module Bandsintown
  class Artist < Base
    
    attr_accessor :name, :mbid, :events, :upcoming_events_count
    
    def initialize(options = {})
      @name = options[:name]
      @mbid = options[:mbid]
      @bandsintown_url = options[:url] || build_bandsintown_url
    end
    
    #Returns an array of Bandsintown::Event objects for each of the artist's upcoming events available through bandsintown.com.
    #See http://www.bandsintown.com/api/requests#artists-events for more information.
    #Can be used with either artist name or mbid (music brainz id).
    #====example:
    #   # using artist name
    #   artist = Bandsintown::Artist.new(:name => "Little Brother")
    #   upcoming_little_brother_events = artist.events
    #
    #   # using mbid for Little Brother
    #   artist = Bandsintown::Artist.new(:mbid => "b929c0c9-5de0-4d87-8eb9-365ad1725629")
    #   upcoming_little_brother_events = artist.events
    #
    def events
      return @events unless @events.blank?
      @events = self.class.request_and_parse(:get, "#{api_name}/events").map { |event| Bandsintown::Event.build_from_json(event) }
    end
    
    # Used in api requests as the RESTful resource id for artists (http://api.bandsintown.com/artists/id/method).
    # If @name is not nil, it will be URI escaped to generate the api_name.  '/' and '?' must be double escaped.
    # If @name is nil, @mbid is used with 'mbid_' prefixed.
    #
    def api_name
      if @name
        name = @name.dup
        name.gsub!('/', CGI.escape('/'))
        name.gsub!('?', CGI.escape('?'))
        URI.escape(name)
      else
        "mbid_#{@mbid}"
      end
    end

    #Returns true if there is at least 1 upcoming event for the artist, or false if there are 0 upcoming events for the artist.
    #Should only be used for artists requested using Bandsintown::Artist.get, or with events already loaded, otherwise an error will be raised.
    #====example:
    #   # using .get method
    #   artist = Bandsintown::Artist.get(:name => "Little Brother")
    #   artist_on_tour = artist.on_tour?
    #
    #   # using .initialize and .events methods
    #   artist = Bandsintown::Artist.get(:name => "Little Brother")
    #   events = artist.events
    #   artist_on_tour = artist.on_tour?
    #
    def on_tour?
      (@upcoming_events_count || @events.size) > 0
    end
    
    #This method is used to create an artist on bandsintown.com.
    #If successful, it will return a Bandsintown::Artist object with the same data as a Bandsintown::Artist.get response.
    #If you attempt to create an artist that already exists, the existing artist will be returned.
    #See http://www.bandsintown.com/api/requests#artists-create for more information.
    #
    #====options
    # * :name - artist name
    # * :mbid - music brainz id
    # * :myspace_url - url
    # * :website - url
    #
    #====notes
    # * :name is required, all other arguments are optional.
    # * :mbid is uuid format, for example : "abcd1234-abcd-1234-abcd-12345678abcd"
    # * :myspace_url must be from either myspace.com or www.myspace.com 
    #
    #====examples
    #Create an artist with full data:
    #   Bandsintown::Artist.create(:name => "A New Artist", :mbid => "abcd1234-abcd-1234-abcd-12345678abcd", :myspace_url => "http://www.myspace.com/anewartist", :website => "http://www.a-new-artist.com")
    #
    #Create an artist with name only:
    #   Bandsintown::Artist.create(:name => "A New Artist")
    #
    def self.create(options)
      build_from_json(self.request_and_parse(:post, "", :artist => options))
    end
    
    #This is used to cancel an event on Bandsintown for a single artist.  If you want to cancel the entire event (all artists), use Bandsintown::Event#cancel.
    #If successful, this method will always return a status message.
    #Unless you have a trusted app_id, events added or removed through the API will need to be approved before the changes are seen live.
    #Contact Bandsintown if you are often adding events and would like a trusted account.
    #See http://www.bandsintown.com/api/requests#artists-cancel-event for more information.
    #
    #====examples:
    #Cancel an artist's event with a non-trusted app_id:
    #   artist = Bandsintown::Artist.new(:name => "Little Brother")
    #   event_id = 12345
    #   artist.cancel_event(event_id)
    #   => "Event successfully cancelled (Pending Approval)"
    #
    #Cancel an artist's event with a trusted app_id:
    #   artist = Bandsintown::Artist.new(:name => "Little Brother")
    #   event_id = 12345
    #   artist.cancel_event(event_id)
    #   => "Event successfully cancelled"
    #
    def cancel_event(event_id)
      raise StandardError.new("event cancellation requires a bandsintown_id") if event_id.blank?
      response = self.class.request_and_parse(:post, "#{api_name}/events/#{event_id}/cancel")
      response["message"]
    end
    
    #Returns a Bandsintown::Artist object with basic information for a single artist, including the number of upcoming events. 
    #Useful in determining if an artist is on tour without requesting the event data.
    #See http://www.bandsintown.com/api/requests#artists-get for more information.
    #Can be used with either artist name or mbid (music brainz id).
    #====example:
    #   # using artist name
    #   artist = Bandsintown::Artist.get(:name => "Little Brother")
    #
    #   # using mbid for Little Brother
    #   artist = Bandsintown::Artist.get(:mbid => "b929c0c9-5de0-4d87-8eb9-365ad1725629")
    #
    def self.get(options = {})
      request_url = Bandsintown::Artist.new(options).api_name
      build_from_json(request_and_parse(:get, request_url))
    end
    
    def self.build_from_json(json_hash)
      Bandsintown::Artist.new({}).tap do |artist|
        artist.name = json_hash['name']
        artist.mbid = json_hash['mbid']
        artist.bandsintown_url = json_hash['url']
        artist.upcoming_events_count = json_hash['upcoming_events_count']
      end
    end
    
    def self.resource_path
      "artists"
    end
    
    private
    
    def build_bandsintown_url
      if @name
        name = @name.dup
        name.gsub!('&', 'And')
        name.gsub!('+', 'Plus')
        name = name.split.map { |w| w.capitalize }.join if name =~ /\s/
        name.gsub!('/', CGI.escape('/'))
        name.gsub!('?', CGI.escape('?'))
        "http://www.bandsintown.com/#{URI.escape(name)}"
      else
        "http://www.bandsintown.com/mbid_#{@mbid}"
      end
    end
  end
end