# WebUI for passivedns

**Minimalistic WebUI for passiveDNS tool by gamelinux.**

This app is built on (http://sinatrarb.com)

## Install

- Ubuntu:
  apt-get install mysql-client libmysql-ruby libsinatra-ruby rubygems libsinatra-ruby libhaml-ruby libsqlite3-dev libsequel-ruby
  gem install will_paginate --no-ri --no-rdoc

## Configure DB
  - supply database information in file: data/database.yaml

## Usage

- Running for development or test:
    ruby pdns-ui.rb

- point your browser to:
    http://localhost:4567/

- Or running with Passenger aka modrails

## TODO
- use form validation helper for 'advanced search' page
- reconsider date format, is US-style right now (MM-DD !)
- create test scripts, RIOT or whatever may be a good fit
- check install requirements on RPM based systems
- check how it feels with large table (+1M records)
