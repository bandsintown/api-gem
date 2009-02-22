require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Event do
  
  describe ".resource_path" do
    it "should return the relative path to Event requests" do
      Bandsintown::Event.resource_path.should == "events"
    end
  end
  
  describe ".search(args = {})" do
    it "should request and parse a call to the BIT events search api method" do
      args = { :date => "2009-01-01" }
      Bandsintown::Event.should_receive(:request_and_parse).with("search", args)
      Bandsintown::Event.search(args)
    end
  end
  
  describe ".build_from_json(json_hash)" do
    before(:each) do
      @event_id   = 745089
      @event_url  = "http://www.bandsintown.com/event/745095"
      @datetime   = "2008-09-30T19:30:00"
      @ticket_url = "http://www.bandsintown.com/event/745095/buy_tickets"
      
      @artist_1 = { "name" => "Little Brother", "url" => "http://www.bandsintown.com/LittleBrother" }
      @artist_2 = { "name" => "Joe Scudda", "url" => "http://www.bandsintown.com/JoeScudda" }
            
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
        "venue" => @venue_hash
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
    it "should set the Event's Venue" do
      built_venue = mock(Bandsintown::Venue)
      Bandsintown::Venue.should_receive(:new).with(@venue_hash).and_return(built_venue)
      @built_event = Bandsintown::Event.build_from_json(@event_hash)
      @built_event.venue.should == built_venue
    end
    it "should set the Event's Artists" do
      built_artist_1 = mock(Bandsintown::Artist, :name => "Little Brother")
      built_artist_2 = mock(Bandsintown::Artist, :name => "Joe Scudda")
      Bandsintown::Artist.should_receive(:new).with(@artist_1).and_return(built_artist_1)
      Bandsintown::Artist.should_receive(:new).with(@artist_2).and_return(built_artist_2)
      @built_event = Bandsintown::Event.build_from_json(@event_hash)
      @built_event.artists.should == [built_artist_1, built_artist_2]
    end
  end
end
