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

categories = []
Place.distinct(:category).each do |c|
  category = {name: c}
  category[:count] = Place.where(category: c).count
  category[:subcategories] = []
  Place.where(category: c).distinct(:subcategory).each do |sub|
    subcategory = {name: sub}
    subcategory[:count] = Place.where(subcategory: sub).count
    category[:subcategories] << subcategory
  end
  categories << category
end

File.open("categories.json","w") do |f|
    f.write(categories.to_json)
end
