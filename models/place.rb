require 'mongoid'

class Place
  include Mongoid::Document

  field :business_image_url, type: String
  field :business_name, type: String
  field :business_url, type: String
  field :entry_id, type: String
  field :location_text, type: String
  field :place, type: String
  field :popularity, type: String
  field :sub_category_id, type: String
  field :sub_category_name, type: String
  field :sub_category_url, type: String
  field :tips, type: String
  field :votes, type: String
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
