# require 'rest-client'
# require'json'

class Api::V1::UsersController < ApplicationController

  skip_before_action :authorized

  def create
    #assemble and send request to Spotify for access and refresh token
    body = {
      grant_type: "authorization_code",
      code: params[:code],
      redirect_uri: ENV['REDIRECT_URI'],
      client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET']
    }
    # byebug
    auth_response = RestClient.post('https://accounts.spotify.com/api/token', body) #ERROR HERE FROM FETCH POST IN AUTH ACTION
    auth_params = JSON.parse(auth_response.body)
    header = {
      Authorization: "Bearer #{auth_params['access_token']}"
    }
    user_response = RestClient.get("https://api.spotify.com/v1/me", header)
    user_params = JSON.parse(user_response.body)

    @user = User.find_or_create_by(
      username: user_params['id'],
      spotify_url: user_params['external_urls']['spotify'],
      href: user_params['href'],
      uri: user_params['uri']
    )
    img_url = user_params["images"][0] ? user_params["images"][0]["url"] : nil
    @user.update(profile_img_url: img_url)
    @user.update(access_token: auth_params['access_token'], refresh_token: auth_params['refresh_token'])
    payload = {user_id: @user.id}
    token = issue_token(payload)

    if @user.expire_artists > Date.today
      artists = JSON.parse(RestClient.get("https://api.spotify.com/v1/me/top/artists", header).body)
      if !(artists['items'].empty?)
        artist_array = artists['items'].map do |artist|
          a = Artist.create(name: artist['name'], image_url: artist['images'][1]['url'])

          apikey = ENV['TICKETMASTER']
          events = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?keyword=#{a.name}&apikey=#{apikey}"))
          @concerts = events['_embedded']['events'].map do |concert|
            seatmap = (!(concert['seatmap']) ? "N/A" : concert['seatmap']['staticUrl'])
            time = Time.parse(concert['dates']['start']['localTime']).strftime("%r")
            time[0] == "0" ? time=time[1..-1] : time
            # byebug
            Concert.find_or_create_by(
              name: concert['name'],
              date: Date.parse(concert['dates']['start']['localDate']).strftime("%b %d, %Y"),
              time: time,
              venue: concert['_embedded']['venues'][0]['name'],
              lat: concert['_embedded']['venues'][0]['location']['latitude'],
              long: concert['_embedded']['venues'][0]['location']['longitude'],
              seatmap: seatmap,
              purchase: concert['url']
            )
          end
          a.concerts = @concerts
          a
        end
        # byebug
        @user.artists = artist_array
      end
      @user.expire_artists = Date.today + 5
    end
    # byebug

    render json: {
      jwt: token, user: {
        username: @user.username,
        spotify_url: @user.spotify_url,
        profile_img_url: @user.profile_img_url,
        artists: @user.artists
      }
    }
  end
end
