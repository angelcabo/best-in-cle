#!/usr/bin/ruby

require 'rest_client'
require 'mongoid'
require 'nokogiri'
require 'open-uri'
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

api_key = 'AIzaSyBnEIFJMht60xYzH4I2I8bybHqv-4qikU8'

Mongoid.load! "mongoid.yml", env

category_doc = Nokogiri::HTML(open('http://cleveland.cityvoter.com/best/cleveland'))

catch :over_limit do
  category_doc.css('dl.LinkList').first.css('dd a').each do |category_link|
    subcategory_doc = Nokogiri::HTML(open("http://cleveland.cityvoter.com/#{category_link['href']}"))
    subcategory_doc.css('dl.LinkList').first.css('dd ul li a').each do |subcategory_link|
      page = 1
      while page > 0 do
        response = RestClient.get "http://cleveland.cityvoter.com/#{subcategory_link['href']}", {:params => {:Get_entries => page}}
        category_response = JSON.parse(response)
        page = Integer(category_response["page"])
        category_response["payload"].each do |entry|
          place = Place.where(name: entry["BusinessName"]).first
          if (!place)
            puts "Searching for #{entry["BusinessName"]}..."
            place_response = RestClient.get 'https://maps.googleapis.com/maps/api/place/textsearch/json', {:params => {:query => entry["BusinessName"], :key => api_key, :sensor => 'false', :location => '41.4822,-81.6697', :radius => '100'}}
            json_response = JSON.parse(place_response)
            if (json_response["results"][0] && json_response["results"][0]["geometry"])
              place_json = json_response["results"][0]
              Place.create(image_url: entry["BusinessImageUrl"],
                           name: entry["BusinessName"],
                           url: entry["url"],
                           cityvoter_url: entry["BusinessUrl"],
                           location_text: entry["LocationText"],
                           place: entry["Place"],
                           popularity: entry["Popularity"],
                           tips: entry["Tips"],
                           votes: entry["Votes"],
                           categories: [category_link.content],
                           subcategories: [subcategory_link.content],
                           lat: place_json["geometry"]["location"]["lat"],
                           lng: place_json["geometry"]["location"]["lng"],
                           map_icon: place_json["icon"],
                           places_ref_id: place_json["reference"],
                           rating: place_json["rating"],
                           formatted_address: place_json["formatted_address"])
            else
              if json_response["status"] == "OVER_QUERY_LIMIT"
                puts "Over Query Limit: Ending on #{category_link.content}: #{subcategory_link.content} - page #{page}"
                throw :over_limit
              end
              Place.create(image_url: entry["BusinessImageUrl"],
                           name: entry["BusinessName"],
                           url: entry["url"],
                           cityvoter_url: entry["BusinessUrl"],
                           location_text: entry["LocationText"],
                           place: entry["Place"],
                           popularity: entry["Popularity"],
                           tips: entry["Tips"],
                           votes: entry["Votes"],
                           categories: [category_link.content],
                           subcategories: [subcategory_link.content])
            end
            sleep 2
          else
            puts "Updating #{entry["BusinessName"]}..."
            place.update_attributes!(image_url: entry["BusinessImageUrl"],
                                     name: entry["BusinessName"],
                                     url: entry["url"],
                                     cityvoter_url: entry["BusinessUrl"],
                                     location_text: entry["LocationText"],
                                     place: entry["Place"],
                                     popularity: entry["Popularity"],
                                     tips: entry["Tips"],
                                     votes: entry["Votes"])
            place.add_to_set(:categories, category_link.content) unless place.categories.include?(category_link.content)
            place.add_to_set(:subcategories, subcategory_link.content) unless place.subcategories.include?(subcategory_link.content)
          end
        end
      end
    end
  end
end
