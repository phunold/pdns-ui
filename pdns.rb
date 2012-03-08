#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'data/init'

require 'haml'
require 'will_paginate'
require 'will_paginate/sequel'

configure do
  FlowsPerPage = 50
  #FIXME make layout <title> dynamic
  @page_title = "PassiveDNS"
  #FIXME totals...fake
  @total = 123
  #FIXME should be able to put page default here too...
  page = 1
end

# routes
get '/' do
  page ||= params[:page].to_i ||= 1
  @records = Pdns.reverse_order(:LAST_SEEN).paginate(page,FlowsPerPage)
  haml :index
end

# exact lookup of DNS query
get '/q/:query' do
  page ||= params[:page].to_i ||= 1
  @lookup  = params[:query]
  @records = Pdns.where(:QUERY => @lookup).paginate(page,FlowsPerPage)

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
  page ||= params[:page].to_i ||= 1
  @lookup   = params[:answer]
  @records = Pdns.where(:ANSWER => @lookup).paginate(page,FlowsPerPage)


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
  page ||= params[:page].to_i ||= 1 

  # go back if search is not valid
  redirect back if @lookup == "search"

  # match loosly against 'query' OR 'answer' column
  @records = Pdns.where(:QUERY.like("%#{@lookup}%") | :ANSWER.like("%#{@lookup}%"))

  # create paginated records
  @records = @records.reverse_order(:LAST_SEEN).paginate(page,FlowsPerPage)

  # FIXME what if returns no results?
  haml :lookup_result

end

get '/advanced_search' do
  # group unique for dropdown menu
  @rrs = Pdns.group(:RR).order(:RR)
  @maptypes = Pdns.group(:MAPTYPE).order(:MAPTYPE)
  haml :advanced_search
end

get '/advanced_search_result' do
  terms = Array.new
  terms << answer  = params[:answer].strip
  terms << query   = params[:query].strip
  terms << rr      = params[:rr]
  terms << maptype = params[:maptype]
  page ||= params[:page].to_i ||= 1

  # FIXME this is quick and too dirty
  # make the advanced search parameters show up nicely at the top
  @lookup = terms.join(" ")

  # go back if search is not valid
  redirect back if (answer == "any" && query == "any" && rr.empty? && maptype.empty?) 

  # start to chain filters (logical AND)
  @records = Pdns
  @records = @records.where(:QUERY.like("%#{query}%")) unless query == "any"
  @records = @records.where(:ANSWER.like("%#{answer}%")) unless answer == "any"
  @records = @records.filter(:RR => rr) unless rr.empty?
  @records = @records.filter(:MAPTYPE => maptype) unless maptype.empty?
  @records = @records.filter(:MAPTYPE => maptype) unless maptype.empty?

  @records = @records.reverse_order(:LAST_SEEN).paginate(page,FlowsPerPage)

  # FIXME what if returns no results?
  haml :lookup_result
end

get '/summary' do
  # get latest/oldest records
  @latest_date = Pdns.order(:FIRST_SEEN).get(:FIRST_SEEN)
  @oldest_date = Pdns.reverse_order(:FIRST_SEEN).get(:FIRST_SEEN)

  # count expiring TTLs per RR
  # FIXME what if now result
  # FIXME it is not accurate, is it useful?
  @low_ttls = Pdns.group_and_count(:QUERY).having{count >= 10}.where(:TTL <= 60).reverse_order(:count)

  # show distribution of maptype(A,PTR,CNAME,etc)
  @maptypes = Pdns.group_and_count(:MAPTYPE)

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
#  not_found do
#    haml :sorry
#  end

# error handling 500
#  error do
#    haml :sorry
#  end

# FIXME just test page to figure out a fancy tooltip
get '/tooltip' do
  haml :tooltip
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
