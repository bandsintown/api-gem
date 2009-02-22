require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Venue do
  
  describe ".initialize(name, url)" do
    before(:each) do
      @name = "Paradise Rock Club"
      @url = "http://www.bandsintown.com/venue/327987"
      @id = 327987
      @region = "MA"
      @city = "Boston"
      @country = "United States"
      @latitude = 42.37
      @longitude = 71.03
      
      @venue = Bandsintown::Venue.new({
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
    it "should set the name" do
      @venue.name.should == @name
    end
    it "should set the bandsintown_url" do
      @venue.bandsintown_url.should == @url
    end
    it "should set the bandsintown_id" do
      @venue.bandsintown_id.should == @bandsintown_id
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
  
end
