module Bandsintown
  class Base
  
    def self.request(api_method, args={})
      self.connection.request(self.resource_path, api_method, args)
    end
  
    def self.connection()
      #@connection ||= Bandsintown::Connection.new("http://api.bandsintown.com/")
      @connection ||= Bandsintown::Connection.new("http://localhost:3000/api")
    end
    
    def self.parse(response)
      
    end
    
    def self.request_and_parse(api_method, args={})
      parse(request(api_method, args))
    end
  
  end
end