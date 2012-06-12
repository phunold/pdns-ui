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

- Fedora/RedHat/CentOS
  * required RPMs pending, big sorry!

- Get code and install dependencies

````Bash
$ git clone git://github.com/phunold/pdns-ui.git
$ sudo bundle install
````

## Configuration

- supply database information in file: **config/database.yml**

````Bash
  adapter: mysql
  host: localhost
  username: pdns
  password: pdns
  database: pdns
````

- OPTIONAL! change application look and feel to your liking: **config/app.yml**

````Bash
per_page: 80                           # number of rows per page
short_date_format: "%T"                # this is for today's date
long_date_format: "%Y-%m-%d at %T"     # format of all other dates
human_readable_counter: true           # set to 'false' for exact counter
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
