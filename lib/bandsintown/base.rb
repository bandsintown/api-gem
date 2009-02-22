module Bandsintown
  class Base
  
    attr_accessor :bandsintown_url
    
    def self.request(api_method, args={})
      self.connection.request(self.resource_path, api_method, args)
    end
  
    def self.connection()
      #@connection ||= Bandsintown::Connection.new("http://api.bandsintown.com/")
      @connection ||= Bandsintown::Connection.new("http://localhost:3000/api")
    end
    
    def self.parse(response)
      json = JSON.parse(response.body)
      check_for_errors(json)
      json
    end
    
    def self.check_for_errors(json)
      if json.is_a?(Hash) && json.has_key?("errors")
        raise Bandsintown::APIError.new(json["errors"].join(", "))
      end
    end
    
    def self.request_and_parse(api_method, args={})
      parse(request(api_method, args))
    end
  
  end
end