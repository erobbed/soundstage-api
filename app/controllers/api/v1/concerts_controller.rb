class Api::V1::ConcertsController < ApplicationController
  skip_before_action :authorized

  def search
    artist = params[:artist]
    apikey = ENV['TICKETMASTER']
    events = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?keyword=#{artist}&apikey=#{apikey}"))

    @concerts = events['_embedded']['events'].map do |concert|
      seatmap = (!(concert['seatmap']) ? "N/A" : concert['seatmap']['staticUrl'])
      time = Time.parse(concert['dates']['start']['localTime']).strftime("%r")
      time[0] == "0" ? time=time[1..-1] : time
      # byebug
      Concert.find_or_create_by(
        name: concert['name'],
        date: Date.parse(concert['dates']['start']['localDate']).strftime("%b %d, %Y"),
        time: time,
        venue: concert['_embedded']['venues'][0]['name'],
        seatmap: seatmap,
        purchase: concert['url']
        #concert['_embedded']['venues'].each {|v\ v['location']} is long/long for each venue
      )
    end

    render json: {concerts: @concerts}
  end

end
