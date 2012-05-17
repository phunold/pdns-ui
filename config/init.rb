require 'rubygems'
require 'sequel'
require 'yaml'

# connect to database with configuration
db_data = File.new("config/database.yml").read
db_cfg = YAML::load db_data
DB = Sequel.connect "#{db_cfg['adapter']}://#{db_cfg['username']}:#{db_cfg['password']}@#{db_cfg['host']}/#{db_cfg['database']}"

require 'config/models.rb'
