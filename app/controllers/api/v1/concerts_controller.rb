class Api::V1::ConcertsController < ApplicationController
  skip_before_action :authorized

  def search
    artist = params[:artist]
    apikey = ENV['TICKETMASTER']
    events = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?keyword=#{artist}&apikey=#{apikey}"))
    byebug

    # concerts = events['_embedded']['events'].each do |concert|
    #   Concert.create(
    #     name: concert['name'],
    #     date: concert['dates']['localDate'],
    #     time: concert['dates']['localTime'],
    #     venue: concert['_embedded']['venues'][0]['name'],
    #     seatmap: concert['seatmap']['staticURL'],
    #     purchase: concert['url']
    #   )
    # end

    #events['_embedded']['events'] = [array]
    #keys for each:
    # ['dates'] has ['localTime'] and ['localDate']
    # ['seatmap']['staticURL']
    # ['_embedded']['venues'] = [array], map for each and get ['name']
    #concert.artists
  end
end
