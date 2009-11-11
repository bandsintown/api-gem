require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Artist do
  
  before(:each) do
    @options = {
      :name => 'Little Brother',
      :url => 'http://www.bandsintown.com/LittleBrother',
      :mbid => 'b929c0c9-5de0-4d87-8eb9-365ad1725629'
    }
    @artist = Bandsintown::Artist.new(@options)
  end
  
  describe "attributes" do
    it "should have an attr_accessor for @name" do
      @artist.should respond_to(:name)
      @artist.should respond_to(:name=)
    end
    it "should have an attr_accessor for @bandsintown_url" do
      @artist.should respond_to(:bandsintown_url)
      @artist.should respond_to(:bandsintown_url=)
    end
    it "should have an attr_accessor for @mbid" do
      @artist.should respond_to(:mbid)
      @artist.should respond_to(:mbid=)
    end
  end
  
  describe ".initialize(options = {})" do
    it "should set the Artist name from options" do
      @artist.name.should == @options[:name]
    end
    it "should set the Artist bandsintown_url from options" do
      @artist.bandsintown_url.should == @options[:url]
    end
    it "should set the Artist mbid from options" do
      @artist.mbid.should == @options[:mbid]
    end
    
    describe "generating a url (initialized without an option for :url)" do
      it "should strip spaces" do
        name = "The Beatles "
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/TheBeatles"
      end
      it "should convert '&' -> 'And'" do
        name = "Meg & Dia"
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/MegAndDia"
      end
      it "should convert '+' -> 'Plus'" do
        name = "+44"
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/Plus44"
      end
      it "should camelcase seperate words" do
        name = "meg & dia"
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/MegAndDia"
      end
      it "should not cgi escape url" do
        name = "$up"
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/$up"
      end
      it "should uri escape accented characters" do
        name = "sigur rós"
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/SigurR%C3%B3s"
      end
      it "should not alter the case of single word names" do
        name = "AWOL"
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/AWOL"
      end
      it "should allow dots" do
        name = "M.I.A"
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/M.I.A"
      end
      it "should allow exclamations" do
        name = "against me!"
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/AgainstMe!"
      end
      it "should not modify @options[:name]" do
        name = "this is how i think"
        Bandsintown::Artist.new(:name => name)
        name.should == "this is how i think"
      end
      it "should cgi escape '/' so it will be double encoded" do
        name = "AC/DC"
        escaped_name = URI.escape(name.gsub('/', CGI.escape('/')))
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/#{escaped_name}"
      end
      it "should cgi escape '?' so it will be double encoded" do
        name = "Does it offend you, yeah?"
        escaped_name = URI.escape("DoesItOffendYou,Yeah#{CGI.escape('?')}")
        Bandsintown::Artist.new(:name => name).bandsintown_url.should == "http://www.bandsintown.com/#{escaped_name}"
      end
      it "should use @mbid only if @name is nil" do
        Bandsintown::Artist.new(:name => 'name', :mbid => 'mbid').bandsintown_url.should == 'http://www.bandsintown.com/name'
        Bandsintown::Artist.new(:mbid => '1234').bandsintown_url.should == 'http://www.bandsintown.com/mbid_1234'
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
      @artist = Bandsintown::Artist.new(:name => "Little Brother")
    end
    it "should request and parse a call to the BIT artist events API method and the artist's api name" do
      @artist.should_receive(:api_name).and_return('Little%20Brother')
      Bandsintown::Artist.should_receive(:request_and_parse).with("Little%20Brother/events").and_return([])
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
    it "should be cached" do
      @artist.events = 'events'
      Bandsintown::Artist.should_not_receive(:request_and_parse)
      @artist.events.should == 'events'
    end
  end
  
  describe "#api_name" do
    it "should URI escape @name" do
      @artist.api_name.should == URI.escape(@artist.name)
    end
    it "should CGI escape / and ? characters before URI escaping the whole name" do
      Bandsintown::Artist.new(:name => "AC/DC").api_name.should == URI.escape(CGI.escape("AC/DC"))
      Bandsintown::Artist.new(:name => "?uestlove").api_name.should == URI.escape(CGI.escape("?uestlove"))
    end
    it "should use 'mbid_<@mbid>' only if @name is nil" do
      Bandsintown::Artist.new(:name => 'name', :mbid => 'mbid').api_name.should == 'name'
      Bandsintown::Artist.new(:mbid => '1234').api_name.should == 'mbid_1234'
    end
  end
end
