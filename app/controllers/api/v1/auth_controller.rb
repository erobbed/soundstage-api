class Api::V1::AuthController < ApplicationController
  skip_before_action :authorized, only: [:spotify_request]

  def spotify_request
      query_params = {
        client_id: ENV['CLIENT_ID'],
        response_type: "code",
        redirect_uri: ENV['REDIRECT_URI'],
        scope: "user-top-read",
        show_dialog: true
      }
      url = "https://accounts.spotify.com/authorize/"
      redirect_to "#{url}?#{query_params.to_query}"
  end
end
