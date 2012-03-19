README for SOE Status
=====================

An iPhone/iPad app to check the status of SOE game servers.


Needs:
------

- Possibility to register for notifications of server status changes;
- Reachability checks for known SOE servers to identify network outages vs server status.

1.2
---

- updates to sharing, for mail and twitter (requires iOS 5.0+)
- rating system
- feedback option
- improve UX for Open in Safari

1.1.1
-----
- switch from lp.soe.com to data.soe.com (permanent home)
- added Clone Wars to games plist

1.1
---
- Icon! 57x, 114x, 75x, 512x
- review for iPad usage
- updates for iOS 5 and Xcode 4.2.

1.0
---
- base release


Accesses the SOE server status data at `https://data.soe.com/json/status/`, corresponding to the server status page at `http://www.soe.com/status/`

###Uses code from:

- ASIHTTPRequest
- Matt Drance's book "iOS Recipes"
- Stig Brautaset's JSON library
- Apple (Reachability)
- PullRefreshTableViewController (Leah Culver)
- Buzz Andersen's SFHFKeychainUtils
- and a couple of others //TODO: update with details!

RESTful access is based on my own generic code (PLRestful), subclassed to add specific support for the SOE feed.

Connecting to GitHub:
http://www.leniel.net/2011/08/xcode-iphone-beginner-projects-git.html

[Markdown](http://daringfireball.net/projects/markdown/basics)

Response is a JSON object, containing keys representing games.  The game object contains regions, which contain servers.  
Servers have age (time, as hh:mm:ss) and status (low, medium, high, locked). I create in the server controller 
extra keys for sortKey (region/server) and date (actual NSDate timestamp).