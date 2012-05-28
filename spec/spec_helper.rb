require File.join(File.dirname(__FILE__), '..', 'pdns.rb')

require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
