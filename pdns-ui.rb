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
  @@_ds = DB[:pdns]
  @@total = @@_ds.count
end

helpers do
  def cycle
    @_cycle ||= reset_cycle
    @_cycle = [@_cycle.pop] + @_cycle
    @_cycle.first
  end
  def reset_cycle
    @_cycle = %w(even odd)
  end  
end

# send empty response
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

# index page / tabular listing of DNS records
get '/' do
  puts WillPaginate::VERSION::STRING
  @items = @@_ds.reverse_order(:LAST_SEEN).limit(100)
  @total = @items.count
#  @items = @items.paginate :page => params[:page], :per_page => 30 
  haml :index
end

# detailed few for 'click' action
get '/q/:query' do
  @results = @@_ds.filter(:QUERY => params[:query])
  puts @results.inspect 
  
  @results_total = @results.count
  haml :searchresult
end

post '/search' do
  pattern = params['search'].strip

  # go back if search is not valid
  redirect back if pattern == "search"

  # match loosly against 'query' and 'answer' column
  @results = @@_ds.where(:QUERY.like("%#{pattern}%") | :ANSWER.like("%#{pattern}%"))

  @results_total = @results.count
  
  # limit results to 100 always
  @results = @results.reverse_order(:LAST_SEEN).limit(100)

  # render result
  haml :searchresult

end

get '/advanced_search' do
  # group unique for dropdown menu
  @rrs = @@_ds.group(:RR).order(:RR)
  @maptypes = @@_ds.group(:MAPTYPE).order(:MAPTYPE)
  haml :advanced_search
end

post '/advanced_search' do
  answer  = params['answer'].strip
  query   = params['query'].strip
  rr      = params['rr']
  maptype = params['maptype']

  # go back if search is not valid
  redirect back if (answer == "any" && query == "any" && rr.empty? && maptype.empty?) 


  # chain filters (logical AND)
  @results = @@_ds
  @results = @results.where(:QUERY.like("%#{query}%")) unless query == "any"
  @results = @results.where(:ANSWER.like("%#{answer}%")) unless answer == "any"
  @results = @results.filter(:RR => rr) unless rr.empty?
  @results = @results.filter(:MAPTYPE => maptype) unless maptype.empty?

  @results = @results.filter(:MAPTYPE => maptype) unless maptype.empty?
  @results_total = @results.count

  # limit results to 100 (always)
  @results = @results.reverse_order(:LAST_SEEN).limit(100)

  # render result
  haml :searchresult
end

get '/summary' do
  # count expiring TTLs per RR
  @low_ttls = @@_ds.group_and_count(:QUERY).having{count >= 10}.where(:TTL <= 60).reverse_order(:count)

  # show distribution of maptype(A,PTR,CNAME,etc)
  @maptypes = @@_ds.group_and_count(:MAPTYPE)

  haml :summary
  
end

get '/about' do
  haml :about
end
