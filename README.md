# WebUI for passivedns

**Minimalistic WebUI for passiveDNS tool by gamelinux.**

This app is built on (http://sinatrarb.com)

## Install

- Ubuntu: apt-get install mysql-client libmysql-ruby libsinatra-ruby rubygems libsinatra-ruby libhaml-ruby libsqlite3-dev libsequel-ruby


## Usage

- start webserver:

    ruby pdns-ui.rb

- point your browser to:

    http://localhost:4567/


## TODO

...lot's to do let's start here:

- [failed] pagination
- detailed view of IP/host
- grouped view of MAPTYPE/RR to make unusal stick out a bit...
- add interactive ASN/WHOIS/TRACEROUTE/DNS lookup for IP/DOMAIN
- interactive query is url/domain/IP is in IP reputation/blacklist somewhere (virustotal,spamhause,cymru.org,etc)
- etc....

! there is no client-ip/server-ip in the database

## Feedback

Open for feedback, suggestions and wishes...
