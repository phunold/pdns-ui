#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'sequel'
require 'haml'
require 'will_paginate'
require 'will_paginate/sequel'
require 'rack-flash'
require 'net/dns'

# non-gem require
require 'config/application_helper'

class App < Sinatra::Base

  configure do
    enable :sessions
    use Rack::Flash
    register WillPaginate::Sinatra
    register Sinatra::ConfigFile
    register Sinatra::Reloader
    config_file 'config/app.yml'
    config_file 'config/database.yml'
    DB = Sequel.connect "#{settings.adapter}://#{settings.username}:#{settings.password}@#{settings.host}/#{settings.database}"
  end

  before do
    # first execution of sql command
    # so let's make sure database configuration is ok
    # otherwise just die ungracefully with HTTP 500
    begin
      # database counter for all pages
      @counter  = Pdns.count
    rescue Sequel::DatabaseConnectionError
      halt 500, "Database error, please check database settings"
    end

    # get all MAPTYPEs aka DNS Query Types (CNAME,A,SOA,MX,etc) for navigation
    # dropdown menu on all pages
    @maptypes = Pdns.group(:MAPTYPE).map(:MAPTYPE)
  end

  # routes
  get '/' do
    page = (params[:page] || 1).to_i
    @records = Pdns.reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "No Filters applied"
    haml :listing
  end
  
  # FIXME this is not linked anywhere, still testing
  get '/grouped' do
    page = (params[:page] || 1).to_i
    @records = Pdns.order(:QUERY,:ANSWER).paginate(page,settings.per_page)
    @grouped = @records.to_hash_groups(:QUERY)
    haml :grouped
  end

  # exact lookup of DNS query
  get '/q/:query' do
    page = (params[:page] || 1).to_i
    @lookup  = params[:query]

    # empty QUERY string lookup produces 404 "page not found"
    # we use an unlikely string for empty/blank queries 
    if @lookup == "--blank--" then
      @records = Pdns.where(:QUERY => '')
    else  
      @records = Pdns.where(:QUERY => @lookup)
    end
    @records = @records.reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Query:"
    haml :lookup_result
  end

  # exact lookup of DNS answer
  get '/a/:answer' do
    page = (params[:page] || 1).to_i
    @lookup   = params[:answer]
    @records = Pdns.where(:ANSWER => @lookup).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Response:"
    haml :lookup_result
  end

  # list of specific DNS Type aka MAPTYPE
  get '/t/:type' do
    page = (params[:page] || 1).to_i
    @lookup   = params[:type]
    @records = Pdns.where(:MAPTYPE => @lookup).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Query Type:"
    haml :listing
  end

  # list of specific DNS ResourceRecord aka RR
  get '/r/:resource' do
    page = (params[:page] || 1).to_i
    @lookup   = params[:resource]
    @records = Pdns.where(:RR => @lookup).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Resource Record:"
    haml :listing
  end

  get '/search' do
    page = (params[:page] || 1).to_i
    @lookup = params[:search].strip

    # go back if search is not valid
    redirect back if @lookup.empty?

    # match case insensitive against 'query' OR 'answer' column
    @records = Pdns.where(:QUERY.ilike("%#{@lookup}%") | :ANSWER.ilike("%#{@lookup}%"))
    @meta = "Search Query and Response for:"

    # create paginated records
    @records = @records.reverse(:LAST_SEEN).paginate(page,settings.per_page)
    haml :lookup_result
  end

  # FIXME add TTL value to advanced search
  get '/advanced_search' do
    # group ResourceRecord for form select-option input
    @rrs = Pdns.group(:RR).map(:RR)
    # all Maptypes already parsed from navigation menu
    haml :advanced_search
  end

  get '/advanced_search_result' do
    page = (params[:page] || 1).to_i
    query      = params[:query].strip
    answer     = params[:answer].strip
    maptype    = params[:maptype].chomp("...")
    rr         = params[:rr].chomp("...")
    first_seen = params[:first_seen].strip
    last_seen  = params[:last_seen].strip

    @search = Search.new(:query     =>query,
                         :answer    =>answer,
                         :first_seen=>first_seen,
                         :last_seen =>last_seen,
                         :rr        => rr,
                         :maptype   => maptype)

    # check validation, populates errors
    # and go back if search is not valid
    @search.validate
    flash[:warning] = @search.errors.full_messages
    redirect back unless @search.valid?
    
    # Final sql statement
    @records = @search.construct_sql(Pdns).paginate(page,settings.per_page)
    @meta = "Woohoo! You just did an &#39;Advanced Search&#39;:"
    @lookup = "FIXME"

    haml :lookup_result
  end

  get '/summary' do
    # get latest/oldest records
    @latest_date = Pdns.order(:FIRST_SEEN).get(:LAST_SEEN)
    @oldest_date = Pdns.reverse(:FIRST_SEEN).get(:FIRST_SEEN)

    # FIXME stats need improvement, dont have good ideas yet!
    # and we have "wrong" numbers of rows because of caching

    # Top 10 Query
    @top_query = Pdns.group_and_count(:QUERY).reverse(:count).limit(10)

    # show distribution of maptype(A,PTR,CNAME,etc)
    @maptypes = Pdns.group_and_count(:MAPTYPE).reverse(:count)

    haml :summary
  end

  # on-demand lookups
  
  # simple dns lookup
  get '/ondemand/dns/:name' do
    @lookup = params[:name]
    @meta = "Name lookup"
    @result = Resolver(params[:name])
    haml :ondemand_result, :layout => false
  end

  # some static pages
  get '/about' do
    @version = settings.version
    haml :about
  end
  # FIXME: just for testing
  get '/tooltip' do
    haml :tooltip
  end

  # send browser something
  get '/favicon.ico' do
  end

  # error handling 404
  not_found do
    haml :not_found
  end

  get '/dns' do
    p Resolver('www.google.com')
  end

  # error handling 500
  error do
    haml :sorry
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

  # FIXME 'require' seems a little misplaced here
  # but it works, and at the top of this file it didn't...
  require 'config/models.rb'
end
