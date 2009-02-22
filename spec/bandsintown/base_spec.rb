require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Base do
  
  describe ".connection" do
    it "should be an instance of Bandsintown::Connection" do
      Bandsintown::Base.connection.class.should == Bandsintown::Connection
    end
    it "should be cached" do
      Bandsintown::Base.connection.should === Bandsintown::Base.connection
    end
  end
  
  describe ".request(api_method, args={})" do
    it "should make a request to the connection url" do
      resource_path = "events"
      method        = "search"
      args          = { :arg => "value" }
      Bandsintown::Base.stub!(:resource_path).and_return(resource_path)
      Bandsintown::Base.connection.should_receive(:request).with(resource_path, method, args)
      Bandsintown::Base.request(method, args)
    end
  end
  
  describe ".parse(response)" do
    it "should check the response for errors" do
      response = mock("HTTP get response", :body => "")
      parsed   = mock("parsed json")
      JSON.stub!(:parse).and_return(parsed)
      Bandsintown::Base.should_receive(:check_for_errors).with(parsed)
      Bandsintown::Base.parse(response)
    end
    it "should convert the response from JSON format and return it" do
      response = mock("HTTP get response", :body => "{\"ok\": 123}")
      Bandsintown::Base.parse(response).should == { "ok" => 123 }
    end
  end
  
  describe ".request_and_parse(api_method, args={})" do
    before(:each) do
      @resource_path = "events"
      @method        = "search"
      @args          = { :arg => "value" }
      Bandsintown::Base.stub!(:resource_path).and_return(@resource_path)
      @response = mock("WWW::Mechanize response")
    end
    it "should make a request" do
      Bandsintown::Base.should_receive(:request).with(@method, @args).and_return(@response)
      Bandsintown::Base.stub!(:parse)
      Bandsintown::Base.request_and_parse(@method, @args)
    end
    it "should parse the response" do
      Bandsintown::Base.stub!(:request).and_return(@response)
      Bandsintown::Base.should_receive(:parse).with(@response)
      Bandsintown::Base.request_and_parse(@method, @args)
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
  
end
