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

class BannedIp < ActiveRecord::Base
end

=begin
File.open('deep_log') do |f|
  f.each_line do |l|
    m = l.match /\[(.*)\]: (.*)/
    t = Time.parse("#{m[1]} +0900")
    Log.create(ip: "127.0.0.1", text: m[2], created_at: t)
  end
end

=end
