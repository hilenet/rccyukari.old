require 'twitter'
require 'json'
require 'yaml'
require 'time'
require 'faraday'

require_relative 'route.rb'


def routin text, char=""
  return if text.empty?
  return if text.length>50

  t = Time.now.to_s
  t.slice! ' +0900'
  File.open('log','a') do |f|
    f.puts "[#{t}]: #{text}\n"
  end
  File.open('deep_log','a') do |f|
    f.puts "[#{t}]: #{text}\n"
  end

  text.gsub!(/(https?|ftp)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)/)
  text.gsub!(/　|\ |\n/, '、')
  text.delete!(",\\.\"\'|<>;:/*`()#}{@$-%!\=\+\[\]")
  
  puts "formated: "#{text}"

  vol = '2.0'
  unless char.empty?
    char = "-c #{char}"
    vol = '1.0'
  end
#  text= docomo(text)
  if text.match(/八雲|やくも|yakumo|ヤクモ|ﾔｸﾓ|淫夢|野獣/)
    text = "汚いこと言わせようとしないでください"
  end
  if text == "世の中には"
    text = "世の中には魔女や魔法少女という存在がいる。魔女とは絶望や呪いから生まれた存在であり、人々に災厄をもたらす異形のモノ。その魔女を倒す者達が魔法少女である。本日この見滝原でも4人の魔法少女が魔女と戦っていた。"
  end

  `yukarin -s #{vol} #{char} -q #{text}`

end

def docomo(text) 
  apikey = "634b4d4856307a37433749704f754735424e6b6d5348725566506b765958667a697757596254492e506e41"

  url = "https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue"

  conn = Faraday.new url
  res = conn.post do |req|
    req.url '?APIKEY='+apikey
    req.headers['Content-Type'] = 'application/json'
    req.body = {
      "utt": text,
    }.to_json
  end
  JSON.parse(res.body)['utt']

end


Thread.abort_on_exception = true

tw = Thread.new do 
  auth = YAML.load_file 'auth.yml'  
  cl = Twitter::Streaming::Client.new do |config|
    config.consumer_key = auth["ck"]
    config.consumer_secret = auth["cs"]
    config.access_token = auth["at"]
    config.access_token_secret = auth["as"]
  end
  print "thread established"
  cl.filter(track: "#rccyukari") do |status|
    next unless status.is_a? Twitter::Tweet
    text = status.text.dup
    next if text.start_with? "RT"
    text.gsub!("#rccyukari", "")
    puts "tw: #{text}"
    routin text
  end
  print "something happen"
end

File.open 'pid', 'w' do |f|
  f.write Process.pid
end

Route.start

