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
    it "should have an attr_accessor for @upcoming_events_count" do
      @artist.should respond_to(:upcoming_events_count)
      @artist.should respond_to(:upcoming_events_count=)
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
      Bandsintown::Artist.should_receive(:request_and_parse).with(:get, "Little%20Brother/events").and_return([])
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
  
  describe ".get(options = {})" do
    before(:each) do
      @options = { :name => "Pete Rock" }
      @artist = Bandsintown::Artist.new(@options)
      Bandsintown::Artist.stub!(:request_and_parse).and_return('json')
      Bandsintown::Artist.stub!(:build_from_json).and_return('built artist')
    end
    it "should initialize a Bandsintown::Artist from options" do
      Bandsintown::Artist.should_receive(:new).with(@options).and_return(@artist)
      Bandsintown::Artist.get(@options)
    end
    it "should request and parse a call to the BIT artists - get API method using api_name" do
      Bandsintown::Artist.should_receive(:request_and_parse).with(:get, @artist.api_name).and_return('json')
      Bandsintown::Artist.get(@options)
    end
    it "should return the result of Bandsintown::Artist.build_from_json with the response data" do
      Bandsintown::Artist.should_receive(:build_from_json).with('json').and_return('built artist')
      Bandsintown::Artist.get(@options).should == 'built artist'
    end
  end
  
  describe ".build_from_json(json_hash)" do
    before(:each) do
      @name = "Pete Rock"
      @bandsintown_url = "http://www.bandsintown.com/PeteRock"
      @mbid = "39a973f2-0785-4ef6-90d9-551378864f89"
      @upcoming_events_count = 7
      @json_hash = {
        "name" => @name,
        "url" => @bandsintown_url,
        "mbid" => @mbid,
        "upcoming_events_count" => @upcoming_events_count
      }
      @artist = Bandsintown::Artist.build_from_json(@json_hash)
    end
    it "should return an instance of Bandsintown::Artist" do
      @artist.should be_instance_of(Bandsintown::Artist)
    end
    it "should set the name" do
      @artist.name.should == @name
    end
    it "should set the mbid" do
      @artist.mbid.should == @mbid
    end
    it "should set the bandsintown_url" do 
      @artist.bandsintown_url.should == @bandsintown_url
    end
    it "should set the upcoming events count" do
      @artist.upcoming_events_count.should == @upcoming_events_count
    end
  end
  
  describe "#on_tour?" do
    it "should return true if @upcoming_events_count is greater than 0" do
      @artist.upcoming_events_count = 1
      @artist.should be_on_tour
    end
    it "should return false if @upcoming_events_count is 0" do
      @artist.upcoming_events_count = 0
      @artist.should_not be_on_tour
    end
    it "should raise an error if both @upcoming_events_count and @events are nil" do
      lambda { @artist.on_tour? }.should raise_error
    end
    describe "when @upcoming_events_count is nil" do
      it "should return true if @events is not empty (.events only returns upcoming events)" do
        @artist.events = [mock(Bandsintown::Event)]
        @artist.should be_on_tour
      end
      it "should return false if @events is empty" do
        @artist.events = []
        @artist.should_not be_on_tour
      end
    end
  end

  describe "#cancel_event(event_id)" do
    before(:each) do
      @event_id = 12345
      @artist = Bandsintown::Artist.new(:name => "Little Brother")
      @response = { "message" => "Event successfully cancelled (pending approval)" }
      Bandsintown::Artist.stub!(:request_and_parse).and_return(@response)
    end
    it "should request and parse a call to the BIT artists - cancel event API method using the artist's api_name and the given event_id" do
      Bandsintown::Artist.should_receive(:request_and_parse).with(:post, "#{@artist.api_name}/events/#{@event_id}/cancel").and_return(@response)
      @artist.cancel_event(@event_id)
    end
    it "should return the response message if an event was successfully cancelled" do
      @artist.cancel_event(@event_id).should == @response["message"]
    end
  end

  describe ".create(options = {})" do
    before(:each) do
      @options = { 
        :name => "A New Artist", 
        :myspace_url => "http://www.myspace.com/a_new_artist", 
        :mbid => "abcd1234-abcd-1234-5678-abcd12345678",
        :website => "http://www.a-new-artist.com"
      }
      Bandsintown::Artist.stub!(:request_and_parse).and_return('json')
      Bandsintown::Artist.stub!(:build_from_json).and_return('built artist')
    end
    it "should request and parse a call to the BIT artists - create API method using the supplied artist data" do
      expected_params = { :artist => @options }
      Bandsintown::Artist.should_receive(:request_and_parse).with(:post, "", expected_params).and_return('json')
      Bandsintown::Artist.create(@options)
    end
    it "should return the result of Bandsintown::Artist.build_from_json with the response data" do
      Bandsintown::Artist.should_receive(:build_from_json).with('json').and_return('built artist')
      Bandsintown::Artist.create(@options).should == 'built artist'
    end
  end
  
end
