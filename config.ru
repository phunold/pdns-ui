require "rubygems"
require "bundler"

Bundler.require

require "pdns"

run Sinatra::Application
