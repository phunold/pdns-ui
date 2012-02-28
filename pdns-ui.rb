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


post '/search' do
  pattern = params['search'].strip
  # go back if search is not valid
  redirect back if pattern == "search"

  # match loosly against 'query' and 'answer' column
  pdns = DB[:pdns]
  @results = pdns.where(:query.like("%#{pattern}%") | :answer.like("%#{pattern}%"))

  @results_total = @results.count

  # render result
  haml :searchresult

end

