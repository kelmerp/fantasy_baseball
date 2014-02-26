require 'rest_client'
require 'json'
require 'pry'

response_batters = RestClient.get 'http://www.kimonolabs.com/api/bt868shs?apikey=455e95d967d14e53ad7188d10746bcf6'

json_batters = JSON.parse(response_batters)

batters = json_batters['results']['collection1']

arr = []

batters.each do |batter|
  name = batter['name']['text'].split('.')[-1].split(',')[0][1..-1]
end


# binding.pry
