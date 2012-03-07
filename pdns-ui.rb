#!/usr/bin/env ruby

require 'sinatra'
require 'rubygems'
require 'sequel'
require 'haml'
require 'ostruct'
require 'will_paginate'
require 'will_paginate/sequel'

configure do
  # set globals
  CONFIG = OpenStruct.new(:PER_PAGE => 50)

  DB = Sequel.mysql 'pdns_test', :user=>'pdns', :host=>'localhost', :password=>'pdns'
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

# index page / tabular listing of DNS records
get '/' do
  params[:page] ||= 1
  @records = @@_ds.reverse_order(:LAST_SEEN).paginate(params[:page].to_i,CONFIG.PER_PAGE)
  haml :index
end

# exact lookup of DNS query
get '/q/:query' do
  params[:page] ||= 1
  @lookup  = params[:query]
  @records = @@_ds.where(:QUERY => @lookup).paginate(params[:page].to_i,CONFIG.PER_PAGE)

  # lookup search should always give you a result
  # but lets just catch this anyway
  if @records.count >= 1 then
    haml :lookup_result
  else
    haml :sorry
  end
end

# exact lookup of DNS answer
get '/a/:answer' do
  params[:page] ||= 1
  @lookup   = params[:answer]
  @records = @@_ds.where(:ANSWER => @lookup).paginate(params[:page].to_i,CONFIG.PER_PAGE)

  # lookup search should always give you a result
  # but lets just catch this anyway
  if @records.count >= 1 then
    haml :lookup_result
  else
    haml :sorry
  end
end

get '/search_result' do
  @lookup = params[:search].strip
  params[:page] ||= 1 

  # go back if search is not valid
  redirect back if @lookup == "search"

  # match loosly against 'query' OR 'answer' column
  @records = @@_ds.where(:QUERY.like("%#{@lookup}%") | :ANSWER.like("%#{@lookup}%"))

  # create paginated records
  @records = @records.reverse_order(:LAST_SEEN).paginate(params[:page].to_i,CONFIG.PER_PAGE)

  # FIXME what if returns no results?
  haml :lookup_result

end

get '/advanced_search' do
  # group unique for dropdown menu
  @rrs = @@_ds.group(:RR).order(:RR)
  @maptypes = @@_ds.group(:MAPTYPE).order(:MAPTYPE)
  haml :advanced_search
end

get '/advanced_search_result' do
  terms = Array.new
  terms << answer  = params[:answer].strip
  terms << query   = params[:query].strip
  terms << rr      = params[:rr]
  terms << maptype = params[:maptype]
  params[:page] ||= 1

  # FIXME this is quick and too dirty
  # make the advanced search parameters show up nicely at the top
  @lookup = terms.join(" ")

  # go back if search is not valid
  redirect back if (answer == "any" && query == "any" && rr.empty? && maptype.empty?) 

  # start to chain filters (logical AND)
  @records = @@_ds
  @records = @records.where(:QUERY.like("%#{query}%")) unless query == "any"
  @records = @records.where(:ANSWER.like("%#{answer}%")) unless answer == "any"
  @records = @records.filter(:RR => rr) unless rr.empty?
  @records = @records.filter(:MAPTYPE => maptype) unless maptype.empty?
  @records = @records.filter(:MAPTYPE => maptype) unless maptype.empty?

  @records = @records.reverse_order(:LAST_SEEN).paginate(params[:page].to_i,CONFIG.PER_PAGE)

  # FIXME what if returns no results?
  haml :lookup_result
end

get '/summary' do
  # get latest/oldest records
  @latest_date = @@_ds.order(:FIRST_SEEN).get(:FIRST_SEEN)
  @oldest_date = @@_ds.reverse_order(:FIRST_SEEN).get(:FIRST_SEEN)

  # count expiring TTLs per RR
  # FIXME what if now result
  # FIXME it is not accurate, is it useful?
  @low_ttls = @@_ds.group_and_count(:QUERY).having{count >= 10}.where(:TTL <= 60).reverse_order(:count)

  # show distribution of maptype(A,PTR,CNAME,etc)
  @maptypes = @@_ds.group_and_count(:MAPTYPE)

  haml :summary
end


# some static pages
get '/about' do
  haml :about
end

# send browser something
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

# FIXME just test page to figure out a fancy tooltip
get '/tooltip' do
  haml :tooltip
end
