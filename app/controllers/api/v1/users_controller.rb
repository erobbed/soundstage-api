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

    if @user.expire_artists <= Date.today
      artists = JSON.parse(RestClient.get("https://api.spotify.com/v1/me/top/artists", header).body)
      if !(artists['items'].empty?)
        artist_array = artists['items'].map do |artist|
          # byebug

          a = Artist.find_or_create_by(name: artist['name'], image_url: artist['images'][1]['url'])
          # a = Artist.find_by(name: "Wilco")
          apikey = ENV['TICKETMASTER']
          events = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?keyword=#{a.name}&apikey=#{apikey}"))


          if events['_embedded']

            filteredconcerts = events['_embedded']['events'].select do |concert|
              concert['_embedded']['venues'][0].keys.include?('location')
            end

            @concerts = filteredconcerts.map do |concert|
              seatmap = (!(concert['seatmap']) ? "N/A" : concert['seatmap']['staticUrl'])
              time = concert['dates']['start']
              if time.keys.include?("localTime")
                time = Time.parse(time['localTime']).strftime("%r")
                time[0] == "0" ? time=time[1...-6] + time[-3..-1] : time=time[0...-6] + time[-3..-1]
              else
                time = "N/A"
              end

              province = (concert['_embedded']['venues'][0]['state'] ? concert['_embedded']['venues'][0]['state']['name'] : concert['_embedded']['venues'][0]['country']['name'])
              Concert.find_or_create_by(
                name: concert['name'],
                date: Date.parse(concert['dates']['start']['localDate']).strftime("%b %d, %Y"),
                time: time,
                venue: concert['_embedded']['venues'][0]['name'],
                lat: concert['_embedded']['venues'][0]['location']['latitude'],
                long: concert['_embedded']['venues'][0]['location']['longitude'],
                seatmap: seatmap,
                purchase: concert['url'],
                city: concert['_embedded']['venues'][0]['city']['name'],
                state: province
              )

            end
            a.concerts = @concerts
          end
          a
        end
        @user.artists = artist_array
      end
      @user.expire_artists = Date.today + 5
    end

    render json: {
      jwt: token, user: {
        username: @user.username,
        spotify_url: @user.spotify_url,
        profile_img_url: @user.profile_img_url,
        artists: @user.artists,
        id: @user.id
      }
    }
  end

  def me
    @user = User.find(current_user)
    render json: {
      user: {
        username: @user.username,
        spotify_url: @user.spotify_url,
        profile_img_url: @user.profile_img_url,
        artists: @user.artists,
        id: @user.id
      }
    }
  end

end
