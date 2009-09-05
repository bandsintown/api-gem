module Bandsintown
  class Connection
    attr_accessor :base_url
    
    def initialize(base_url)
      @base_url = base_url
    end
    
    def request(resource_path, method_path, args = {})
      request_url = "#{@base_url}/#{resource_path}/#{method_path}?#{encode(args.symbolize_keys)}"
      begin
        open(request_url).read
      rescue OpenURI::HTTPError => error_response
        error_response.io.read
      end
    end
    
    private 
    
    def encode(args = {})
      start_date = args.delete(:start_date)
      end_date   = args.delete(:end_date)
      if start_date && end_date
        start_date  = start_date.strftime("%Y-%m-%d") unless start_date.is_a?(String)
        end_date    = end_date.strftime("%Y-%m-%d")   unless end_date.is_a?(String)
        args[:date] = "#{start_date},#{end_date}"
      elsif args.has_key?(:date)
        args[:date] = args[:date].strftime("%Y-%m-%d") unless args[:date].is_a?(String)
      end
      args[:format] = "json"
      args.to_param
    end
    
  end
end