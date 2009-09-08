module Bandsintown
  class Artist < Base
    
    attr_accessor :name, :events
    
    def initialize(name, url = nil)
      @name = name
      @bandsintown_url = url || build_bandsintown_url
    end
    
    #Returns an array of Bandsintown::Event objects for each of the artist's upcoming events available through bandsintown.com.
    #See http://www.bandsintown.com/api/requests#artists-events for more information.
    #
    #====example:
    #   artist = Bandsintown::Artist.new("Little Brother")
    #   upcoming_little_brother_events = artist.events
    #
    def events
      return @events unless @events.blank?
      @events = self.class.request_and_parse("#{api_name}/events").map { |event| Bandsintown::Event.build_from_json(event) }
    end
    
    # name used in api requests. / and ? must be double escaped.
    #
    def api_name
      name = @name.dup
      name.gsub!('/', CGI.escape('/'))
      name.gsub!('?', CGI.escape('?'))
      URI.escape(name)
    end
    
    def self.resource_path
      "artists"
    end
    
    private
    
    def build_bandsintown_url
      name = @name.dup
      name.gsub!('&', 'And')
      name.gsub!('+', 'Plus')
      name = name.split.map { |w| w.capitalize }.join if name =~ /\s/
      name.gsub!('/', CGI.escape('/'))
      name.gsub!('?', CGI.escape('?'))
      "http://www.bandsintown.com/#{URI.escape(name)}"
    end
    
  end
end