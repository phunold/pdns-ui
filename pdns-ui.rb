#!/usr/bin/env ruby

require 'sinatra'
require 'rubygems'
require 'sequel'
require 'haml'
require 'will_paginate'
require 'will_paginate/sequel'
require 'will_paginate/version'

configure do
  DB = Sequel.mysql 'pdns', :user=>'pdns', :host=>'localhost', :password=>'pdns'
  @@total = DB[:pdns].count
end

# send emtpy
get '/favicon' do
end

# error handling 404
not_found do
  haml :sorry
end
# error handling 500
error do
  haml :sorry
end

get '/' do
  puts WillPaginate::VERSION::STRING
  @items = DB[:pdns].reverse_order(:LAST_SEEN).limit(100)
  @total = @items.count
#  @items = @items.paginate :page => params[:page], :per_page => 30 
  haml :index
end

post '/search' do
  pattern = params['search'].strip
  # go back if search is not valid
  redirect back if pattern == "search"

  # match loosly against 'query' and 'answer' column
  pdns = DB[:pdns]
  @results = pdns.where(:QUERY.like("%#{pattern}%") | :ANSWER.like("%#{pattern}%"))

  @results_total = @results.count

  # render result
  haml :searchresult

end

get '/summary' do
  # count expiring TTLs per RR
  @low_ttls = DB[:pdns].group_and_count(:QUERY).having{count >= 10}.where(:TTL <= 60).reverse_order(:count)

  # show distribution of maptype(A,PTR,CNAME,etc)
  @maptypes = DB[:pdns].group_and_count(:MAPTYPE)

  haml :summary
  
end

get '/about' do
  haml :about
end
