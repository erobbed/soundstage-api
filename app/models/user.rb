class User < ApplicationRecord

  has_many :user_artists
  has_many :artists, through: :user_artists
  has_many :user_concerts
  has_many :concerts, through: :user_concerts

  def access_token_expired?
    (Time.now - self.updated_at) > 3300
  end

  def refresh_access_token
    if access_token_expired?
      body = {
        grant_type: "refresh_token",
        refresh_token: self.refresh_token,
        client_id: ENV['CLIENT_ID'],
        client_secret: ENV["CLIENT_SECRET"]
      }
      auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)
      auth_params = JSON.parse(auth_response)
      self.update(access_token: auth_params["access_token"])
    else
      puts "Current user's access token has not expired"
    end
  end

  def artists_expired?(auth_params)
    if self.expire_artists <= Date.today

      header = {
        Authorization: "Bearer #{auth_params['access_token']}"
      }

      artists = JSON.parse(RestClient.get("https://api.spotify.com/v1/me/top/artists", header).body)
      if !(artists['items'].empty?)
        artist_array = artists['items'].map do |artist|
          a = Artist.find_or_create_by(name: artist['name'], image_url: artist['images'][1]['url'])
          Concert.fetch(a)
        end
        self.artists = artist_array
      end
      self.expire_artists = Date.today + 5
      self.save
    else
      self.artists.each do |a|
        Concert.fetch(a)
      end
    end
  end

end
