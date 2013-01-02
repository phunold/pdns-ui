require 'rubygems'
require 'bundler'

Bundler.require

# my app requires
require Pathname.new(__FILE__).dirname + 'config/application_helper'
require Pathname.new(__FILE__).dirname + 'pdns'

run App
