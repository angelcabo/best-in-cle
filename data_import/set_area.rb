#!/usr/bin/ruby

require 'mongoid'
require 'json'

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

Mongoid.load! "mongoid.yml", env

Place.each do |place|
  if (place.lat.to_f < 41.430135)
    place.update_attribute(:area, "South")
  elsif (place.lng.to_f < -81.695409)
    place.update_attribute(:area, "West Side")
  else
    place.update_attribute(:area, "East Side")
  end
end
