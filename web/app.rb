load 'config.rb'

require 'rubygems'
require 'sinatra'
require 'cgi'
require 'date'
require 'chronic'
require 'shellwords'
require 'rubybot2/account'
require 'rubybot2/irc'
require 'rubybot2/nextlib'

set :public_folder, File.dirname(__FILE__) + '/pub'

r = File.read('lib/rubybot2/url-regex.txt').scan(/^(?![#\r\n])[^\r\n]+/)
$url_regex = Regexp.new(r.first, Regexp::IGNORECASE)

SHORT_TIME_FMT  = '[%H:%M] '
MED_TIME_FMT    = '[%a %H:%M] '
LONG_TIME_FMT   = '[%b %d %H:%M] '
VLONG_TIME_FMT  = '[%b %d, %Y %H:%M] '
DAY = 24 * 60 * 60
WEEK = 7 * DAY
MONTH = 31 * DAY
YEAR = 365 * DAY

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    if @auth.provided? && @auth.basic? && @auth.credentials
      name, trypass = @auth.credentials
      @account = Account.by_name(name)
      Account.check_passwd(name, trypass)
    else
      false
    end
  end

  def navitem(name)
    i = request.path_info.index(name)
    c = (i && i < 2) ? 'current' : 'other'
    "<a href='#{url name}'><div class='#{c}'>#{name}</div></a>"
  end

  def link_urls(text)
    text.gsub($url_regex) do |m|
      u = (m =~ /^(?:http|ftp)/) ? m : "http://#{m}"
      "<a href='#{u}'>#{m}</a>"
    end
  end

  def format_next(nxt)
    msg = nxt[:message].gsub(/<([^>]+)>/, '&lt;\\1&gt;').
      gsub('<', '&lt;').gsub('>', '&gt;')
    link_urls(msg).gsub(/\002([^\002]+)\002/, '<b>\\1</b>')
  end

  def get_log_params(urls_default = :fulltext)
    if (from = params['from']) && from.length > 0
      from = Chronic.parse(from, :context => :past, :guess => false)
      from = from.begin if Chronic::Span === from
    else
      t = Time.now
      from = Time.new(t.year, t.month, t.day)
    end

    if (to = params['to']) && to.length > 0
      to = Chronic.parse(to, :context => :past, :guess => false)
      to = to.end if Chronic::Span === to
    else
      to = from + DAY
    end

    unless (chan = params['chan']) and IRC.channel_name?(chan)
      chan = nil
    end

    case params['urls']
    when 'urls'
      urls = :urls
    when 'fulltext'
      urls = :fulltext
    else
      urls = urls_default
    end

    unless (q = params['q']) and q.length > 0
      q = nil
    end

    return from.utc, to.utc, chan, urls, q
  end

  def log_dirs
    Dir["log/[#+&]*"]
  end

  def read_logs(from, to, chan, urls, q)
    # 1. get list of files with date range and channel(s)
    channels = chan ? ["log/#{chan}"] : log_dirs
    d = from.dup
    chan_files = {}
    while d <= to
      prefix = d.strftime("/%Y-%m-%d-")
      channels.each do |dir|
        chan = File.basename(dir)
        file = "#{dir}#{prefix}#{chan}.log"
        chan_files[chan] = (chan_files[chan] || []) << file if File.exist?(file)
      end
      d += DAY
    end

    # 2. read in log lines
    log = channels.inject({}) {|h, chan| h[File.basename chan] = []; h}
    chan_files.each do |chan, files|
      cmd = "cat #{files.join(' ')}"
      cmd << " | pcregrep -iue #{Shellwords.shellescape q}" if q
      cmd << " | pcregrep -iuf lib/rubybot2/url-regex.txt" if urls == :urls
      cmd << " | head -n 50000" # ought to be enough for anybody!
      log[chan] += `#{cmd}`.split(/\r?\n/)
    end

    # 3. split into Time, String pairs
    log.each_key do |chan|
      log[chan] = log[chan].map do |line|
        stamp, text = line.split(' ', 2)
        t = DateTime.strptime(stamp, '%Y-%m-%dT%H:%M:%S%Z').to_time
        [t, text]
      end
    end

    # 4. filter by date range
    log.each_key do |chan|
      log[chan] = log[chan].select {|t, text| from <= t && t <= to}
    end

    # 5. prefix with channel when multiple channels present and sort by time,
    #    commingling results
    if log.keys.length > 1
      lines = []
      log.each do |chan, clines|
        clines.each do |t, text|
          lines << [t, "#{chan} #{text}"]
        end
      end
      # XXX not sure what to do about this fucking up whitespace
      #lines = lines.sort_by {|t, text| t}
    else
      lines = log[log.keys.first]
    end

    # 6. format lines
    lines.map do |t, text|
      s = text.gsub('<', '&lt;').gsub('>', '&gt;').
        sub(/((?:&lt;#{IRC::NICK}&gt;)|(?:\* [\w-]+))/, "<span class='nick'>\\1</span>").
        gsub(/\003(1[0-5]|\d)?(?:,(1[0-5]|\d))?([^\003]+)/) do |m|
          if $1 || $2
            c = "<span class='"
            c << "fg#$1" if $1
            c << " bg$2" if $2
            c << "'>#{$3}</span>"
          else
            $3
          end
      end
      fmt =
        if @to - @from < 2 * DAY
          SHORT_TIME_FMT  # HH:MM
        elsif @to - @from < WEEK
          MED_TIME_FMT    # Day HH:MM
        elsif @to - @from < YEAR
          LONG_TIME_FMT   # Mon DY HH:MM
        else
          VLONG_TIME_FMT  # Mon DY, YYYY HH:MM
        end
      t.strftime(fmt) + link_urls(s)
    end
  end

  def log_files_for(channels, t)
    prefix = t.strftime("/%Y-%m-%d-")
    channels.map do |dir|
      chan = File.basename(dir)
      "#{dir}#{prefix}#{chan}.log"
    end.delete_if {|file| !File.exist?(file)}
  end

  def find_latest_url(files)
    files.sort_by {|file| File.mtime(file)}.reverse_each do |file|
      u = `cat #{file} | pcregrep -iuvf lib/rubybot2/url-block.txt | pcregrep -iuof lib/rubybot2/url-regex.txt | tail -1`.strip
      if u.length > 0
        u = "http://#{u}" if u !~ /^(?:http|ftp)/
        return u 
      end
    end
    nil
  end

  # XXX pull from file written by global_message service
  def last_url
    unless (chan = params['chan']) and IRC.channel_name?(chan)
      chan = nil
    end
    channels = chan ? ["log/#{chan}"] : log_dirs

    # Fast path: try the last three days' files
    t = Time.now.utc
    files = log_files_for(channels, t)
    t -= DAY
    files += log_files_for(channels, t)
    t -= DAY
    files += log_files_for(channels, t)
    url = find_latest_url(files) and return url

    # Slow path: go through all remaining log files newest -> oldest
    other_files = channels.map {|c| Dir["#{c}/*.log"].to_a}.flatten - files
    find_latest_url(other_files)
  end
end

not_found do
  haml :four_oh_four
end

get '/' do
  if authorized?
    redirect to('/account')
  else
    haml :index
  end
end

get '/style/site.css' do
  sass :site
end

get '/account' do
  protected!
  @nicks = Account.list_nicks(@account[:name])
  haml :account
end

post '/account' do
  protected!
  @errors = []
  @notices = []

  if (nicks = params['nicks'])
    enicks = Account.list_nicks(@account[:name])
    nicks = nicks.scan(IRC::NICK_REGEX)
    if nicks.length > 0 # add or remove nicks
      remnicks = enicks - nicks
      (nicks - enicks).each do |addnick|
        succ, msg = Account.add_nick(@account[:name], addnick)
        (succ ? @notices : @errors) << msg
      end
    elsif enicks.length > 0 # remove existing nicks
      remnicks = enicks
    else
      remnicks = []
    end
    remnicks.each do |remnick|
      succ, msg = Account.del_nick(@account[:name], remnick)
      (succ ? @notices : @errors) << msg
    end
  end
  @nicks = Account.list_nicks(@account[:name])

  if (zip = params['zip']) and zip =~ /^\d{1,5}$/
    zip = zip.to_i
    if zip != @account[:zip]
      DB[:accounts].filter(name: @account[:name]).update(zip: zip)
      @account = Account.by_name(@account[:name])
      @notices << "Updated zip code"
    end
  else
    @errors << "Zip is not a 5-digit US zip code"
  end

  if (pass1 = params['pass1']) && pass1.length > 0
    if (pass2 = params['pass2']) && pass2.length > 0
      if pass1.length < 3
        @errors << "Password must be at least 3 characters long"
      elsif pass1 != pass2
        @errors << "Passwords do not match"
      else
        DB[:accounts].filter(name: @account[:name]).update(passwd: Account::hash_passwd(pass1))
        @account = Account.by_name(@account[:name])
        @notices << "Password updated"
      end
    else
      @errors << "You must confirm the new password"
    end
  end

  haml :account
end

post '/account/destroy' do
  protected!
  Account::destroy(@account[:name])
  haml :account_destroy
end

get '/account/create' do
  @errors = []
  haml :account_create
end

post '/account/create' do
  @errors = []
  if (@name = params['name']) and @name !~ /^\w+$/
    @errors << "Name must only contain letters, numbers, '_', and no spaces"
  elsif Account::exists?(@name)
    @errors << "Account '#{@name}' already exists"
  end
  if (@zip = params['zip']) and @zip !~ /^\d{1,5}$/
    @errors << "Zip is not a 5-digit US zip code"
  end
  if (@password = params['password']) and @password.length < 3
    @errors << "Password must be at least 3 characters long"
  end
  if @password and @password =~ /\s/
    @errors << "Password must not contain whitespace"
  end

  if @errors.length > 0
    haml :account_create
  elsif Account::create(@name, @zip.to_i, @password)
    redirect to('/account')
  else
    @errors << "Unknown error creating account"
    haml :account_create
  end
end

get '/account/received-nexts' do
  protected!
  @title = 'Received Nexts'
  @nexts = NextLib.list_delivered(@account[:name])
  haml :received_nexts
end

get '/account/undelivered-nexts' do
  protected!
  @title = 'Undelivered Nexts'
  @nexts = NextLib.list_undelivered(@account[:name], 0)
  haml :undelivered_nexts
end

post '/account/delete-next/:nid' do
  protected!
  if NextLib.delete_undelivered(@account[:name], params[:nid])
    'success'
  else
    halt 409, 'next not found'
  end
end

MIN_DEFAULT_RESULTS = 32

get '/logs' do
  protected!

  @channels = ['All'] + log_dirs.delete_if {|path| !File.directory?(path)}.
    sort_by {|path| File.mtime(path)}.map {|path| File.basename path}
  @from, @to, @chan, urls, q = get_log_params
  @logs = read_logs(@from, @to, @chan, urls, q)
  two_weeks_ago = Time.now - (2 * WEEK)
  if !(from = params['from']) || from.length < 1
    while @logs.length < MIN_DEFAULT_RESULTS && @from > two_weeks_ago
      @from -= DAY
      @logs = read_logs(@from, @to, @chan, urls, q)
    end
  end
  haml :chatlog
end

get '/logs/golast' do
  protected!
  if (url = last_url)
    redirect url, 302
  else
    'No URL to be found!'
  end
end

get '/db' do
  protected!
  haml :db
end

get '/db/accounts' do
  protected!
  @accounts = DB[:accounts].select_col(:name)
  haml :accounts
end

get '/db/last' do
  protected!
  @last = DB[:last].order(:chan, :nick).all
  haml :db_last
end

get '/db/points' do
  protected!
  @points = DB[:points].all
  haml :db_points
end

get '/db/levels' do
  protected!
  @levels = DB[:levels].all
  haml :db_levels
end
