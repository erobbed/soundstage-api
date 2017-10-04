class Api::V1::UsersController < ApplicationController

  skip_before_action :authorized

  def create
    body = {
      grant_type: "authorization_code",
      code: params[:code],
      redirect_uri: ENV['REDIRECT_URI'],
      client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET']
    }

    auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)
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

    img_url = (user_params["images"][0] ? user_params["images"][0]["url"] : nil)
    @user.update(profile_img_url: img_url)
    @user.update(access_token: auth_params['access_token'], refresh_token: auth_params['refresh_token'])
    payload = {user_id: @user.id}
    token = issue_token(payload)

    @user.artists_expired?(auth_params)

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

  def geo
    res = RestClient.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{params['geo']}&key=#{ENV['GEOCODE']}")
    coords = JSON.parse(res)['results'][0]['geometry']['location']
    render json: {coords: {latitude: coords['lat'], longitude: coords['lng']}}
  end

end
