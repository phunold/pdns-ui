# WebUI for passivedns

**Minimalistic WebUI for passiveDNS tool by gamelinux.**

This app is built on (http://sinatrarb.com)

## Install

- Ubuntu:
````Bash
  sudo apt-get install mysql-client libmysqlclient-dev ruby rubygems
  sudo bundle install
````

- Ubuntu 10.04: install latest rubygem manually:
  http://qastuffs.blogspot.com/2010/11/installing-gem-bundler-in-ubuntu-1004.html

## Configure DB
- supply database information in file: data/database.yaml

## Usage

- Running for development or test:

````Bash
    rackup
````

- point your browser to:

````Bash
    http://localhost:9292/
````

- Or running with Passenger aka modrails

## TODO
- reconsider date format, is US-style right now (MM-DD !)
- create test scripts, RIOT or whatever may be a good fit
- check install requirements on RPM based systems
- check how it feels with large table (+1M records)
- more error handling, like mysql database (Sequel::DatabaseConnectionError,Sequel::DatabaseConnectionError)
- check out sinatra/contributions in sinatra 1.3.2
- add environment configuration development/test/production similar what Rails does
