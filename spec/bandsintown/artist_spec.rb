require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Artist do
  
  describe ".initialize(name, url)" do
    before(:each) do
      @name = "Little Brother"
      @url = "http://bandsintown.com/LittleBrother"
      @artist = Bandsintown::Artist.new({ "name" => @name, "url" => @url})
    end
    it "should set the Artist name" do
      @artist.name.should == @name
    end
    it "should set the Artist bandsintown_url" do
      @artist.bandsintown_url.should == @url
    end
  end
  
end
