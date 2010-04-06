module Bandsintown
  class Event < Base
    
    attr_accessor :bandsintown_id, :datetime, :ticket_url, :artists, :venue, :status, :ticket_status, :on_sale_datetime
    
    def tickets_available?
      ticket_status == "available"
    end
    
    #Returns an array of Bandsintown::Event objects matching the options passed.
    #See http://www.bandsintown.com/api/requests#events-search for more information.
    #====options:
    # :artists - an array of artist names or music brainz id's (formatted as 'mbid_<id>').
    # :location - a string with one of the following formats:
    #   * 'city, state' for United States and Canada
    #   * 'city, country' for other countries
    #   * 'latitude,longitude'
    #   * ip address - will use the location of the passed ip address
    #   * 'use_geoip' - will use the location of the ip address that made the request
    # :radius - a number in miles. API default is 25, maximum is 150.
    # :date - use one of the following formats:
    #   * 'upcoming' - all upcoming dates, this is the API default.
    #   * single date
    #     * String formatted 'yyyy-mm-dd'
    #     * Time/Date/DateTime object (anything that responds to strftime)
    #   * date range
    #     * String formatted 'yyyy-mm-dd,yyyy-mm-dd'
    #     * alternatively use :start_date and :end_date with 'yyyy-mm-dd' Strings or Time/Date/DateTime objects.
    # :per_page - number of results per response.  API default is 50, maximum is 100.
    # :page - offset for paginated results.  API default is 1.
    #
    #====notes:
    #:location or :artists is required for this request, all other arguments are optional.
    #
    #====examples:
    #All concerts (first page w/ 50 results) in New York City for The Roots or Slum Village within the next 30 days (using Date objects):
    #   Bandsintown::Event.search(:location => "New York, NY", :artists => ["The Roots", "Slum Village"], :start_date => Date.today, :end_date => Date.today + 30)
    #
    #All concerts (first page w/ 50 results) on Dec 31 2009 (using formatted date string) within 100 miles of London:
    #   Bandsintown::Event.search(:location => "London, UK", :radius => 100, :date => "2009-12-31")
    # 
    #Second page of all concerts near the request's ip address within in the next month, using Time objects and 100 results per page:
    #   Bandsintown::Event.search(:start_date => Time.now, :end_date => 1.month.from_now, :per_page => 100, :page => 2, :location => "use_geoip")
    #
    def self.search(options = {})
      events = []
      self.request_and_parse("search", options).each { |event| events << Bandsintown::Event.build_from_json(event) }
      events
    end
    
    #Returns an array of Bandsintown::Event objects for all events added to Bandsintown within the last day (updated at 12:00 PM EST daily).
    #See http://www.bandsintown.com/api/requests#events-daily for more information.
    #
    def self.daily
      events = []
      self.request_and_parse("daily").each { |event| events << Bandsintown::Event.build_from_json(event) }
      events
    end
    
    #Returns an array of Bandsintown::Event objects matching the options passed.
    #See http://www.bandsintown.com/api/requests#events-recommended for more information.
    #====options:
    #All options are the same as Bandsintown::Event.search with the following extra option:
    # :only_recs - boolean for whether to include events with the artists from the :artists option. default is false.
    #
    #====notes:
    #:location and :artists are required for this request, all other arguments are optional.
    #
    #====examples:
    #All concerts (first page w/ 50 results) in Boston, MA recommended for fans of Metallica, including Metallica concerts
    #   Bandsintown::Event.recommended(:location => "Boston, MA", :artists => ["Metallica"])
    #
    #All concerts (first page w/ 50 results) on Dec 31 2009 within 100 miles of London recommended for fans of Usher and Lil Wayne, excluding Usher and Lil Wayne concerts
    #   Bandsintown::Event.recommended(:location => "London, UK", :radius => 100, :date => "2009-12-31", :artists => ["Usher", "Lil Wayne"], :only_recs => true)
    #
    def self.recommended(options = {})
      events = []
      self.request_and_parse("recommended", options).each { |event| events << Bandsintown::Event.build_from_json(event) }
      events
    end
    
    #Returns an array of Bandsintown::Event objects going on sale in the next week, and matching the options passed.
    #See http://www.bandsintown.com/api/requests#on-sale-soon for more information.
    #====options:
    #:location, :radius, and :date options are supported.  See the Bandsintown::Event.search documentation for accepted formats.
    #
    #====notes:
    #If :location is given without :radius, a default radius of 25 miles will be used.
    #
    #====examples:
    #All upcoming concerts within 10 miles of Boston, MA, with tickets going on sale in the next week:
    #   Bandsintown::Event.on_sale_soon(:location => "Boston, MA", :radius => 10)
    #
    #All concerts happening between Mar 01 2010 and Mar 15 2010 within 25 miles of London, UK, with tickets going on sale in the next week:
    #   Bandsintown::Event.on_sale_soon(:location => "London, UK", :start_date => "2010-03-01", :end_date => "2010-03-15")
    #
    def self.on_sale_soon(options = {})
      events = []
      self.request_and_parse("on_sale_soon", options).each { |event| events << Bandsintown::Event.build_from_json(event) }
      events
    end
    
    def self.resource_path
      "events"
    end
    
    def self.build_from_json(json_hash)
      event                  = Bandsintown::Event.new
      event.bandsintown_id   = json_hash["id"]
      event.bandsintown_url  = json_hash["url"]
      event.datetime         = Time.parse(json_hash["datetime"])
      event.ticket_url       = json_hash["ticket_url"]
      event.status           = json_hash["status"]
      event.ticket_status    = json_hash["ticket_status"]
      event.on_sale_datetime = Time.parse(json_hash["on_sale_datetime"]) rescue nil
      event.venue            = Bandsintown::Venue.build_from_json(json_hash["venue"])
      event.artists          = json_hash["artists"].map { |artist| Bandsintown::Artist.new(artist.symbolize_keys) }
      event
    end
    
  end
end