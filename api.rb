require 'sinatra'
require 'json'

get '/foo.json' do
  content_type :json
  return {:foo => "bar"}.to_json
end
