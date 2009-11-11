require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Event do
  
  describe ".resource_path" do
    it "should return the relative path to Event requests" do
      Bandsintown::Event.resource_path.should == "events"
    end
  end
  
  describe ".search(args = {})" do
    @args = { :location => "Boston, MA", :date => "2009-01-01" }
    it "should request and parse a call to the BIT events search api method" do
      Bandsintown::Event.should_receive(:request_and_parse).with("search", @args).and_return([])
      Bandsintown::Event.search(@args)
    end
    it "should return an Array of Bandsintown::Event objects built from the response" do
      event_1 = mock(Bandsintown::Event)
      event_2 = mock(Bandsintown::Event)
      results = [ "event 1", "event 2" ]
      Bandsintown::Event.stub!(:request_and_parse).and_return(results)
      Bandsintown::Event.should_receive(:build_from_json).with("event 1").ordered.and_return(event_1)
      Bandsintown::Event.should_receive(:build_from_json).with("event 2").ordered.and_return(event_2)
      Bandsintown::Event.search(@args).should == [event_1, event_2]
    end
  end
  
  describe ".recommended(args = {})" do
    @args = { :location => "Boston, MA", :date => "2009-01-01" }
    it "should request and parse a call to the BIT recommended events api method" do
      Bandsintown::Event.should_receive(:request_and_parse).with("recommended", @args).and_return([])
      Bandsintown::Event.recommended(@args)
    end
    it "should return an Array of Bandsintown::Event objects built from the response" do
      event_1 = mock(Bandsintown::Event)
      event_2 = mock(Bandsintown::Event)
      results = [ "event 1", "event 2" ]
      Bandsintown::Event.stub!(:request_and_parse).and_return(results)
      Bandsintown::Event.should_receive(:build_from_json).with("event 1").ordered.and_return(event_1)
      Bandsintown::Event.should_receive(:build_from_json).with("event 2").ordered.and_return(event_2)
      Bandsintown::Event.recommended(@args).should == [event_1, event_2]
    end
  end
  
  describe ".daily" do
    it "should request and parse a call to the BIT daily events api method" do
      Bandsintown::Event.should_receive(:request_and_parse).with("daily").and_return([])
      Bandsintown::Event.daily
    end
    it "should return an array of Bandsintown::Events built from the response" do
      event = mock(Bandsintown::Event)
      Bandsintown::Event.stub!(:request_and_parse).and_return(['event json'])
      Bandsintown::Event.should_receive(:build_from_json).with('event json').and_return(event)
      Bandsintown::Event.daily.should == [event]
    end
  end
  
  describe ".build_from_json(json_hash)" do
    before(:each) do
      @event_id   = 745089
      @event_url  = "http://www.bandsintown.com/event/745095"
      @datetime   = "2008-09-30T19:30:00"
      @ticket_url = "http://www.bandsintown.com/event/745095/buy_tickets"
      
      @artist_1 = { "name" => "Little Brother", "url" => "http://www.bandsintown.com/LittleBrother", "mbid" => "b929c0c9-5de0-4d87-8eb9-365ad1725629" }
      @artist_2 = { "name" => "Joe Scudda", "url" => "http://www.bandsintown.com/JoeScudda", "mbid" => nil } # sorry Joe its just an example
            
      @venue_hash = {
        "id" => 327987,
        "url" => "http://www.bandsintown.com/venue/327987",
        "region" => "MA",
        "city" => "Boston",
        "name" => "Paradise Rock Club",
        "country" => "United States",
        "latitude" => 42.37,
        "longitude" => 71.03
      }
      
      @event_hash = {
        "id" => @event_id,
        "url" => @event_url,
        "datetime" => @datetime,
        "ticket_url" => @ticket_url,
        "artists" => [@artist_1, @artist_2],
        "venue" => @venue_hash,
        "status" => "new",
        "ticket_status" => "available",
        "on_sale_datetime" => "2008-09-01T19:30:00"
      }
      
      @built_event = Bandsintown::Event.build_from_json(@event_hash)
    end
    it "should return a built Event" do
      @built_event.class.should == Bandsintown::Event
    end
    it "should set the Event id" do
      @built_event.bandsintown_id.should == @event_id
    end
    it "should set the Event url" do
      @built_event.bandsintown_url.should == @event_url
    end
    it "should set the Event datetime" do
      @built_event.datetime.should == Time.parse(@datetime)
    end
    it "should set the Event ticket url" do
      @built_event.ticket_url.should == @ticket_url
    end
    it "should set the Event status" do
      @built_event.status.should == "new"
    end
    it "should set the Event ticket_status" do
      @built_event.ticket_status.should == "available"
    end
    it "should set the Event on_sale_datetime" do
      @built_event.on_sale_datetime.should == Time.parse(@event_hash['on_sale_datetime'])
    end
    it "should set the Event on_sale_datetime to nil if not given" do
      @event_hash['on_sale_datetime'] = nil
      Bandsintown::Event.build_from_json(@event_hash).on_sale_datetime.should be_nil
    end
    it "should set the Event's Venue" do
      built_venue = mock(Bandsintown::Venue)
      Bandsintown::Venue.should_receive(:new).with(@venue_hash).and_return(built_venue)
      @built_event = Bandsintown::Event.build_from_json(@event_hash)
      @built_event.venue.should == built_venue
    end
    it "should set the Event's Artists" do
      built_artist_1 = mock(Bandsintown::Artist)
      built_artist_2 = mock(Bandsintown::Artist)
      Bandsintown::Artist.should_receive(:new).with(:name => @artist_1["name"], :url => @artist_1["url"], :mbid => @artist_1["mbid"]).and_return(built_artist_1)
      Bandsintown::Artist.should_receive(:new).with(:name => @artist_2["name"], :url => @artist_2["url"], :mbid => @artist_2["mbid"]).and_return(built_artist_2)
      @built_event = Bandsintown::Event.build_from_json(@event_hash)
      @built_event.artists.should == [built_artist_1, built_artist_2]
    end
  end
  
  describe "#tickets_available?" do
    it "should return true if @ticket_status is 'available'" do
      event = Bandsintown::Event.new
      event.ticket_status = 'available'
      event.tickets_available?.should be_true
    end
    it "should return false if @ticket_status is not 'available'" do
      event = Bandsintown::Event.new
      event.ticket_status = 'unavailable'
      event.tickets_available?.should be_false
    end
  end
end
