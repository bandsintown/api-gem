module Bandsintown
  class Venue < Base
    
    attr_accessor :name, :bandsintown_id, :region, :city, :country, :latitude, :longitude
        
    def initialize(args={})
      @name            = args["name"]
      @bandsintown_url = args["url"]
      @bandsintown_id  = args["id"]
      @region          = args["region"]
      @city            = args["city"]
      @country         = args["country"]
      @latitude        = args["latitude"]
      @longitude       = args["longitude"]
    end
    
  end
end