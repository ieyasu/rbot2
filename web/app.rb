load 'config.rb'

require 'rubygems'
require 'sinatra'
require 'cgi'
require 'date'
require 'chronic'
require 'shellwords'
require 'rubybot2/account'
require 'rubybot2/nextlib'

helpers do
  def protected!
    if authorized?
      # XXX set ENV['TZ'] to account's tz
    else
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
    "<a href='/#{name}'><div class='#{c}'>#{name}</div></a>"
  end

  def format_next(nxt)
    msg = nxt[:message].gsub(/<([^>]+)>/, '&lt;\\1&gt;').
      gsub('<', '&lt;').gsub('>', '&gt;')
    msg.gsub(URI.regexp('http')) {|m| "<a href='#{m}'>#{m}</a>"}.
      gsub(/\002([^\002]+)\002/, '<b>\\1</b>')
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
      to = from + (24 * 60 * 60)
    end

    unless (chan = params['chan']) and chan =~ /^#\w+$/
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

  def read_logs(from, to, chan, urls, q)
    # 1. get list of files with date range and channel(s)
    channels = chan ? ["log/#{chan}"] : Dir["log/#*"]
    d = from.dup
    chan_files = {}
    while d <= to
      prefix = d.strftime("/%Y-%m-%d-")
      channels.each do |dir|
        chan = File.basename(dir)
        file = "#{dir}#{prefix}#{chan}.log"
        chan_files[chan] = (chan_files[chan] || []) << file if File.exist?(file)
      end
      d += 24 * 60 * 60
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
      lines = lines.sort_by {|t, text| t}
    else
      lines = log[log.keys.first]
    end

    # 6. format lines
    lines.map do |t, text|
      t.strftime('[%H:%M] ') +
        text.gsub('<', '&lt;').gsub('>', '&gt;').
        sub(/((?:&lt;[\w-]+&gt;)|(?:\* [\w-]+))/, "<span class='nick'>\\1</span>")
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
    files.sort_by {|file| File.mtime(file)}.reverse.each do |file|
      u = `cat #{file} | pcregrep -iuof lib/rubybot2/url-regex.txt | tail -1`.strip
      return u if u.length > 0
    end
    nil
  end

  def last_url
    unless (chan = params['chan']) and chan =~ /^#.*$/
      chan = nil
    end
    channels = chan ? ["log/#{chan}"] : Dir["log/#*"]

    # Fast path: try the last three days' files
    t = Time.now.utc
    files = log_files_for(channels, t)
    t -= 24 * 60 * 60
    files += log_files_for(channels, t)
    t -= 24 * 60 * 60
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

get '/account/create' do
  haml :create
end

post '/account/create' do
  # XXX do stuff with parameters
  'not implemented yet'
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
  @nexts = NextLib.list_undelivered(@account[:name])
  haml :undelivered_nexts
end

get '/logs' do
  protected!

  @channels = ['All'] + Dir['log/#*'].delete_if {|path| !File.directory?(path)}.sort_by {|path| File.mtime(path)}.map {|path| File.basename path}

  @from, @to, @chan, urls, q = get_log_params

  if (f = params['from']) && f.length > 0
    @fromd = params['from']
  else
    @fromd = @from.strftime('%Y-%m-%d')
  end
  if (t = params['to']) && t.length > 0
    @tod = params['to']
  else
    @tod = nil
  end

  @logs = read_logs(@from, @to, @chan, urls, q)

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
