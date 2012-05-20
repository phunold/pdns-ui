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

# non-gem require
#require 'config/init'

class App < Sinatra::Base

  configure do
    enable :sessions
    use Rack::Flash
    register WillPaginate::Sinatra
    register Sinatra::ConfigFile
    config_file 'config/app.yml'
    config_file 'config/database.yml'
    DB = Sequel.connect "#{settings.adapter}://#{settings.username}:#{settings.password}@#{settings.host}/#{settings.database}"
    register Sinatra::Reloader
  end


  # count number of rows
  before do
    @counter  = Pdns.count
    @rrs      = Pdns.group(:RR).order(:RR)
    @maptypes = Pdns.group(:MAPTYPE).order(:MAPTYPE)
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
    @records = Pdns.group_and_count(:QUERY).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @members_list = Hash.new
    @records.each do |r|
      puts r.values
    end
    @meta = "This is just a to test out a new view/layout"
    haml :grouped
  end

  # exact lookup of DNS query
  get '/q/:query' do
    page = (params[:page] || 1).to_i
    @lookup  = params[:query]
    @records = Pdns.where(:QUERY => @lookup).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Query:"

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
    @records = Pdns.where(:ANSWER => @lookup).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Response:"

    # lookup search should always give you a result
    # but lets just catch this anyway
    if @records.count >= 1 then
      haml :lookup_result
    else
      haml :sorry
    end
  end

  # list of specific DNS Type aka MAPTYPE
  get '/t/:type' do
    page = (params[:page] || 1).to_i
    @lookup   = params[:type]
    @records = Pdns.where(:MAPTYPE => @lookup).reverse(:LAST_SEEN).paginate(page,settings.per_page)
    @meta = "Filter by Query Type:"

    # lookup search should always give you a result
    # but lets just catch this anyway
    if @records.count >= 1 then
      haml :listing
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
    @meta = "Search Query and Response for:"

    # create paginated records
    @records = @records.reverse(:LAST_SEEN).paginate(page,settings.per_page)
    haml :lookup_result
  end

  # FIXME add TTL value to advanced search
  get '/advanced_search' do
    # group unique for dropdown menu
    #FIXME @rrs = Pdns.group(:RR).order(:RR)
    #FIXME @maptypes = Pdns.group(:MAPTYPE).order(:MAPTYPE)
    haml :advanced_search
  end

  get '/advanced_search_result' do
    page = (params[:page] || 1).to_i
    query      = params[:query]
    answer     = params[:answer]
    maptype    = params[:maptype]
    rr         = params[:rr]
    first_seen = params[:first_seen]
    last_seen  = params[:last_seen]

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
    @meta = "Woohoo! You've done an Advanced Search!"

    haml :lookup_result
  end

  get '/summary' do
    # get latest/oldest records
    @latest_date = Pdns.order(:FIRST_SEEN).get(:LAST_SEEN)
    @oldest_date = Pdns.reverse_order(:FIRST_SEEN).get(:FIRST_SEEN)

    # FIXME all stats are kinda useless, since the backend is caching!
    # Top 10 Query
    @top_query = Pdns.group_and_count(:QUERY).order(:count).limit(10)

    # show distribution of maptype(A,PTR,CNAME,etc)
    @maptypes = Pdns.group_and_count(:MAPTYPE).reverse(:count)

    # show NXDOMAIN answers
    @nxdomains = Pdns.where(:ANSWER.like("NXDOMAIN")).group_and_count(:QUERY).reverse(:count).limit(20)

    haml :summary
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
    haml :sorry
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
