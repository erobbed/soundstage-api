require 'geokit'

class Concert < ApplicationRecord
  has_many :user_concerts
  has_many :users, through: :user_concerts
  has_many :artist_concerts
  has_many :artists, through: :artist_concerts

  def distance(lat, long)
    current_location = Geokit::LatLng.new(lat, long)
    destination = "#{self.lat}, #{self.long}"
    current_location.distance_to(destination)
  end
end
