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


## TODO and ThinkTank

Just thinking out loud, anything or nothing may be implemented. Some are totally out-of-scope.
 
- [failed] pagination
- detailed view of a query name including class/qtype/query length/IP(s)/TTL/Reponse Flags(Reply Codes,NXDOMAIN,Opcodes/Authorative/Recursive Flag/AXFR/do-bit and other extra data allocated with that query domain
- create view of domains grouped by ccTLD,gTLD and TLD, 2nd level and 3rd level domains
- create statistics
  * queries over time
  * new RR per unique domain, new unique IP addresses
  * client addr vs. return codes
  * Opcodes(query vs. STATUS,IQUERY,NOTIFY,UPDATE)
  * reponse code vs response length vs overall message length
  * domain name vs. query name, domain name vs. TLD
  * transport vs query type, ipv4 vs ipv6
- specialty reports
  * IPv6 RSN abuser
  * CHAOS names and classes 
  * internationalized domain names(non ASCII) starting with 'xn-'
  * check where forware DNS(A) doesn't match Reverse(PTR)
  * separate some specialty queries, i.e. root server queries, [a-m].root-servers.net
- on demand information lookup (registrar/whois/ip ranges,traceroute/BGP Prefix/ASN/GeoIP)
- on demand IP/Domain reputation and blacklist lookup (bogon,SPF,SBL,DNSBL,DROP,URIBL,SNARE,NOTOS,etc.)
- allow user to classify and group domains (i.e: popluar domains like facebook/google/etc., common domains according to alexa.com, CDN domains, dynamic domains(no-ip.com/dyn-dns.com,etc.)
- graphical interpretation of DNS data (tag-cloud, word-tree)
- display possible security issues (fast-flux,fwd lookup not match reverse,covert comm, rogue servers, DNS poisoning/pharming/redirection/hijacking, enumeration/scans, subdomain anomalies)
- display sensitive information DNS queries may hold (software used, partners, email, OS detection, etc.)

! there is no client-ip/server-ip in the database

## Feedback

Open for feedback, suggestions and wishes...
