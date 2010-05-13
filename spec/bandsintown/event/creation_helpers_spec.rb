require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Bandsintown::Event::CreationHelpers do
  before(:each) do
    class Bandsintown::ExtendedClass; include Bandsintown::Event::CreationHelpers; end
  end
  describe ".parse_datetime(datetime)" do
    it "should return datetime when given a String object" do
      datetime = "2010-06-01T20:30:00"
      expected = datetime
      Bandsintown::ExtendedClass.parse_datetime(datetime).should == expected
    end
    it "should return datetime formatted to ISO 8601 if given a Time object" do
      datetime = Time.parse("2010-06-01 20:30")
      expected = "2010-06-01T20:30:00"
      Bandsintown::ExtendedClass.parse_datetime(datetime).should == expected
    end
    it "should return datetime formatted to ISO 8601 if given a DateTime object" do
      datetime = DateTime.parse("2010-06-01 20:30")
      expected = "2010-06-01T20:30:00"
      Bandsintown::ExtendedClass.parse_datetime(datetime).should == expected
    end
    it "should return datetime formatted to ISO 8601 at 19:00 if given a Date object" do
      datetime = Date.parse("2010-06-01")
      expected = "2010-06-01T19:00:00"
      Bandsintown::ExtendedClass.parse_datetime(datetime).should == expected
    end
  end
  
  describe ".parse_venue(venue_data)" do
    describe "venue_data given as a hash" do
      before(:each) do
        @venue_data = { 
          :name => "Paradise", 
          :address => "967 Commonwealth Ave",
          :city => "Boston", 
          :region => "MA", 
          :postalcode => "02215",
          :country => "United States", 
          :latitude => '',
          :longitude => ''
        }        
      end
      it "should return a hash with non-blank location data if venue_data is given as a hash without bandsintown id" do
        Bandsintown::ExtendedClass.parse_venue(@venue_data).should == {
          :name => "Paradise", 
          :address => "967 Commonwealth Ave",
          :city => "Boston", 
          :region => "MA", 
          :postalcode => "02215",
          :country => "United States"
        }
      end
      it "should return a hash with bandsintown id and no location data if venue_data is given as a hash with bandsintown id" do
        @venue_data[:bandsintown_id] = 1700
        Bandsintown::ExtendedClass.parse_venue(@venue_data).should == { :id => 1700 }
      end
    end
    describe "venue_data given as a Bandsintown::Venue" do
      before(:each) do
        @venue = Bandsintown::Venue.new(1700)
        @venue.name = "Paradise"
        @venue.address = "967 Commonwealth Ave"
        @venue.city = "Boston"
        @venue.region = "MA"
        @venue.country = "United States"
      end
      it "should return a hash with non-blank location data if venue_data is given as a Bandsintown::Venue without bandsintown id" do
        @venue.bandsintown_id = ''
        Bandsintown::ExtendedClass.parse_venue(@venue).should == {
          :name => "Paradise", 
          :address => "967 Commonwealth Ave",
          :city => "Boston", 
          :region => "MA", 
          :country => "United States"
        }
      end
      it "should return a hash with bandsintown id if venue_data is given as a Bandsintown::Venue with bandsintown id" do
        Bandsintown::ExtendedClass.parse_venue(@venue).should == { :id => 1700 }
      end
    end
  end

  describe ".parse_artists(artist_data)" do
    it "should return an array of { :name => name } when given strings" do
      artist_data = ["Evidence", "Alchemist"]
      Bandsintown::Event.parse_artists(artist_data).should == [{ :name => "Evidence" }, { :name => "Alchemist" }]
    end
    it "should return an array of { :name => name } when given Bandsintown::Artist instances without mbid" do
      artist_data = [Bandsintown::Artist.new(:name => "Evidence"), Bandsintown::Artist.new(:name => "Alchemist")]
      Bandsintown::Event.parse_artists(artist_data).should == [{ :name => "Evidence" }, { :name => "Alchemist" }]
    end
    it "should return an array of { :mbid => mbid } when given Bandsintown::Artist instance with mbid" do
      artist_data = [Bandsintown::Artist.new(:mbid => "123"), Bandsintown::Artist.new(:mbid => "456")]
      Bandsintown::Event.parse_artists(artist_data).should == [{ :mbid => "123" }, { :mbid => "456" }]
    end
    it "should work with different data types given" do
      artist_data = ["Evidence", Bandsintown::Artist.new(:name => "Alchemist"), Bandsintown::Artist.new(:mbid => "123")]
      Bandsintown::Event.parse_artists(artist_data).should == [{ :name => "Evidence" }, { :name => "Alchemist" }, { :mbid => "123" }]
    end
  end
end