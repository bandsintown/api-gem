require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Venue do
  
  describe "attributes" do
    before(:each) do
      @venue = Bandsintown::Venue.new(123)
    end
    it "should have an accessor for @name" do
      @venue.should respond_to(:name)
      @venue.should respond_to(:name=)
    end
    it "should have an accessor for @bandsintown_id" do
      @venue.should respond_to(:bandsintown_id)
      @venue.should respond_to(:bandsintown_id=)
    end
    it "should have an accessor for @bandsintown_url" do
      @venue.should respond_to(:bandsintown_url)
      @venue.should respond_to(:bandsintown_url=)
    end
    it "should have an accessor for @address" do
      @venue.should respond_to(:address)
      @venue.should respond_to(:address=)
    end
    it "should have an accessor for @city" do
      @venue.should respond_to(:city)
      @venue.should respond_to(:city=)
    end
    it "should have an accessor for @region" do
      @venue.should respond_to(:region)
      @venue.should respond_to(:region=)
    end
    it "should have an accessor for @postalcode" do
      @venue.should respond_to(:postalcode)
      @venue.should respond_to(:postalcode=)
    end
    it "should have an accessor for @country" do
      @venue.should respond_to(:country)
      @venue.should respond_to(:country=)
    end
    it "should have an accessor for @latitude" do
      @venue.should respond_to(:latitude)
      @venue.should respond_to(:latitude=)
    end
    it "should have an accessor for @longitude" do
      @venue.should respond_to(:longitude)
      @venue.should respond_to(:longitude=)
    end
    it "should have an accessor for @events" do
      @venue.should respond_to(:events)
      @venue.should respond_to(:events=)
    end
  end
  
  describe ".initialize(bandsintown_id)" do
    it "should set @bandsintown_id to bandsintown_id" do
      Bandsintown::Venue.new(123).bandsintown_id.should == 123
    end
  end
  
  describe ".build_from_json(options = {})" do
    before(:each) do
      @name = "Paradise Rock Club"
      @url = "http://www.bandsintown.com/venue/327987"
      @id = 327987
      @region = "MA"
      @city = "Boston"
      @country = "United States"
      @latitude = 42.37
      @longitude = 71.03
      
      @venue = Bandsintown::Venue.build_from_json({
        "name" => @name,
        "url" => @url,
        "id" => @id,
        "region" => @region,
        "city" => @city,
        "country" => @country,
        "latitude" => @latitude,
        "longitude" => @longitude,
      })
    end
    it "should return a Bandsintown::Venue instance" do
      @venue.should be_instance_of(Bandsintown::Venue)
    end
    it "should set the name" do
      @venue.name.should == @name
    end
    it "should set the bandsintown_url" do
      @venue.bandsintown_url.should == @url
    end
    it "should set the bandsintown_id" do
      @venue.bandsintown_id.should == @id
    end
    it "should set the region" do
      @venue.region.should == @region
    end
    it "should set the city" do
      @venue.city.should == @city
    end
    it "should set the country" do
      @venue.country.should == @country
    end
    it "should set the longitude" do
      @venue.longitude.should == @longitude
    end
    it "should set the latitude" do
      @venue.latitude.should == @latitude
    end
  end
  
  describe ".resource_path" do
    it "should return the path for Venue requests" do
      Bandsintown::Venue.resource_path.should == "venues"
    end
  end
  
  describe ".search(options={})" do
    before(:each) do
      @args = { :location => "Boston, MA", :query => "House of Blues" }
    end
    it "should request and parse a call to the BIT venues search api method" do
      Bandsintown::Venue.should_receive(:request_and_parse).with(:get, "search", @args).and_return([])
      Bandsintown::Venue.search(@args)
    end
    it "should return an Array of Bandsintown::Venue objects built from the response" do
      results = [
        { 'id' => '123', 'name' => "house of blues" },
        { 'id' => '456', 'name' => "house of blues boston" }
      ]
      Bandsintown::Venue.stub!(:request_and_parse).and_return(results)
      venues = Bandsintown::Venue.search(@args)
      venues.should be_instance_of(Array)
      
      venues.first.should be_instance_of(Bandsintown::Venue)
      venues.first.bandsintown_id.should == '123'
      venues.first.name.should == 'house of blues'
      
      venues.last.should be_instance_of(Bandsintown::Venue)
      venues.last.bandsintown_id.should == '456'
      venues.last.name.should == 'house of blues boston'
    end
  end
  
  describe "#events" do
    before(:each) do
      @bandsintown_id = 123
      @venue = Bandsintown::Venue.new(@bandsintown_id)
    end
    it "should request and parse a call to the BIT venues - events API method with @bandsintown_id" do
      Bandsintown::Venue.should_receive(:request_and_parse).with(:get, "#{@bandsintown_id}/events").and_return([])
      @venue.events
    end
    it "should return an Array of Bandsintown::Event objects built from the response" do
      event_1 = mock(Bandsintown::Event)
      event_2 = mock(Bandsintown::Event)
      results = [ "event 1", "event 2" ]
      Bandsintown::Venue.stub!(:request_and_parse).and_return(results)
      Bandsintown::Event.should_receive(:build_from_json).with("event 1").ordered.and_return(event_1)
      Bandsintown::Event.should_receive(:build_from_json).with("event 2").ordered.and_return(event_2)
      @venue.events.should == [event_1, event_2]
    end
    it "should be memoized" do
      @venue.events = 'events'
      Bandsintown::Venue.should_not_receive(:request_and_parse)
      @venue.events.should == 'events'
    end
  end
  
end
