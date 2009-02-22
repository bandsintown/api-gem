require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Connection do
  before(:each) do
    @base_url = "http://api.bandsintown.com"
  end
  
  describe ".initialize(base_url)" do
    it "should set the base_url for the Connection" do
      Bandsintown::Connection.new(@base_url).base_url.should == @base_url
    end
  end
  
  describe ".agent" do
    it "should be an instance of WWW::Mechanize" do
      Bandsintown::Connection.agent.class.should == WWW::Mechanize
    end
    it "should not kill your computer" do
      Bandsintown::Connection.agent.max_history.should == 1
    end
  end
  
  describe ".request(url_path, args = {}, method = :get)" do
    before(:each) do
      @connection = Bandsintown::Connection.new(@base_url)
    end
    it "should convert args to url parameters" do
      args         = { :artists => ["Little Brother", "Joe Scudda"], :location => "Boston, MA", :radius => 10 }
      api_resource = "events"
      api_method   = "search"
      request_url  = "http://api.bandsintown.com/events/search?artists%5B%5D=Little+Brother&artists%5B%5D=Joe+Scudda&format=json&location=Boston%2C+MA&radius=10"  
      Bandsintown::Connection.agent.should_receive(:get).with(request_url)
      @connection.request(api_resource, api_method, args)  
    end
    it "should convert args[:start_date] and args[:end_date] to a single args[:date] parameter" do
      args         = { :start_date => "2009-01-01", :end_date => "2009-02-01" }
      api_resource = "events"
      api_method   = "search"
      request_url  = "http://api.bandsintown.com/events/search?date=2009-01-01%2C2009-02-01&format=json"
      Bandsintown::Connection.agent.should_receive(:get).with(request_url)
      @connection.request(api_resource, api_method, args)
    end
  end
  
end
