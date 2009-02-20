module Bandsintown
  class Event < Base
    
    def self.search(args={})
      results = self.request_and_parse("search", args)
    end
    
    def self.resource_path()
      "events/"
    end
    
  end
end