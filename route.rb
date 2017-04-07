require 'sinatra/base'
require 'sinatra/reloader'
require 'sqlite3'
require 'active_record'
require 'securerandom'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'hoge.db'
)

class Slug < ActiveRecord::Base
  self.primary_key  = :slug_id
end


class Route < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, 37564
  enable :sessions

  @@ip = '127.0.0.1'
  @@time = Time.now

  post "/" do
    text = JSON.parse(request.body.read)['mes']

    routin text if filter request, session
  end
  
  get "/" do
    @logs = []
    session[:slug_id] = publish_slug

    File.open('log', 'r') do |f|
      f.each_line do |l|
        @logs.unshift l
      end
      # not mutex!!!!
      switchLog if f.lineno>100
    end
  
    erb :index
  end
  
  post "/form" do
    text = params[:text]

    if filter request, session
      if params[:loli]=="loli"
        routin text, "ai"
      elsif params[:kansai]=="kansai"
        routin text, "akn"
      else
        routin text
      end
    end
    
    redirect to('/')
  end

  get "/silent" do
    `ps aux | grep mpg | grep -v grep | awk '{ print "kill -9", $2 }' | sh`
    redirect to('/')
  end

  def publish_slug
    slug_id = SecureRandom.hex(32)
    Slug.create({"slug_id": slug_id}).slug_id 

    return slug_id
  end

  def destroy_slug slug_id
    slug = Slug.find_by(slug_id: slug_id)

    return false unless slug

    slug.destroy()

    return slug.slug_id
  end

  def filter request, session
    # sessionベースのフィルタリング
    unless destroy_slug(session[:slug_id])
      return false
    end

    return true
  end


  def switchLog
    buf = File.read('log').split("\n").drop(50)
  
    File.write('log', buf.join("\n")+"\n")
  end

  def self.start
    run!
  end
end
