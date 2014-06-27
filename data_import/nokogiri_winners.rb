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

api_key = 'AIzaSyDEBiXVPoWSaQlJzAH_S3ZL-WXVreU5s78'

Mongoid.load! "mongoid.yml", env

category_doc = Nokogiri::HTML(open('http://cleveland.cityvoter.com/best/cleveland'))
catch :over_limit do
  category_doc.css('.winner-section-area li h4.section-title a').each do |category_link|
    subcategory_doc = Nokogiri::HTML(open("http://cleveland.cityvoter.com/#{category_link['href']}"))
    subcategory_doc.css('.results-featured li .ellips a').each do |subcategory_link|
      winners_doc = Nokogiri::HTML(open("http://cleveland.cityvoter.com/#{subcategory_link['href']}"))
      catch :only_top_five do
        winners_doc.css('.category-results li').each_with_index do |biz, i|
          throw :only_top_five if i > 4
          biz_name = biz.css('.BizName').first.content
          place = Place.where(name: biz_name).first
          if (!place)
            biz_location_text = biz.css('.locality').first ? biz.css('.locality').first.content : ""
            biz_cityvoter_url = biz.css('.BizName').first['href']
            biz_image_url = biz.css('.BizImg img').first['src']
            puts "Searching for #{biz_name}..."
            place_response = RestClient.get 'https://maps.googleapis.com/maps/api/place/textsearch/json', {:params => {:query => biz_name, :key => api_key, :sensor => 'false', :location => '41.4822,-81.6697', :radius => '100'}}
            json_response = JSON.parse(place_response)
            if (json_response["results"][0] && json_response["results"][0]["geometry"])
              place_json = json_response["results"][0]
              Place.create(image_url: biz_image_url,
                           name: biz_name,
                           url: "",
                           cityvoter_url: biz_cityvoter_url,
                           location_text: biz_location_text,
                           place: (i+1).ordinalize,
                           categories: [category_link.content],
                           subcategories: [subcategory_link.content.gsub("Best ", "")],
                           lat: place_json["geometry"]["location"]["lat"],
                           lng: place_json["geometry"]["location"]["lng"],
                           map_icon: place_json["icon"],
                           places_ref_id: place_json["reference"],
                           rating: place_json["rating"],
                           formatted_address: place_json["formatted_address"])
            else
              if json_response["status"] == "OVER_QUERY_LIMIT"
                puts "Over Query Limit"
                throw :over_limit
              end
              Place.create(image_url: biz_image_url,
                           name: biz_name,
                           url: "",
                           cityvoter_url: biz_cityvoter_url,
                           location_text: biz_location_text,
                           place: (i+1).ordinalize,
                           categories: [category_link.content],
                           subcategories: [subcategory_link.content.gsub("Best ", "")])
            end
            sleep 2
          else
            puts "Updating #{category_link.content} -> #{subcategory_link.content} -> #{biz_name}..."
            place.update_attribute(:place, (i + 1).ordinalize)
            place.add_to_set(:categories, category_link.content) unless place.categories.include?(category_link.content)
            place.add_to_set(:subcategories, subcategory_link.content.gsub("Best ", "")) unless place.subcategories.include?(subcategory_link.content.gsub("Best ", ""))
          end
        end
      end
    end
  end
end
