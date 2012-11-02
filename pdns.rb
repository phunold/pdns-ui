#!/usr/bin/env ruby -w

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
require 'net/ping'
require 'whois'
require 'action_view'
include ActionView::Helpers::NumberHelper
require 'rest_client'
require 'simpleidn'

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
    DB = Sequel.connect(:adapter  => settings.adapter,
			:host     => settings.host,
			:database => settings.database,
			:user     => settings.username,
			:password =>"#{settings.password}")
  end

  before do
    # first execution of sql command
    # so let's make sure database configuration is ok
    # otherwise just die ungracefully with HTTP 500
    begin
      # database counter for all pages
      @counter ||= session[:counter] ||= Pdns.count
    rescue Sequel::DatabaseError => e
      halt 500, "Database error: #{e.message}"
    rescue Sequel::DatabaseConnectionError => e
      halt 500, "Database error, please check database settings: #{e.message}"
    end

    # get all MAPTYPEs aka DNS Query Types (CNAME,A,SOA,MX,etc) for navigation
    # dropdown menu on all pages
    @maptypes ||= session[:maptypes] ||= Pdns.group(:MAPTYPE).map(:MAPTYPE)
  end

  # routes
  get '/' do
    page = (params[:page] || 1).to_i
    @records = Pdns.reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "No Filters applied"
    haml :short_listing
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
    # Internationalized Domain beginning with 'xn--'
    elsif @lookup == "xn--" then
      @records = Pdns.filter(:QUERY.ilike("xn--%"))
    else
      @records = Pdns.where(:QUERY => @lookup)
    end
    @records = @records.reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Query:"
    haml :long_listing
  end

  # exact lookup of DNS answer
  get '/a/:answer' do
    page = (params[:page] || 1).to_i
    @lookup   = params[:answer]
    @records = Pdns.where(:ANSWER => @lookup).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Response:"
    haml :long_listing
  end

  # list of specific DNS Type aka MAPTYPE
  get '/t/:type' do
    page = (params[:page] || 1).to_i
    @lookup   = params[:type]
    @records = Pdns.where(:MAPTYPE => @lookup).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Query Type:"
    haml :short_listing
  end

  # list of specific DNS ResourceRecord aka RR
  get '/r/:resource' do
    page = (params[:page] || 1).to_i
    @lookup   = params[:resource]
    @records = Pdns.where(:RR => @lookup).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Resource Record:"
    haml :short_listing
  end

  get '/search' do
    page = (params[:page] || 1).to_i
    @lookup = params[:search].strip

    # go back if search is not valid
    redirect back if @lookup.empty?
    
    #:QUERY.ilike("%#{@lookup}%")) | (:ANSWER.ilike("%#{@lookup}%"))"
    # create "in-addr.arpa" to match PTR address too
    if @lookup =~ /^[0-9]{1,3}\./
      in_addr_arpa_str = @lookup.split(".").reverse.join(".")
      @records = Pdns.filter([:QUERY, :ANSWER].sql_string_join.ilike("%#{@lookup}%","#{in_addr_arpa_str}%"))
      @meta = "Search Query and Response for (incl in_addr_arpa):"
    else
      # match case insensitive against 'query' OR 'answer' column
      @records = Pdns.filter([:QUERY, :ANSWER].sql_string_join.ilike("%#{@lookup}%"))
      @meta = "Search Query and Response for:"
    end

    @records = @records.reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @records.empty? ? (haml :sorry) : (haml :short_listing)
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

    # FIXME overkill/hack! Is giving sql-error on startup, validate still works for my purpose
    # Mysql::Error: Table 'pdns.searches' doesn't exist: DESCRIBE `searches`
    # Mysql::Error: Table 'pdns.searches' doesn't exist: SELECT * FROM `searches` LIMIT 1
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
    # FIXME flash still a bit clumsy and doesnt make much sense with history.back() .js
    flash[:warning] = nil
    @meta = "Woohoo! You just did an &#39;Advanced Search&#39;:"
    # FIXME should display excerpt of what was searched for
    @lookup = "FIXME"
    if @records.empty? then
      @back_btn = "Try Again"
      haml :sorry
    else
      @back_btn = "Refine Search"
      haml :short_listing
    end
  end

  get '/summary' do
    # get latest/oldest records
    @oldest_date = Pdns.order(:FIRST_SEEN).get(:FIRST_SEEN)
    @newest_date = Pdns.reverse(:LAST_SEEN).get(:LAST_SEEN)

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
    # create resolver object(uses system defaults)
    res = Net::DNS::Resolver.new
    begin
      @result = res.query(@lookup)
    rescue Net::DNS::Resolver::NoResponseError
      @nameservers = res.nameservers
      @result = false
    end 

    # open as .js modal window
    haml :ondemand_dns, :layout => false
  end
  # ICMP ping (IP or NAME)
  get '/ondemand/ping/:ip' do
    @lookup = params[:ip]
    @meta = "Pinging IP/Host:"
    @ping = Net::Ping::External.new(@lookup)
    # open as .js modal window
    haml :ondemand_ping, :layout => false
  end

  # whois lookup
  get '/ondemand/whois/:domain' do
    @lookup = params[:domain]
    @meta = "Whois Domain lookup:"
    c = Whois::Client.new(:timeout => 3)
    @whois = c.query(@lookup)
    # open as .js modal window
    haml :ondemand_whois, :layout => false
  end

  # google safebrowsing lookup
  get '/ondemand/safebrowsing/:domain' do
    @lookup = params[:domain]
    @meta = "Google Safebrowsing lookup:"
    @safebrowsing = RestClient.post settings.gsafebrowsing_url + "?" + 
                                    "client=pdns" + 
                                    "&apikey=" + settings.gsafebrowsing_apikey + 
                                    "&appver=" + settings.version + 
                                    "&pver="   + settings.gsafebrowsing_version,
                                    "1\n#{@lookup}"
    # open as .js modal window
    haml :ondemand_safebrowsing, :layout => false
  end

  # some static pages
  get '/about' do
    @version = settings.version
    haml :about
  end

  # send browser something
  get '/favicon.ico' do
  end

  # error handling 404
  not_found do
    halt 404, "Sorry, could not found this page."
  end

  # error handling 500
  error do
    halt 500, "Something went terribly wrong. Please report this issue!"
  end

  # FIXME 'require' seems a little misplaced here
  # but it works, and at the top of this file it didn't...
  require 'config/models.rb'
end
