module Bandsintown
  class Venue < Base
    attr_accessor :name, :bandsintown_id, :city, :region, :country, :latitude, :longitude, :events
    
    #Note - address and postalcode are not returned in API responses, but they are accepted when passing venue data to Bandsintown::Event.create.
    attr_accessor :address, :postalcode
    
    def initialize(bandsintown_id)
      @bandsintown_id = bandsintown_id
    end 
    
    #Returns an array of Bandsintown::Event objects for each of the venues's upcoming events available through bandsintown.com.
    #See http://www.bandsintown.com/api/requests#venues-events for more information.
    #
    #====example:
    #
    #   # using Paradise Rock Club in Boston, MA (bandsintown id 1700)
    #   venue = Bandsintown::Venue.new(1700)
    #   upcoming_paradise_events = venue.events
    #
    def events
      @events ||= self.class.request_and_parse(:get, "#{@bandsintown_id}/events").map { |event_hash| Bandsintown::Event.build_from_json(event_hash) }
    end 
    
    #Returns an array of Bandsintown::Venue objects matching the options passed.
    #See http://www.bandsintown.com/api/requests#venues-search for more information.
    #====options:
    # :query - a string to match the beginning of venue names
    # :location - a string with one of the following formats:
    #   * 'city, state' for United States and Canada
    #   * 'city, country' for other countries
    #   * 'latitude,longitude'
    #   * ip address - will use the location of the passed ip address
    #   * 'use_geoip' - will use the location of the ip address that made the request
    # :radius - a number in miles. API default is 25, maximum is 150.
    # :per_page - number of results per response.  Default is 5, maximum is 100.
    # :page - offset for paginated results.  API default is 1.
    #
    #====notes:
    #:query is required for this request, all other arguments are optional.
    #
    #====examples:
    #All venues (first page w/ 5 results) with name beginning with 'House of Blues':
    #   Bandsintown::Venue.search(:query => 'House of Blues')
    #
    #All venues (first page w/ 5 results) with name beginning with 'House of' within 25 miles of San Diego, CA:
    #   Bandsintown::Venue.search(:query => "House of", :location => "San Diego, CA")
    # 
    #Second page of all venues near the request's ip address with name beginning with "Club" and 100 results per page:
    #   Bandsintown::Venue.search(:query => "Club", :per_page => 100, :page => 2, :location => "use_geoip")
    #
    def self.search(options = {})
      self.request_and_parse(:get, "search", options).map { |venue_hash| Bandsintown::Venue.build_from_json(venue_hash) }
    end
    
    def self.resource_path
      "venues"
    end
     
    def self.build_from_json(args={})
      Bandsintown::Venue.new(args['id']).tap do |v|
        v.name            = args["name"]
        v.bandsintown_url = args["url"]
        v.bandsintown_id  = args["id"]
        v.region          = args["region"]
        v.city            = args["city"]
        v.country         = args["country"]
        v.latitude        = args["latitude"]
        v.longitude       = args["longitude"]
      end
    end
  end
end