class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authorized, except: [:issue_token, :decode_token, :logged_in?]

  def issue_token(payload)
    JWT.encode(payload, ENV['JWT_SECRET'], ENV['JWT_ALGORITHM'])
  end

  def decoded_token(token)
    begin
      JWT.decode(token, ENV['JWT_SECRET'], ENV['JWT ALGORITHM'] )
    rescue JWT::DecodeError
      []
    end
  end

  def token
    if bearer_token = request.headers["Authorization"]
      jwt_token = bearer_token.split(" ")[1]
    else
      # no return
    end
  end

  def current_user
    decoded_hash = decoded_token(token)
    if !decoded_hash.empty?
      user_id = decoded_hash[0]["user_id"]
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: {error: "Access denied: not authorized."}, status: 401 unless logged_in?
  end
end
