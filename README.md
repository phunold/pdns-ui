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

## Configuration
- supply database information in file: **config/database.yml**

````Bash
  adapter: mysql
  host: localhost
  username: pdns
  password: pdns
  database: pdns
````

- change application look and feel to your liking: **config/app.yml**

````Bash
    per_page: 100                          # number of rows per page
    short_date_format: "%T %F"             # date format 'strftime'
    long_date_format: "%a, %d %b %Y %T %z" # date format 'strftime'
````

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
- check install requirements on RPM based systems
- check how it feels with large table (+1M records)
- escape special characters for html/link
- add more unit tests RSPEC
