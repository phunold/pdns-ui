# ROADMAP

## 0.1 
- add some special reports to navigation (NXDOMAIN, blank query string, I18n domains, CHAOS, etc.)
- add more dynamic searches/menus (ie: filter by "XYZ")
- add basic on-demand lookup feature (whois,DNS,etc.)
- performance improvements

## 0.2
- add more special reports (IPv6 RSN abusers,'long' Queries and TXT, character rule violation, etc.)
- additional stats where it makes sense
- optional user access control
- integration with PassiveDNS alert-log

## 0.5 
- interesting "advanced search" can be stored/shared
- introduce API to read data with optional access control
- add IP/Domain reputation and blacklist on demand lookup
- user can costumize views
- add more stats/graphs
- ability to deal with DNS information gathered by multiple sensors running PassiveDNS
- introducing detection of suspicious DNS activity and alerting beyond a blacklist

## Think Tank
- some stats and reports
  * new RR per unique domain, new IP addresses)
  * domain name vs. query name, domain name vs. TLD
  * client addr vs. return codes
  * Opcodes(query vs. STATUS,IQUERY,NOTIFY,UPDATE)
  * reponse code vs response length vs overall message length
  * transport vs query type, ipv4 vs ipv6
  * grouped by ccTLD, gTLD and TLD
  * grouped by 2nd level and 3rd level domains
  * list domains with 4 or more levels (foo.bar.bad.hack.com) 
  * fast-flux,domain generation algorithms(DGA)
  * common DNS servers used by hackers(appears to not exist! and able to use well known domain, like google.com, fluxing domain names)
  * highlight and group some special domains (CDN domains, dynamic domains, popular domains)
  * covert comm, rogue servers, roque ISPs, DNS poisoning/pharming/redirection/hijacking, enumeration/scans, subdomain anomalies
  * display sensitive information DNS queries may hold (software used, partners, email, OS detection, etc.)

- some on demand information lookups
  * other ip ranges ISP provides
  * traceroute/BGP Prefix/ASN/GeoIP
  * Website/server details if available
  * website scans(bogon,SPF,SBL,DNSBL,DROP,URIBL,SNARE,NOTOS,etc.)
    * malwaredomains.com nice blacklist..., incorporates lots of sources...
    * malwaredomainlist.com
    * virustotal.com
    * ET RBN
    * autoshun.org (collaboration snort logs...)
    * abuse.ch some nice special interest blacklists(zeus,etc.)
    * cymr. bogons
    * google safe browsing
    * norton safe web
    * phish tank
    * geo-trust (used by opera browser), antimalware website scan (by Symantec)
    * sucuri.net Blacklist - ip/domains and site scan/check
    * unmaskparasites.com website scan (nice listing of external refernces!)
      * use: http://ww.unmaskparasites.com/security-report/?page=example.com
    * labs.alienvault.com by OSSIM guys *detecting malware domains by syntax heuritstics

