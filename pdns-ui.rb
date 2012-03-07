#!/usr/bin/env ruby

require 'sinatra'
require 'rubygems'
require 'sequel'
require 'haml'

configure do
  set :bind, '192.168.56.101'

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

# index page / tabular listing of DNS records
get '/' do
  @records = @@_ds.reverse_order(:LAST_SEEN).limit(100)
  haml :index
end

# exact lookup of DNS query
get '/q/:query' do
  @search_term   = params[:query]
  @records       = @@_ds.filter(:QUERY => @search_term)
  @total_records = @records.count

  # lookup search should always give you a result
  # but lets just catch this anyway
  if @total_records >= 1 then
    haml :lookup_result
  else
    haml :sorry
  end
end

# exact lookup of DNS answer
get '/a/:answer' do
  @search_term   = params[:query]
  @records = @@_ds.filter(:ANSWER => params[:answer])
  @total_records = @records.count

  # lookup search should always give you a result
  # but lets just catch this anyway
  if @total_records >= 1 then
    haml :lookup_result
  else
    haml :sorry
  end
end

post '/search' do
  pattern = params['search'].strip

  # go back if search is not valid
  redirect back if pattern == "search"

  # match loosly against 'query' and 'answer' column
  @records = @@_ds.where(:QUERY.like("%#{pattern}%") | :ANSWER.like("%#{pattern}%"))

  @total_records = @records.count
  
  # limit records to 100 always
  @records = @records.reverse_order(:LAST_SEEN).limit(100)

  # render result
  haml :search_result

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
  @records = @@_ds
  @records = @records.where(:QUERY.like("%#{query}%")) unless query == "any"
  @records = @records.where(:ANSWER.like("%#{answer}%")) unless answer == "any"
  @records = @records.filter(:RR => rr) unless rr.empty?
  @records = @records.filter(:MAPTYPE => maptype) unless maptype.empty?
  @records = @records.filter(:MAPTYPE => maptype) unless maptype.empty?
  @total_records = @records.count

  # FIXME limit records to 100 until we have pagination
  @records = @records.reverse_order(:LAST_SEEN).limit(100)

  haml :searchresult
end

get '/summary' do
  # get latest/oldest records
  @latest_date = @@_ds.order(:FIRST_SEEN).get(:FIRST_SEEN)
  @oldest_date = @@_ds.reverse_order(:FIRST_SEEN).get(:FIRST_SEEN)

  # count expiring TTLs per RR
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
