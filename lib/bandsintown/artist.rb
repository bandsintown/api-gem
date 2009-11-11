module Bandsintown
  class Artist < Base
    
    attr_accessor :name, :bandsintown_url, :mbid, :events
    
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
      @events = self.class.request_and_parse("#{api_name}/events").map { |event| Bandsintown::Event.build_from_json(event) }
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