#!/usr/bin/env ruby

require 'sinatra'
require 'rubygems'
require 'sequel'
require 'haml'

# connect to passiveDNS database
DB = Sequel.mysql 'pdns', :user=>'pdns', :host=>'localhost', :password=>'pdns'

get '/' do
	@pdns = DB[:pdns].order(:LAST_SEEN)
	@total = @pdns.count
	haml :index
end


