require 'sinatra/base'
require 'sinatra/reloader'
require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'hoge.db'
)

# all log
# ip, text, times
class Log < ActiveRecord::Base
end

# banned ips table
# ip, times
class BannedIp < ActiveRecord::Base
end


class Route < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, 37564 
  set :environment, 'production'
  
  # top page
  get "/" do
    @logs = Log.last(50).map do |node| 
      "[#{node.created_at.localtime.to_s[0..-7]}]: #{node.text}"
    end
  
    erb :index
  end
  
  # receive posted text 
  post "/form" do
    text = params[:text]

    if filter request
      if params[:loli]=="loli"
        routin text, request.ip, "ai"
      elsif params[:kansai]=="kansai"
        routin text, request.ip, "akn"
      else
        routin text, request.ip
      end

    end
    
    redirect to('/')
  end

  post "/yo" do 
    url = params[:url]
    redirect to '/' if url.include? ";"
    redirect to '/' unless url.include? "http"

    `youtube-dl '#{url}' -o - | mplayer - -novideo --volume=30 --softvol`

    redirect to('/')
  end

  # quiet
  get "/silent" do
    `ps aux | grep mpg | grep -v grep | awk '{ print "kill -9", $2 }' | sh`
    `ps aux | grep youtube-dl | grep -v grep | awk '{ print "kill -9", $2 }' | sh`
    `ps aux | grep mplayer | grep -v grep | awk '{ print "kill -9", $2 }' | sh`
    redirect to('/')
  end

  get '/banned' do
    @list = BannedIp.all.map

    erb :banned
  end

  # return false if data invalid
  def filter request
    # Thread切りたいけどトランザクション怪しいなあ・・・
    update_banned_table(request)
    return false if BannedIp.all.map{|node| node.ip}.include? request.ip

    return true
  end

  # expire = 3600s
  # ban : 10req / 10s
  def update_banned_table request
    # reflesh
    unless (l=BannedIp.where("created_at < ?", Time.now-3600)).empty?
      BannedIp.destroy l.map{|node| node.id}
    end
    # ban
    if Log.where("created_at > ?", Time.now-10).length >= 10
      BannedIp.create(ip: request.ip) unless BannedIp.find_by(ip: request.ip)
      puts "ban: #{request.ip}"
    end
  end

  def self.start
    run!
  end
end
