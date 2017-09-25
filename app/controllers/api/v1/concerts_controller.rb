class Api::V1::ConcertsController < ApplicationController
  skip_before_action :authorized

  def search
    artist = params[:artist]
    a = Artist.find_or_create_by(name: params[:artist])
    @concerts = a.concerts
    # byebug

    render json: {concerts: @concerts}
  end

end
