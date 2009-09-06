require File.dirname(__FILE__) + '/spec_helper.rb'

describe Bandsintown do
  it "should have a module attr_accessor for @app_id" do
    Bandsintown.should respond_to(:app_id)
    Bandsintown.should respond_to(:app_id=)
  end
end
