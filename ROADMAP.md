## ThinkTank

Just thinking out loud, anything or nothing may be implemented.
This is waaaaay out-of-scope! Just want to do a 'brain-dump'.
 
- more detailed DNS query/response information including query length/IP(s)(server/client)/Reponse Flags(Reply Codes,NXDOMAIN,Opcodes/Authorative/Recursive Flag/IXFR,AXFR/do-bit and other extra data allocated with that query domain
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
  * check where forware DNS(A) doesnt match Reverse(PTR)
  * separate some specialty queries, i.e. root server queries, [a-m].root-servers.net or just 'blank' queries
  - on demand information lookup (registrar/whois/ISP,ip ranges,traceroute/BGP Prefix/ASN/GeoIP, Websitei/server details
  - on demand IP/Domain reputation and blacklist lookup and website scans(bogon,SPF,SBL,DNSBL,DROP,URIBL,SNARE,NOTOS,etc.)
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
- allow user to classify and group domains (i.e: popluar domains like facebook/google/etc., common domains according to alexa.com, CDN domains, dynamic domains(no-ip.com/dyn-dns.com,etc.)
- graphical interpretation of DNS data (tag-cloud, word-tree)
  * https://google-developers.appspot.com/chart/interactive/docs/gallery
  * http://www.highcharts.com/ 
- display possible security issues (fast-flux,domain generation algorithms(DGA),fwd lookup not match reverse,custom DNS servers used by hackers(appears to not exist! and able to use well known domain, like google.com, fluxing domain names), covert comm, rogue servers, roque ISPs, DNS poisoning/pharming/redirection/hijacking, enumeration/scans, subdomain anomalies)
- display sensitive information DNS queries may hold (software used, partners, email, OS detection, etc.)
  * list all domains which violate character rule /a-zA-z0-9\-/
  * list domains with 4 or more levels (foo.bar.bad.hack.com) 
  * allow user to create a 'watchlist', similar to a costumized view of capture DNS info
  * special view/list for TXT queries

## Feedback

Open for feedback, suggestions and wishes...
