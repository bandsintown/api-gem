require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Connection do
  before(:each) do
    Bandsintown.app_id = 'YOUR_APP_ID'
    @base_url = "http://api.bandsintown.com"
  end
  
  describe ".initialize(base_url)" do
    it "should set the base_url for the Connection" do
      Bandsintown::Connection.new(@base_url).base_url.should == @base_url
    end
  end
  
  describe ".request(url_path, args = {}, method = :get)" do
    before(:each) do
      @connection = Bandsintown::Connection.new(@base_url)
      @response = StringIO.new("response")
      @connection.stub!(:open).and_return(@response)
      @api_resource = "events"
      @api_method = "search"
    end
    it "should convert args to url parameters when making a request" do
      args         = { :artists => ["Little Brother", "Joe Scudda"], :location => "Boston, MA", :radius => 10 }
      request_url  = "http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&artists%5B%5D=Little+Brother&artists%5B%5D=Joe+Scudda&format=json&location=Boston%2C+MA&radius=10"  
      @connection.should_receive(:open).with(request_url).and_return(@response)
      @connection.request(@api_resource, @api_method, args)  
    end
    it "should convert args[:start_date] and args[:end_date] to a single args[:date] parameter when making a request" do
      args         = { :start_date => "2009-01-01", :end_date => "2009-02-01" }
      request_url  = "http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&date=2009-01-01%2C2009-02-01&format=json"
      @connection.should_receive(:open).with(request_url).and_return(@response)
      @connection.request(@api_resource, @api_method, args)
    end
    it "should allow date to be a Time object" do
      args = { :date => Time.now.beginning_of_day }
      request_url = "http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&date=#{Time.now.beginning_of_day.strftime("%Y-%m-%d")}&format=json"
      @connection.should_receive(:open).with(request_url).and_return(@response)
      @connection.request(@api_resource, @api_method, args)
    end
    it "should allow date to be a Date object" do
      args = { :date => Date.today }
      request_url = "http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&date=#{Date.today.strftime("%Y-%m-%d")}&format=json"
      @connection.should_receive(:open).with(request_url).and_return(@response)
      @connection.request(@api_resource, @api_method, args)
    end
    it "should allow date to be a String object" do
      args = { :date => "2009-01-01" }
      request_url = "http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&date=2009-01-01&format=json"
      @connection.should_receive(:open).with(request_url).and_return(@response)
      @connection.request(@api_resource, @api_method, args)
    end
    it "should allow start date and end date to be Time objects" do
      args         = { :start_date => 1.week.ago, :end_date => 1.week.from_now }
      request_url  = "http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&date=#{1.week.ago.strftime('%Y-%m-%d')}%2C#{1.week.from_now.strftime('%Y-%m-%d')}&format=json"
      @connection.should_receive(:open).with(request_url).and_return(@response)
      @connection.request(@api_resource, @api_method, args)
    end
    it "should allow start date and end date to be Date objects" do
      args         = { :start_date => 1.week.ago.to_date, :end_date => 1.week.from_now.to_date }
      request_url  = "http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&date=#{1.week.ago.to_date.strftime('%Y-%m-%d')}%2C#{1.week.from_now.to_date.strftime('%Y-%m-%d')}&format=json"
      @connection.should_receive(:open).with(request_url).and_return(@response)
      @connection.request(@api_resource, @api_method, args)
    end
    it "should allow start date and end date to be String objects" do
      args         = { :start_date => "2009-01-01", :end_date => "2009-02-01" }
      request_url  = "http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&date=2009-01-01%2C2009-02-01&format=json"
      @connection.should_receive(:open).with(request_url).and_return(@response)
      @connection.request(@api_resource, @api_method, args)
    end
    it "should return the API error message instead of raising an error if there was a problem with the request (404 response)" do
      error = OpenURI::HTTPError.new('404', StringIO.new('error message'))
      @connection.stub!(:open).and_raise(error)
      lambda { @connection.request("", "", {}) }.should_not raise_error
      error.io.rewind
      @connection.request("", "", {}).should == 'error message'
    end
    it "should set the format to json and the send app id without the user having to specify them" do
      request_url = "http://api.bandsintown.com/events/search?app_id=#{Bandsintown.app_id}&format=json"
      @connection.should_receive(:open).with(request_url).and_return(@response)
      @connection.request(@api_resource, @api_method, {})
    end
  end
  
end
