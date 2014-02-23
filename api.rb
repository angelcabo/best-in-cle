require 'json'

require_relative 'models/place'

get '/' do
  @places = Place.where(:lat.exists => false)
  erb :index
end

get '/place/:id/edit' do
  @place = Place.find(params[:id])
  erb :edit
end

patch '/place/:id/update' do
  @place = Place.find(params[:id])
  @place.update_attributes!(formatted_address: params[:place][:formatted_address], lat: params[:place][:lat], lng: params[:place][:lng], website: params[:place][:website], phone: params[:place][:phone])
  redirect to('/')
end

get '/foo.json' do
  content_type :json
  return {:foo => "bar"}.to_json
end
