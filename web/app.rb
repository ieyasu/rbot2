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

  def format_next(nxt)
    msg = nxt[:message].gsub(/<([^>]+)>/, '&lt;\\1&gt;').
      gsub('<', '&lt;').gsub('>', '&gt;')
    msg.gsub(URI.regexp('http')) {|m| "<a href='#{m}'>#{m}</a>"}.
      gsub(/\002([^\002]+)\002/, '<b>\\1</b>')
  end
end

get '/' do
  if authorized?
    redirect to('/account')
  else
    haml :index
  end
end

get '/account' do
  protected!
  @nicks = Account.list_nicks(@account[:name])
  haml :account
end

get '/accounts' do
  protected!
  @accounts = DB[:accounts].select_col(:name)
  haml :accounts
end

get '/create' do
  haml :create
end

get '/received-nexts' do
  protected!
  @nexts = NextLib.list_delivered(@account[:name])
  haml :received_nexts
end

get '/undelivered-nexts' do
  protected!
  @nexts = NextLib.list_undelivered(@account[:name])
  haml :undelivered_nexts
end

