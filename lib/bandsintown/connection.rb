module Bandsintown
  class Connection
    attr_accessor :base_url, :client
    
    def initialize(base_url)
      @base_url = base_url
    end
    
    def get(resource_path, method_path, params = {})
      request_url = File.join([@base_url, resource_path, method_path].reject(&:blank?)) + "?" + encode(params.symbolize_keys)
      begin
        RestClient.get(request_url)
      rescue RestClient::ResourceNotFound => error_response
        error_response.response
      end
    end
    
    def post(resource_path, method_path, body = {})
      request_url = File.join([@base_url, resource_path, method_path].reject(&:blank?)) + "?" + encode({})
      begin
        RestClient.post(request_url, body.to_json, :content_type => :json, :accept => :json)
      rescue RestClient::ResourceNotFound => error_response
        error_response.response
      end
    end
    
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
      args[:app_id] = Bandsintown.app_id
      args.to_param
    end
    
  end
end