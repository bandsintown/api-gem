$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'open-uri'
require 'cgi'
require 'activesupport'
require 'json'

require 'bandsintown/base'
require 'bandsintown/connection'
require 'bandsintown/artist'
require 'bandsintown/event'
require 'bandsintown/venue'

module Bandsintown
  VERSION = '0.1.4'
  class APIError < StandardError; end
  class << self
    # All Bandsintown API requests require an app_id parameter for identification.
    # See http://www.bandsintown.com/api/authentication for more information.
    #
    attr_accessor :app_id
  end
end


