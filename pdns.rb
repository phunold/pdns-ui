#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'sinatra'
require 'sequel'
require 'haml'
require 'will_paginate'
require 'will_paginate/sequel'
require 'rack-flash'

# non-gem require
require 'config/init'

class App < Sinatra::Application

  configure do
    enable :sessions
    use Rack::Flash

    # FIXME Global vars should probably be in a config file
    AppVersion = "0.1draft"
    FlowsPerPage = 50
  end

  # count number of rows
  before do
    @counter = Pdns.count
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

    haml :lookup_result
  end

  # FIXME add TTL value to advanced search
  get '/advanced_search' do
    # group unique for dropdown menu
    @rrs = Pdns.group(:RR).order(:RR)
    @maptypes = Pdns.group(:MAPTYPE).order(:MAPTYPE)
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
                         :last_seen =>last_seen)

puts @search.inspect
puts @search.valid?

    # go back if search is not valid
    flash[:warning] = @search.errors.full_messages
puts flash[:warning].inspect
puts flash[:warning].class

    redirect back unless @search.valid?

    # start to stick together sql statement (logical AND)
    @records = Pdns
    @records = @records.where(:QUERY.like("%#{query}%")) unless query.empty?
    @records = @records.where(:ANSWER.like("%#{answer}%")) unless answer.empty?
    @records = @records.filter(:RR => rr) unless rr.empty?
    @records = @records.filter(:MAPTYPE => maptype) unless maptype.empty?
    @records = @records.filter(:FIRST_SEEN >= Date.parse(first_seen))
    @records = @records.filter(:LAST_SEEN <= Date.parse(last_seen))

    # Final sql statement
    @records = @records.reverse_order(:LAST_SEEN).paginate(page,FlowsPerPage)

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

    # show NXDOMAIN answers
    @nxdomains = Pdns.where(:ANSWER.like("NXDOMAIN")).group_and_count(:QUERY).reverse_order(:count)

    haml :summary
  end


  # some static pages
  get '/about' do
    @version = AppVersion
puts "version: #{@version}"

    haml :about
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

end
