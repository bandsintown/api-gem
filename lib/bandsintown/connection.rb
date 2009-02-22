module Bandsintown
  class Connection
    attr_accessor :base_url
    
    class << self
      attr_accessor :agent
    end
    
    def initialize(base_url="http://localhost:3000")
      @base_url = base_url
    end
    
    def request(resource_path, method_path, args = {})
      request_url = "#{@base_url}/#{resource_path}/#{method_path}?#{encode(args.symbolize_keys)}"
      self.class.agent.get(request_url)
    end
    
    def self.agent
      return @agent unless @agent.nil?
      @agent = WWW::Mechanize.new()
      @agent.max_history = 1 # default is no limit, not so good...
      @agent
    end
    
    private 
    def encode(args = {})
      if args.has_key?(:end_date) && args.has_key?(:start_date)
        args[:date] = "#{args[:start_date]},#{args[:end_date]}"
        args.reject! { |k,v| k == :start_date || k == :end_date }
      end
      args[:format] = "json"
      args.to_param
    end
    
  end
end