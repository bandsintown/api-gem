require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Event do
  it "should include the Bandsintown::Event::CreationHelpers module" do
    Bandsintown::Event.included_modules.should include(Bandsintown::Event::CreationHelpers)
  end
  
  describe ".resource_path" do
    it "should return the relative path to Event requests" do
      Bandsintown::Event.resource_path.should == "events"
    end
  end
  
  describe ".search(options = {})" do
    before(:each) do
      @args = { :location => "Boston, MA", :date => "2009-01-01" }
    end
    it "should request and parse a call to the BIT events search api method" do
      Bandsintown::Event.should_receive(:request_and_parse).with(:get, "search", @args).and_return([])
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
  
  describe ".recommended(options = {})" do
    before(:each) do
      @args = { :location => "Boston, MA", :date => "2009-01-01" }
    end
    it "should request and parse a call to the BIT recommended events api method" do
      Bandsintown::Event.should_receive(:request_and_parse).with(:get, "recommended", @args).and_return([])
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
      Bandsintown::Event.should_receive(:request_and_parse).with(:get, "daily").and_return([])
      Bandsintown::Event.daily
    end
    it "should return an array of Bandsintown::Events built from the response" do
      event = mock(Bandsintown::Event)
      Bandsintown::Event.stub!(:request_and_parse).and_return(['event json'])
      Bandsintown::Event.should_receive(:build_from_json).with('event json').and_return(event)
      Bandsintown::Event.daily.should == [event]
    end
  end
  
  describe ".on_sale_soon(options = {})" do
    before(:each) do
      @args = { :location => "Boston, MA", :radius => 50, :date => "2010-03-02" }
    end
    it "should request and parse a call to the BIT on sale soon api method" do
      Bandsintown::Event.should_receive(:request_and_parse).with(:get, "on_sale_soon", @args).and_return([])
      Bandsintown::Event.on_sale_soon(@args)
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
      @built_event.should be_instance_of(Bandsintown::Event)
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
      venue = @built_event.venue
      venue.should be_instance_of(Bandsintown::Venue)
      venue.bandsintown_id.should == 327987
      venue.bandsintown_url.should == "http://www.bandsintown.com/venue/327987"
      venue.region.should == "MA"
      venue.city.should == "Boston"
      venue.name.should == "Paradise Rock Club"
      venue.country.should == "United States"
      venue.latitude.should == 42.37
      venue.longitude.should == 71.03
    end
    it "should set the Event's Artists" do
      artists = @built_event.artists
      artists.should be_instance_of(Array)
      artists.size.should == 2
      
      artists.first.should be_instance_of(Bandsintown::Artist)
      artists.first.name.should == "Little Brother"
      artists.first.bandsintown_url.should == "http://www.bandsintown.com/LittleBrother"
      artists.first.mbid.should == "b929c0c9-5de0-4d87-8eb9-365ad1725629"
      
      artists.last.should be_instance_of(Bandsintown::Artist)
      artists.last.name.should == "Joe Scudda"
      artists.last.bandsintown_url.should == "http://www.bandsintown.com/JoeScudda"
      artists.last.mbid.should be_nil          
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
  
  describe ".create(options = {})" do
    before(:each) do
      @options = { :artists => [], :venue => {}, :datetime => '' }
      @response = { "message" => "Event successfully submitted (pending approval)" }
      Bandsintown::Event.stub!(:request_and_parse).and_return(@response)
    end
    it "should request and parse a call to the BIT events - create API mehod" do
      Bandsintown::Event.should_receive(:request_and_parse).with(:post, "", anything).and_return(@response)
      Bandsintown::Event.create(@options)
    end
    it "should return the response message if an event was successfully submitted using a non-trusted app_id" do
      Bandsintown::Event.should_not_receive(:build_from_json)
      Bandsintown::Event.create(@options).should == @response["message"]
    end
    it "should return a Bandsintown::Event build from the response if an event was sucessfully submitted using a trusted app_id" do
      Bandsintown::Event.stub!(:request_and_parse).and_return({ "event" => "data" })
      event = mock(Bandsintown::Event)
      Bandsintown::Event.should_receive(:build_from_json).with("data").and_return(event)
      Bandsintown::Event.create(@options).should == event
    end
    describe "event options" do
      before(:each) do
        Bandsintown::Event.stub!(:parse_artists)
        Bandsintown::Event.stub!(:parse_datetime)
        Bandsintown::Event.stub!(:parse_venue)
      end
      
      it "should parse the artists using parse_artists" do
        @options = { :artists => ["Evidence", "Alchemist"] }
        Bandsintown::Event.should_receive(:parse_artists).with(@options[:artists]).and_return('parsed')
        expected_event_params = { :artists => 'parsed' }
        Bandsintown::Event.should_receive(:request_and_parse).with(:post, "", :event => hash_including(expected_event_params))
      end
      
      it "should parse the datetime using parse_datetime" do
        @options = { :datetime => "2010-06-01T20:30:00" }
        Bandsintown::Event.should_receive(:parse_datetime).with(@options[:datetime]).and_return('parsed')
        expected_event_params = { :datetime => "parsed" }
        Bandsintown::Event.should_receive(:request_and_parse).with(:post, "", :event => hash_including(expected_event_params))
      end
      
      it "should parse the on_sale_datetime using parse_datetime" do
        @options = { :on_sale_datetime => "2010-06-01T20:30:00" }
        Bandsintown::Event.should_receive(:parse_datetime).with(@options[:on_sale_datetime]).and_return('parsed')
        expected_event_params = { :on_sale_datetime => "parsed" }
        Bandsintown::Event.should_receive(:request_and_parse).with(:post, "", :event => hash_including(expected_event_params))
      end
      
      it "should parse the venue using parse_venue" do
        @options = { :venue => "data" }
        Bandsintown::Event.should_receive(:parse_venue).with("data").and_return("venue")
        expected_event_params = { :venue => "venue" }
        Bandsintown::Event.should_receive(:request_and_parse).with(:post, "", :event => hash_including(expected_event_params))
      end
      
      after(:each) do
        Bandsintown::Event.create(@options)
      end
    end
  end

  describe "#cancel" do
    before(:each) do
      @event = Bandsintown::Event.new
      @event.bandsintown_id = 12345
      @response = { "message" => "Event successfully cancelled (pending approval)" }
      Bandsintown::Event.stub!(:request_and_parse).and_return(@response)
    end
    it "should raise an error if the event does not have a bandsintown_id" do
      @event.bandsintown_id = nil
      lambda { @event.cancel }.should raise_error(StandardError, "event cancellation requires a bandsintown_id")
    end
    it "should request and parse a call to the BIT events - cancel API method using the event's bandsintown_id" do
      Bandsintown::Event.should_receive(:request_and_parse).with(:post, "#{@event.bandsintown_id}/cancel").and_return(@response)
      @event.cancel
    end
    it "should return the response message if an event was successfully cancelled" do
      @event.cancel.should == @response["message"]
    end
  end
end