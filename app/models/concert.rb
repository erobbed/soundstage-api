class Concert < ApplicationRecord
  has_many :user_concerts	
  has_many :users, through: :user_concerts
  has_many :artist_concerts
  has_many :artists, through: :artist_concerts
end
