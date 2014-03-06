#!/usr/bin/ruby

require 'rest_client'
require 'mongoid'
require 'geokit'
require_relative '../models/place'

require 'pry'

env = 'development'

ARGV.each do |arg|
  arg_split = arg.split "="
  if arg_split[0] == 'env'
    if arg_split[1] == 'development' || arg_split[1] == 'test'
      env = arg_split[1]
    elsif arg_split[1] == 'production'
      if ENV['MONGOHQ_URL'].nil? || ENV['MONGOHQ_URL'].empty?
        raise "MONGOHQ_URL not defined"
      end
      env = arg_split[1]
    end
  end
end

api_key = 'AIzaSyDoUKogMqiFAq7pM0uZDYLY8dHeDhDp3RU'

Mongoid.load! "mongoid.yml", env

catch :over_limit do
  (1..29).each do |index|
    puts "checking page: #{index}"
    response = RestClient.get 'http://cleveland.cityvoter.com/Voting/ViewContest.aspx', {:params => {:contest => '4883', :GetMoreCategories => index}}
    json_response = JSON.parse(response)
    json_response["categories"].each do |category|
      subcategory_name = category["url"].split("/")[2].gsub("-", "_")
      category_name = category["url"].split("/")[3].gsub("-", "_")
      category["entries"].each do |entry|
        place = Place.where(name: entry["BusinessName"])[0]
        if (!place)
          puts "Searching for #{entry["BusinessName"]}..."
          place_response = RestClient.get 'https://maps.googleapis.com/maps/api/place/textsearch/json', {:params => {:query => entry["BusinessName"], :key => api_key, :sensor => 'false', :location => '41.4822,-81.6697', :radius => '100'}}
          json_response = JSON.parse(place_response)
          if (json_response["results"][0] && json_response["results"][0]["geometry"])
            place_json = json_response["results"][0]
            Place.create(image_url: entry["BusinessImageUrl"],
                         name: entry["BusinessName"],
                         url: entry["url"],
                         location_text: entry["LocationText"],
                         place: entry["Place"],
                         popularity: entry["Popularity"],
                         tips: entry["Tips"],
                         votes: entry["Votes"],
                         category: category_name.titleize,
                         subcategory: subcategory_name.titleize,
                         lat: place_json["geometry"]["location"]["lat"],
                         lng: place_json["geometry"]["location"]["lng"],
                         map_icon: place_json["icon"],
                         places_ref_id: place_json["reference"],
                         rating: place_json["rating"],
                         formatted_address: place_json["formatted_address"])
          else
            if json_response["status"] == "OVER_QUERY_LIMIT"
              puts "Ending on page: #{index}"
              throw :over_limit
            end
            Place.create(image_url: entry["BusinessImageUrl"],
                         name: entry["BusinessName"],
                         url: entry["url"],
                         location_text: entry["LocationText"],
                         place: entry["Place"],
                         popularity: entry["Popularity"],
                         tips: entry["Tips"],
                         votes: entry["Votes"],
                         category: category_name.titleize,
                         subcategory: subcategory_name.titleize)
          end
          sleep 2
        else
          puts "Updating #{entry["BusinessName"]}..."
          place.update_attributes!(image_url: entry["BusinessImageUrl"],
                                   name: entry["BusinessName"],
                                   url: entry["url"],
                                   location_text: entry["LocationText"],
                                   place: entry["Place"],
                                   popularity: entry["Popularity"],
                                   tips: entry["Tips"],
                                   votes: entry["Votes"],
                                   category: category_name,
                                   subcategory: subcategory_name.titleize)
        end
      end
    end
  end
end
