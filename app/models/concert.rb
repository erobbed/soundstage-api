require 'geokit'

class Concert < ApplicationRecord
  has_many :user_concerts
  has_many :users, through: :user_concerts
  has_many :artist_concerts
  has_many :artists, through: :artist_concerts

  def distance(lat, long)
    current_location = Geokit::LatLng.new(lat, long)
    destination = "#{self.lat}, #{self.long}"
    current_location.distance_to(destination)
  end

  def self.fetch(artist)
    apikey = ENV['TICKETMASTER']
    events = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?keyword=#{artist.name}&apikey=#{apikey}"))

    if events['_embedded']
      @filteredconcerts = events['_embedded']['events'].select do |concert|
        concert['_embedded']['venues'][0].keys.include?('location')
      end
      @concerts = @filteredconcerts.map do |concert|
        seatmap = (!(concert['seatmap']) ? "N/A" : concert['seatmap']['staticUrl'])
        time = concert['dates']['start']
        if time.keys.include?("localTime")
          time = Time.parse(time['localTime']).strftime("%r")
          time[0] == "0" ? time=time[1...-6] + time[-3..-1] : time=time[0...-6] + time[-3..-1]
        else
          time = "N/A"
        end
        province = (concert['_embedded']['venues'][0]['state'] ? concert['_embedded']['venues'][0]['state']['name'] : concert['_embedded']['venues'][0]['country']['name'])
        self.find_or_create_by(
          name: concert['name'],
          date: Date.parse(concert['dates']['start']['localDate']).strftime("%b %d, %Y"),
          time: time,
          venue: concert['_embedded']['venues'][0]['name'],
          lat: concert['_embedded']['venues'][0]['location']['latitude'],
          long: concert['_embedded']['venues'][0]['location']['longitude'],
          seatmap: seatmap,
          purchase: concert['url'],
          city: concert['_embedded']['venues'][0]['city']['name'],
          state: province
        )
      end
      artist.concerts = @concerts
      artist.save
      artist
    else
      artist
    end
  end

end
