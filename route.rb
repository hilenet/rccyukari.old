require 'sinatra/base'
require 'sinatra/reloader'


class Route < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, 37564

  @@ip = '127.0.0.1'
  @@time = Time.now

  post "/" do
    text = JSON.parse(request.body.read)['mes']

    routin text if filter(request)
  end
  
  get "/" do
    @logs = []
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
    
    p params[:loli]
    if filter request
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

  def filter request
    p request.to_s

    #if request.ip == "192.168.1.3"
    #  return false
    if (request.user_agent.include? "curl")
      return false
    end
    if (request.ip == @@ip)
      if ((Time.now - @@time) < 5)
        @@time = Time.now
        return false
      end
    else
      @@ip = request.ip
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
