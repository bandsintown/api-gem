module Bandsintown
  class Event < Base
    
    module CreationHelpers
      ISO_8601_FORMAT = "%Y-%m-%dT%H:%M:%S"
      
      def self.included(klass)
        klass.extend(ClassMethods)
      end
      
      module ClassMethods
        def parse_datetime(datetime)
          case datetime
          when Time, DateTime then datetime.strftime(ISO_8601_FORMAT)
          when Date then (datetime + 19.hours).strftime(ISO_8601_FORMAT)
          else datetime
          end
        end
        
        def parse_venue(venue_data)
          hash = venue_data.to_hash
          bandsintown_id = hash[:id] || hash[:bandsintown_id]
          venue = if bandsintown_id.blank?
            {
              :name => hash[:name], 
              :city => hash[:city], 
              :region => hash[:region],
              :country => hash[:country], 
              :latitude => hash[:latitude],
              :longitude => hash[:longitude]
            }
          else
            { :id => bandsintown_id }
          end
          venue.reject { |k,v| v.blank? }
        end
        
        def parse_artists(artist_data)
          artist_data.map do |artist|
            if artist.is_a?(String)
              { :name => artist }
            else
              hash = artist.to_hash
              hash[:mbid].blank? ? { :name => hash[:name] } : { :mbid => hash[:mbid] }
            end
          end          
        end
      end
    end
    
    include CreationHelpers
    
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
      self.request_and_parse(:get, "search", options).each { |event| events << Bandsintown::Event.build_from_json(event) }
      events
    end
    
    #Returns an array of Bandsintown::Event objects for all events added to Bandsintown within the last day (updated at 12:00 PM EST daily).
    #See http://www.bandsintown.com/api/requests#events-daily for more information.
    #
    def self.daily
      events = []
      self.request_and_parse(:get, "daily").each { |event| events << Bandsintown::Event.build_from_json(event) }
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
      self.request_and_parse(:get, "recommended", options).each { |event| events << Bandsintown::Event.build_from_json(event) }
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
      self.request_and_parse(:get, "on_sale_soon", options).each { |event| events << Bandsintown::Event.build_from_json(event) }
      events
    end
    
    # TODO: better documentation for this method
    #Allows you to submit events to Bandsintown.  If submitted successfully, a message will be returned: "Event submitted successfully (pending approval)".  
    #Once the event has been approved by Bandsintown it will appear in API requests and on www.bandsintown.com.
    #If your app_id has been approved as a trusted source, the event is automatically added to bandsintown and this method
    #will return a fully populated Bandsintown::Event object.
    #See http://www.bandsintown.com/api/requests#events-create for more information.
    #===options:
    #   :artists - an Array of artist data with each element in one of the following formats:
    #     * artist name String
    #     * Hash of { :name => artist name } or { :mbid => music brainz id }
    #     * Bandsintown::Artist object with :mbid or :name
    #   :datetime - use one of the following formats:
    #     * String in ISO-8601 format: '2010-06-01T19:30:00'
    #     * Any object that responds to strftime (Date/Time/DateTime)
    #   :venue - use one of the following formats:
    #     * Hash of { :id => bandsintown id } or location data (:name, :city, :region, :country, :latitude, :longitude)
    #       * :name, :city, :region, :country are required for venues in the United States
    #       * :name, :city, :country are required for venues outside the United States
    #       * :latitude and :longitude are always optional
    #     * Bandsintown::Venue object
    #   :on_sale_datetime - use the same formats as :datetime
    #   :ticket_url - string with a link to where you can buy tickets to the event
    #   :ticket_price - a number or string with ticket price
    #
    #===notes:
    #   * :artists, :datetime, and :venue are required, all other options are optional.
    #   * If :mbid and :name are available in an artist Hash or Bandsintown::Artist, :mbid is used first.
    #   * If :bandsintown_id and location data are given in a venue Hash or Bandsintown::Venue, :bandsintown_id is used first.
    #
    #===examples:
    #Create an event for Evidence and Alchemist at House of Blues - San Diego on June 1st, 2010 using Bandsintown::Artist and Bandsintown::Venue:
    #   evidence = Bandsintown::Artist.new(:name => "Evidence")
    #   alchemist = Bandsintown::Artist.new(:name => "Alchemist")
    #   venue = Bandsintown::Venue.new(727861) # id for House of Blues - San Diego
    #   Bandsintown::Event.create(:artists => [evidence, alchemist], :venue => venue, :datetime => "2010-06-01T19:30:00")
    #   # => "Event submitted successfully (pending approval)"
    #
    def self.create(options = {})
      event_data = {
        :artists          => self.parse_artists(options[:artists]),
        :venue            => self.parse_venue(options[:venue]),
        :datetime         => self.parse_datetime(options[:datetime]),
        :on_sale_datetime => self.parse_datetime(options[:on_sale_datetime]),
        :ticket_url       => options[:ticket_url],
        :ticket_price     => options[:ticket_price]
      }.reject { |k,v| v.blank? }
      
      response = self.request_and_parse(:post, "create", :event => event_data)
      
      if response.key?("message")
        response["message"]
      else
        Bandsintown::Event.build_from_json(response["event"])
      end
    end
    
    def self.resource_path
      "events"
    end
    
    def self.build_from_json(json_hash)
      returning Bandsintown::Event.new do |event|
        event.bandsintown_id   = json_hash["id"]
        event.bandsintown_url  = json_hash["url"]
        event.datetime         = Time.parse(json_hash["datetime"])
        event.ticket_url       = json_hash["ticket_url"]
        event.status           = json_hash["status"]
        event.ticket_status    = json_hash["ticket_status"]
        event.on_sale_datetime = Time.parse(json_hash["on_sale_datetime"]) rescue nil
        event.venue            = Bandsintown::Venue.build_from_json(json_hash["venue"])
        event.artists          = json_hash["artists"].map { |artist| Bandsintown::Artist.new(artist.symbolize_keys) }
      end
    end

    
  end
end