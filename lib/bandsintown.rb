$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'mechanize'
require 'activesupport'
require 'json'

require 'bandsintown/base'
require 'bandsintown/connection'
require 'bandsintown/artist'
require 'bandsintown/event'
require 'bandsintown/venue'

module Bandsintown
  class APIError < StandardError
  end
  VERSION = '0.0.1'
end


