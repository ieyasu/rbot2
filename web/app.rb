load 'config.rb'

require 'rubygems'
require 'sinatra'
require 'rubybot2/account'
require 'rubybot2/nextlib'

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
    "<a href='/#{name}'><div class='#{c}'>#{name}</div></a>"
  end

  def format_next(nxt)
    msg = nxt[:message].gsub(/<([^>]+)>/, '&lt;\\1&gt;').
      gsub('<', '&lt;').gsub('>', '&gt;')
    msg.gsub(URI.regexp('http')) {|m| "<a href='#{m}'>#{m}</a>"}.
      gsub(/\002([^\002]+)\002/, '<b>\\1</b>')
  end

  def read_logs(startd, endd, channel)
    ymd = startd.strftime('%Y-%m-%d')
    File.open("log/#{channel}/#{ymd}.log") do |fin|
      fin.read.split(/\r?\n/).map do |line|
        line.gsub('<', '&lt;').gsub('>', '&gt;').
          gsub(/(&lt;[\w-]+&gt;)/, "<span class='nick'>\\1</span>")
      end
    end
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

  @channels = Dir['log/#*'].delete_if {|path| !File.directory?(path)}.sort_by {|path| File.mtime(path)}.map {|path| File.basename path} +
    ['All']

  @startd = Time.now.utc
  @endd = nil

  @logs = read_logs(@startd, @startd, '#hatcave')

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
