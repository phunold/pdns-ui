# WebUI for passivedns

**Minimalistic WebUI for passiveDNS tool by gamelinux.**

This app is built on (http://sinatrarb.com)

## Install

- Ubuntu:
  apt-get install mysql-client libmysql-ruby libsinatra-ruby rubygems libsinatra-ruby libhaml-ruby libsqlite3-dev libsequel-ruby
  gem install will_paginate --no-ri --no-rdoc

## Usage

- start webserver:

    ruby pdns-ui.rb

- point your browser to:

    http://localhost:4567/


## TODO
- create test scripts, RIOT or whatever may be a good fit
- create conf for running in passenger
- make it look like a 'real' app and re-organise, introduce proper MVC, split Model/Controller/helpers
- make 'summary' page look nicer
- create detailed views with overlays and other eye candy
- check install requirements on RPM based systems
- show duplicate records for the same query
- use form validation helper for 'advanced search' page
