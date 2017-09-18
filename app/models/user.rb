class User < ApplicationRecord


  has_many :user_artists
  has_many :artists, through: :user_artists
  has_many :user_concerts
  has_many :concerts, through: :user_concerts
end
