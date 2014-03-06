require 'json'

require_relative 'models/place'

get '/' do
  erb :index
end

get '/admin/places' do
  @query_string = request.query_string
  if (params[:with_location] == 'true')
    @places = Place.where(:lat.ne => "", :lat.exists => true)
  elsif (params[:with_location] == 'false')
    # @places = Place.where(:lat.ne => "", :lat.exists => false)
    @places = Place.any_of({ lat: "" }, { :lat.exists => false })
  else
    @places = Place.all
  end
  erb :admin_index
end

get '/admin/place/:id/edit' do
  @place = Place.find(params[:id])
  @query_string = request.query_string
  erb :admin_edit
end

patch '/admin/place/:id/update' do
  @place = Place.find(params[:id])
  @place.update_attributes!(formatted_address: params[:place][:formatted_address], lat: params[:place][:lat], lng: params[:place][:lng], website: params[:place][:website], phone: params[:place][:phone])
  redirect to("/admin/places?#{request.query_string}")
end
