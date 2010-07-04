require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Base do
  
  describe ".connection" do
    it "should be an instance of Bandsintown::Connection" do
      Bandsintown::Base.connection.class.should == Bandsintown::Connection
    end
    it "should be memoized" do
      Bandsintown::Base.connection.should === Bandsintown::Base.connection
    end
    it "should use http://api.bandsintown.com as the base url" do
      Bandsintown::Base.connection.base_url.should == "http://api.bandsintown.com"
    end
  end
  
  describe ".request(http_method, api_method, params={})" do
    before(:each) do
      Bandsintown::Base.stub!(:resource_path).and_return("events")
    end
    it "should make a GET request to the connection url using api_method and params when http_method == :get" do
      http_method = :get 
      api_method = "search"
      params = { :arg => "value" }
      Bandsintown::Base.stub!(:resource_path).and_return("events")
      Bandsintown::Base.connection.should_receive(:get).with("events", api_method, params).and_return("response")
      Bandsintown::Base.request(http_method, api_method, params).should == "response"
    end
    it "should make a POST request to the connection url using api_method and params when http_method == :post" do
      http_method = :post 
      api_method = "create"
      params = { :arg => "value" }
      Bandsintown::Base.connection.should_receive(:post).with("events", api_method, params).and_return("response")
      Bandsintown::Base.request(http_method, api_method, params).should == "response"
    end
    it "should raise an error if http_method is not :get or :post" do
      http_method = :delete
      api_method = "search"
      params = { :arg => "value" }
      lambda { Bandsintown::Base.request(http_method, api_method, params) }.should raise_error(ArgumentError, "only :get and :post requests are supported")
    end
  end
  
  describe ".parse(response)" do
    it "should check the response for errors" do
      response = "response"
      parsed = mock("parsed json")
      JSON.stub!(:parse).and_return(parsed)
      Bandsintown::Base.should_receive(:check_for_errors).with(parsed)
      Bandsintown::Base.parse(response)
    end
    it "should convert the response from JSON format and return it" do
      response = "{\"ok\": 123}\n"
      Bandsintown::Base.parse(response).should == { "ok" => 123 }
    end
  end
  
  describe ".request_and_parse(http_method, api_method, params={})" do
    before(:each) do
      @http_method = :get 
      @api_method = "search"
      @params = { :arg => "value" }
      Bandsintown::Base.stub!(:resource_path).and_return("events")
      @response = mock("HTTP response body")
    end
    it "should make a request with the http method, api method, and params" do
      Bandsintown::Base.should_receive(:request).with(@http_method, @api_method, @params).and_return(@response)
      Bandsintown::Base.stub!(:parse)
      Bandsintown::Base.request_and_parse(@http_method, @api_method, @params)
    end
    it "should parse the response" do
      Bandsintown::Base.stub!(:request).and_return(@response)
      Bandsintown::Base.should_receive(:parse).with(@response)
      Bandsintown::Base.request_and_parse(@http_method, @api_method, @params)
    end
  end
  
  describe ".check_for_errors(json)" do
    it "should raise an APIError containing all the error messages from the API, if the response has error messages" do
      json = { "errors" => [ "location or artists param is required", "invalid date format" ] }
      lambda { Bandsintown::Base.check_for_errors(json) }.should raise_error(Bandsintown::APIError, "location or artists param is required, invalid date format")
    end
    it "should not raise an error if the response doesn't have error messages" do
      json = { "something" => "thats not an error" }
      lambda { Bandsintown::Base.check_for_errors(json) }.should_not raise_error
    end
  end
  
  
  describe "#to_hash" do
    it "should return a hash from non-blank instance variables" do
      class Bandsintown::TestObject < Bandsintown::Base; attr_accessor :one, :two, :three; end
      test_object = Bandsintown::TestObject.new
      test_object.one = '1'
      test_object.two = 2
      test_object.three = ''
      test_object.to_hash.should == { :one => '1', :two => 2 }
    end
  end
end
