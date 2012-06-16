# WebUI for passivedns

**Minimalistic WebUI for passiveDNS tool by gamelinux.**

This app is built with:
* sinatra web development framework (http://sinatrarb.com)
* bootstrap, from twitter (http://twitter.github.com/bootstrap/)

## Demo

http://pdns.tklapp.com:8123/
````Bash
Username: pdns
Password: demo1
````

## Install

- Ubuntu 12.04:
````Bash
    apt-get install mysql-client libmysqlclient-dev ruby rubygems
    gem install bundler --no-ri --no-rdoc
````

- Ubuntu 10.04: 

````Bash
$ apt-get install libmysqlclient16 ruby ruby-dev rubygems libruby libruby-extras
# you need to install latest rubygem manually ( >= v1.3.6)
$    gem install rubygems-update
$    cd /var/lib/gems/1.8/bin && ./update_rubygems
 $  gem install bundler --no-ri --no-rdoc
`````

- Fedora16
$ yum install ldns ldns-devel libpcap-devel openssl-devel ruby rubygems rubygem-bundler rubygem-rack libffi-devel libffi mysql-devel

- Get code and install dependencies

````Bash
$ git clone git://github.com/phunold/pdns-ui.git
$ sudo bundle install
````

## Configuration

- supply database information in file: **config/database.yml**

````Bash
$ cp config/database.yml.example config/database.yml
  adapter: mysql
  host: localhost
  username: pdns
  password: pdns
  database: pdns
````

- change application look and feel to your liking: **config/app.yml**

````Bash
$ cp config/app.yml.example config/app.yml
# Application Version
version: v0.0.5
# Application Look
per_page: 80                           # number of rows per page
short_date_format: "%T"                # this is for today's date
long_date_format: "%Y-%m-%d at %T"     # format of all other dates
human_readable_counter: true           # set to 'false' for exact counter
# Google Safebrowings
gsafebrowsing_enable: false            # set to 'true' to enable
gsafebrowsing_apikey: 'API-KEY'        # provide Google's API key
gsafebrowsing_url: 'https://sb-ssl.google.com/safebrowsing/api/lookup'
gsafebrowsing_version: '3.0'           # Google's Safebrowsing Lookup API Release
````

## Usage

- Running for development using test:

````Bash
$ rackup
http://localhost:9292/
````

- Or running with Passenger aka modrails

````Bash
$ sudo aptitude install libapache2-mod-passenger
$ cat /etc/apache2/sites-enabled/pdns
<VirtualHost *:80>
    ServerName pdns.example.com
    DocumentRoot /home/pdns-ui/public
    <Directory /home/pdns-ui/public>
        Allow from all
        Options -MultiViews
    </Directory>
</VirtualHost>
````
for more details visit:
http://www.modrails.com/documentation/Users%20guide%20Apache.html

## TODO
- update install requirements on RPM based systems
- add more unit tests
* anything else check ROADMAP

## Feedback

Open for feedback, suggestions and wishes...
