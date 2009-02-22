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
    it "should build Bandsintown::Error objects if there was a problem with the request"
    it "should build Bandsintown objects from the response if the request was ok"
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
  
end
