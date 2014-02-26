#!/usr/bin/ruby

require 'mongoid'
require 'json'

require_relative '../models/place'

Mongoid.load! "mongoid.yml", env

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

Place.each do |place|
  place.update(category: place.category.titleize)
end

File.open("subcategories.json","w") do |f|
    f.write(subcategories.to_json)
end
