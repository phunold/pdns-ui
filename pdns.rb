#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'data/init'

require 'haml'
require 'will_paginate'
require 'will_paginate/sequel'

configure do
  FlowsPerPage = 50
  #Calculate total number of records
  @@total = Pdns.count
end

# routes
get '/' do
  page = (params[:page] || 1).to_i
  @records = Pdns.reverse_order(:LAST_SEEN).paginate(page,FlowsPerPage)
  haml :listing
end

# exact lookup of DNS query
get '/q/:query' do
  page = (params[:page] || 1).to_i
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
  page = (params[:page] || 1).to_i
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

get '/search' do
  page = (params[:page] || 1).to_i
  @lookup = params[:search].strip

  # go back if search is not valid
  redirect back if @lookup == "search"

  # match case insensitive against 'query' OR 'answer' column
  @records = Pdns.where(:QUERY.ilike("%#{@lookup}%") | :ANSWER.ilike("%#{@lookup}%"))

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
  page = (params[:page] || 1).to_i
  terms = Array.new
  terms << answer     = params[:answer].strip
  terms << query      = params[:query].strip
  terms << rr         = params[:rr]
  terms << maptype    = params[:maptype]
  # FIXME this is quick and too dirty
  # make the advanced search parameters show up nicely at the top
  @lookup = terms.join(" ")

  first_seen = params[:first_seen].strip
  last_seen  = params[:last_seen].strip

  # go back if search is not valid
  redirect back if (answer == "any" && query == "any" && rr.empty? && maptype.empty? && first_seen == "YYYY-MM-DD" && last_seen == "YYYY-MM-DD")

  # start to chain filters (logical AND)
  @records = Pdns
  @records = @records.where(:QUERY.like("%#{query}%")) unless query == "any"
  @records = @records.where(:ANSWER.like("%#{answer}%")) unless answer == "any"
  @records = @records.filter(:RR => rr) unless rr.empty?
  @records = @records.filter(:MAPTYPE => maptype) unless maptype.empty?
  @records = @records.filter(:FIRST_SEEN < Date.parse(first_seen)) unless first_seen == "YYYY-MM-DD" or first_seen.empty?
  @records = @records.filter(:LAST_SEEN > Date.parse(last_seen)) unless last_seen == "YYYY-MM-DD" or last_seen.empty?

  @records = @records.reverse_order(:LAST_SEEN).paginate(page,FlowsPerPage)

  # FIXME what if returns no results?
  haml :lookup_result
end

get '/summary' do
  # get latest/oldest records
  @latest_date = Pdns.order(:FIRST_SEEN).get(:LAST_SEEN)
  @oldest_date = Pdns.reverse_order(:FIRST_SEEN).get(:FIRST_SEEN)

  # Top 10 Query
  @top_query = Pdns.group_and_count(:QUERY).reverse_order(:count).limit(10)

  # show distribution of maptype(A,PTR,CNAME,etc)
  @maptypes = Pdns.group_and_count(:MAPTYPE).reverse_order(:count)

  # Show NXDOMAIN answers
  @nxdomains = Pdns.where(:ANSWER.like("NXDOMAIN")).group_and_count(:QUERY).reverse_order(:count)

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
