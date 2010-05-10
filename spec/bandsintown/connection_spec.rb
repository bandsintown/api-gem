require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Connection do
  before(:each) do
    Bandsintown.app_id = 'YOUR_APP_ID'
    @base_url = "http://api.bandsintown.com"
  end
  
  describe ".initialize(base_url)" do
    before(:each) do
      @connection = Bandsintown::Connection.new(@base_url)
    end
    it "should set the base_url for the Connection" do
      @connection.base_url.should == @base_url
    end
  end
  
  describe ".get(resource_path, method_path, http_method, args = {})" do
    before(:each) do
      @connection = Bandsintown::Connection.new(@base_url)
      RestClient.stub!(:get).and_return("response")
      @api_resource = "events"
      @api_method = "search"
    end
    it "should convert args to url parameters when making a request" do
      args         = { :artists => ["Little Brother", "Joe Scudda"], :location => "Boston, MA", :radius => 10 }
      request_url  = "http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&artists%5B%5D=Little+Brother&artists%5B%5D=Joe+Scudda&format=json&location=Boston%2C+MA&radius=10"  
      @connection.should_receive(:encode).with(args).and_return(args.merge(:app_id => Bandsintown.app_id, :format => "json"))
      RestClient.should_receive(:get).with(request_url).and_return(@response)
      @connection.get(@api_resource, @api_method, args)
    end
    
    it "should return the API error message instead of raising an error if there was a problem with the request (404 response)" do
      error = RestClient::ResourceNotFound.new; error.response = "error message"
      RestClient.stub!(:get).and_raise(error)
      lambda { @connection.get("", "", {}) }.should_not raise_error
      @connection.get("", "", {}).should == "error message"
    end
  end
  
  describe ".encode(args={})" do
    before(:each) do
      @connection = Bandsintown::Connection.new(@base_url)
    end
    it "should return a Hash including :app_id and :format => json without the user having to specify them" do
      encoded = @connection.encode({})
      encoded.should be_instance_of(Hash)
      encoded[:app_id].should == Bandsintown.app_id
      encoded[:format].should == 'json'
    end
    it "should convert args[:start_date] and args[:end_date] to a single args[:date] parameter" do
      args = { :start_date => "2009-01-01", :end_date => "2009-02-01" }
      encoded = @connection.encode(args)
      encoded[:date].should == "2009-01-01,2009-02-01"
    end
    it "should allow :date to be a Time object" do
      args = { :date => Time.now.beginning_of_day }
      encoded = @connection.encode(args)
      encoded[:date].should == Time.now.beginning_of_day.strftime("%Y-%m-%d") 
    end
    it "should allow :date to be a Date object" do
      args = { :date => Date.today }
      encoded = @connection.encode(args)
      encoded[:date].should == Date.today.to_s
    end
    it "should allow :date to be a String object" do
      args = { :date => "2009-01-01" }
      encoded = @connection.encode(args)
      encoded[:date].should == "2009-01-01"
    end
    it "should allow :start_date and :end_date to be Time objects" do
      args = { :start_date => 1.week.ago, :end_date => 1.week.from_now }
      encoded = @connection.encode(args)
      encoded[:date].should == "#{1.week.ago.strftime("%Y-%m-%d")},#{1.week.from_now.strftime("%Y-%m-%d")}"
    end
    it "should allow :start_date and :end_date to be Date objects" do
      args = { :start_date => 1.week.ago.to_date, :end_date => 1.week.from_now.to_date }
      encoded = @connection.encode(args)
      encoded[:date].should == "#{1.week.ago.strftime("%Y-%m-%d")},#{1.week.from_now.strftime("%Y-%m-%d")}"
    end
    it "should allow :start_date and :end_date to be String objects" do
      args = { :start_date => "2009-01-01", :end_date => "2009-02-01" }
      encoded = @connection.encode(args)
      encoded[:date].should == "2009-01-01,2009-02-01" 
    end
  end
end
