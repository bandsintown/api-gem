require 'test/unit'

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'bandsintown'
