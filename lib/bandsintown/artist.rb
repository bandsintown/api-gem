module Bandsintown
  class Artist < Base
    
    attr_accessor :name
        
    def initialize(args = {})
      @name = args["name"]
      @bandsintown_url = args["url"]
    end
    
  end
end