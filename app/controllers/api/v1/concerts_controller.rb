class Api::V1::ConcertsController < ApplicationController
  skip_before_action :authorized

  def search
    artist = params[:artist]
    apikey = ENV['TICKETMASTER']
    events = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?keyword=#{artist}&apikey=#{apikey}"))

    @concerts = events['_embedded']['events'].map do |concert|
      seatmap = (!(concert['seatmap']) ? "N/A" : concert['seatmap']['staticUrl'])
      byebug
      Concert.find_or_create_by(
        name: concert['name'],
        date: Date.parse(concert['dates']['start']['localDate']),
        time: concert['dates']['start']['localTime'],
        venue: concert['_embedded']['venues'][0]['name'],
        seatmap: seatmap,
        purchase: concert['url']
      )
    end

    render json: {concerts: @concerts}

    #events['_embedded']['events'] = [array]
    #keys for each:
    # ['dates'] has ['localTime'] and ['localDate']
    # ['seatmap']['staticURL']
    # ['_embedded']['venues'] = [array], map for each and get ['name']
    #concert.artists
  end
end
