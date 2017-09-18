class Artist < ApplicationRecord
  has_many :user_artists
  has_many :users, through: :user_artists
  has_many :artist_concerts
  has_many :concerts, through: :artist_concerts	
end
