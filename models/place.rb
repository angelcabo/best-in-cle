require 'mongoid'

class Place
  include Mongoid::Document

  field :image_url, type: String
  field :name, type: String
  field :cityvoter_url, type: String
  field :url, type: String
  field :location_text, type: String
  field :place, type: String
  field :popularity, type: String
  field :tips, type: String
  field :votes, type: String
  field :categories, type: Array
  field :subcategories, type: Array
  field :website, type: String
  field :phone, type: String

  # Location and Places Data
  field :lat, type: String
  field :lng, type: String
  field :area, type: String
  field :rating, type: String
  field :formatted_address, type: String
  field :map_icon, type: String
  field :places_ref_id, type: String

end
