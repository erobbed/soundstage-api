class Api::V1::ConcertsController < ApplicationController
  skip_before_action :authorized

  def search
    artist = params[:artist]
    a = Artist.find_or_create_by(name: params[:artist])
    @concerts = a.concerts
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

#pass in curent location lat and long to index
#select only upcoming concerts that are less than a week away
#sort by date
#if dates are equal, sort by distance using distance method

  def index
    lat = request.headers['lat'].to_f
    long = request.headers['long'].to_f

    @user = User.find(current_user)
    @concerts = @user.artists.map do |a|
      a.concerts.select{|c| Date.parse(c.date) > Date.today && Date.parse(c.date) < (Date.today + 7)}
    end
    @concerts = @concerts.flatten.sort  do |concert1, concert2|
      order = Date.parse(concert1.date) <=> Date.parse(concert2.date)
      if order != 0
        order
      else
        concert1.distance(lat, long) <=> concert2.distance(lat, long)
      end
    end
    render json: {concerts: @concerts}
  end

end
