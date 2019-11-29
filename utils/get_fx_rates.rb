require 'net/http'
require 'json'

# Setting URL
url = "https://api.exchangerate-api.com/v4/latest/USD"
uri = URI(url)
response = Net::HTTP.get(uri)
response_obj = JSON.parse(response)
rate = response_obj['rates']['EUR']
puts rate.inspect
