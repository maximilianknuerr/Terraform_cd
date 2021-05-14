# A simple web app built on top of Ruby and Sinatra.

require 'sinatra'
require 'json'
require 'redis'

set :port, ARGV[0] || 4567
set :bind, '0.0.0.0'

redis = Redis.new(host: ARGV[1] || "localhost")

get '/' do
  redis.lpush("user_agents", "#{Time.now} - #{request.user_agent}")
  redis.ltrim("user_agents", 0, 9)

  content_type :json
  JSON.dump redis.lrange("user_agents", 0, -1)
end