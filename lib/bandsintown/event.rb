module Bandsintown
  class Event < Base
    
    attr_accessor :bandsintown_id, :datetime, :ticket_url, :artists, :venue
    
    def self.search(args={})
      results = self.request_and_parse("search", args)
      events = []
      results.each { |event| events << Bandsintown::Event.build_from_json(event) }
      events
    end
    
    def self.resource_path()
      "events"
    end
    
    def self.build_from_json(json_hash)
      event                 = Bandsintown::Event.new()
      event.bandsintown_id  = json_hash["id"]
      event.bandsintown_url = json_hash["url"]
      event.datetime        = Time.parse(json_hash["datetime"])
      event.ticket_url      = json_hash["ticket_url"]
      event.venue           = Bandsintown::Venue.new(json_hash["venue"])
      event.artists         = []
      json_hash["artists"].each { |artist| event.artists << Bandsintown::Artist.new(artist) }
      event
    end
    
  end
end