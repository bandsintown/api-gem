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
  
end
