require 'sinatra'
require 'mongoid'

configure do
  Mongoid.load! "#{File.dirname(__FILE__)}/mongoid.yml"
end

require './api'
run Sinatra::Application
