load 'config.rb'

require 'rubygems'
require 'sinatra'
require 'date'
require 'chronic'
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
    files = []
    while d <= to
      prefix = d.strftime("/%Y-%m-%d-")
      channels.each do |dir|
        file = "#{dir}#{prefix}#{File.basename(dir)}.log"
        files << file if File.exist?(file)
      end
      d += 24 * 60 * 60
    end

    # 2. read in log lines
    log = channels.inject({}) {|h, chan| h[File.basename chan] = []; h}

    files.each do |file|
      file =~ /\d-(#.+)\.log$/; chan = $1
      s =
        if urls == :urls || q               # filter with pcregrep
          `pcregrep -hiu #{q} -- #{file}`
        else                                # read the whole file
          File.read(file)
        end
      log[chan] += s.split(/\r?\n/)
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

    # 5. format lines
    res = []
    log.each do |chan, lines|
      res << chan
      lines.each do |t, text|
        if t && text
          res << t.strftime('[%H:%M] ') +
            text.gsub('<', '&lt;').gsub('>', '&gt;').
            sub(/((?:&lt;[\w-]+&gt;)|(?:\* [\w-]+))/, "<span class='nick'>\\1</span>")
        else
          res << "t = #{t.inspect} && text = #{text.inspect}"
        end
      end
    end
    res
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

  @from, @to, chan, urls, q = get_log_params

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

  @logs = read_logs(@from, @to, chan, urls, q)

  haml :chatlog
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
