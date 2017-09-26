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
    @user = User.find(current_user)
    @concert = Concert.find(params[:concert])
    if !(@user.concerts.include?(@concert))
      @user.concerts << @concert
    end
    render json: {concerts: @user.concerts }
  end

  def remove
    @user = User.find(current_user)
    @concert = Concert.find(params[:concert])
    if @user.concerts.include?(@concert)
      @user.concerts.delete(@concert.id)
    end
    render json: {concerts: @user.concerts }
  end

end
