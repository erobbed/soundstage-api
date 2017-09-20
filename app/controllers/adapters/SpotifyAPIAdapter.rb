class SpotifyAPIAdapter < ApplicationController
  #current-user helper method
  # def self.refresh_token
  #   if current_user.access_token_expired?
  #     body = {
  #       grant_type: 'refresh_token',
  #       refresh_token: current_user.refresh_token,
  #       client_id: ENV['CLIENT_ID'],
  #       client_secret: ENV['CLIENT_SECRET']
  #     }
  #
  #     auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)
  #     auth_params - JSON.parse(auth_response)
  #     current_user.update(access_token: auth_params['access_token'])
  #   else
  #     puts "Current user's access token has not expired."
  #   end
  # end
end
