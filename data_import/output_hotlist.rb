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

places = []
Place.each do |place|
  places << place
end

File.open("hotlist.json","w") do |f|
    f.write(places.to_json)
end
