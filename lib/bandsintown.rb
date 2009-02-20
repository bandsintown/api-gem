$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'mechanize'
require 'cgi'
require 'activesupport'

require 'bandsintown/base'
require 'bandsintown/connection'
require 'bandsintown/event'

module Bandsintown
  VERSION = '0.0.1'
end