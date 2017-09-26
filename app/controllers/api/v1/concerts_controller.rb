class Api::V1::ConcertsController < ApplicationController
  skip_before_action :authorized

  def search
    artist = params[:artist]
    a = Artist.find_or_create_by(name: params[:artist])
    @concerts = a.concerts
    # byebug

    render json: {concerts: @concerts}
  end

  def show
    @user = User.find(current_user)
    render json: {concerts: @user.concerts }
  end

  def add
    #add concert method here
  end

end
