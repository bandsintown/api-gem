require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Artist do
  
  before(:each) do
    @name = "Little Brother"
    @url = "http://www.bandsintown.com/LittleBrother"
    @artist = Bandsintown::Artist.new(@name, @url)
  end
  
  describe ".initialize(name, url = nil)" do
    it "should set the Artist name" do
      @artist.name.should == @name
    end
    it "should set the Artist bandsintown_url if given" do
      @artist.bandsintown_url.should == @url
    end
    
    describe "generating a url (initialize with nil url)" do
        it "should strip spaces" do
        name = "The Beatles "
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/TheBeatles"
      end
      it "should convert '&' -> 'And'" do
        name = "Meg & Dia"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/MegAndDia"
      end
      it "should convert '+' -> 'Plus'" do
        name = "+44"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/Plus44"
      end
      it "should camelcase seperate words" do
        name = "meg & dia"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/MegAndDia"
      end
      it "should not cgi escape url" do
        name = "$up"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/$up"
      end
      it "should not cgi escape accented characters" do
        name = "sigur rós"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/SigurRós"
      end
      it "should not alter the case of single word names" do
        name = "AWOL"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/AWOL"
      end
      it "should allow dots" do
        name = "M.I.A"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/M.I.A"
      end
      it "should allow exclamations" do
        name = "against me!"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/AgainstMe!"
      end
      it "should not modify @name" do
        name = "this is how i think"
        Bandsintown::Artist.new(name)
        name.should == "this is how i think"
      end
      it "should cgi escape '/' so it will be double encoded" do
        name = "AC/DC"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/AC#{CGI.escape('/')}DC"
      end
      it "should cgi escape '?' so it will be double encoded" do
        name = "Does it offend you, yeah?"
        Bandsintown::Artist.new(name).bandsintown_url.should == "http://www.bandsintown.com/DoesItOffendYou,Yeah#{CGI.escape('?')}"
      end
    end
  end
  
  describe ".resource_path" do
    it "should return the API resource path for artists" do
      Bandsintown::Artist.resource_path.should == 'artists'
    end
  end
  
  describe "#events" do
    before(:each) do
      @artist = Bandsintown::Artist.new("Little Brother")
    end
    it "should request and parse a call to the BIT artist events API method and the artist's api name" do
      @artist.should_receive(:api_name).and_return("Little+Brother")
      Bandsintown::Artist.should_receive(:request_and_parse).with("Little+Brother/events").and_return([])
      @artist.events
    end
    it "should return an Array of Bandsintown::Event objects built from the response" do
      event_1 = mock(Bandsintown::Event)
      event_2 = mock(Bandsintown::Event)
      results = [ "event 1", "event 2" ]
      Bandsintown::Artist.stub!(:request_and_parse).and_return(results)
      Bandsintown::Event.should_receive(:build_from_json).with("event 1").ordered.and_return(event_1)
      Bandsintown::Event.should_receive(:build_from_json).with("event 2").ordered.and_return(event_2)
      @artist.events.should == [event_1, event_2]
    end
  end
  
  describe "#api_name" do
    it "should URI escape @name" do
      @artist.api_name.should == URI.escape(@artist.name)
    end
    it "should CGI escape / and ? characters before URI escaping the whole name" do
      Bandsintown::Artist.new("AC/DC").api_name.should == URI.escape(CGI.escape("AC/DC"))
      Bandsintown::Artist.new("?uestlove").api_name.should == URI.escape(CGI.escape("?uestlove"))
    end
  end
end
