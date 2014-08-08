README for SOE Status
=====================

An iPhone/iPad app to check the status of SOE game servers.

If you find any problems, please use the Feedback menu to report them to me directly.  Or fix them yourself - the code is, as ever, available for you on github at https://github.com/pauldlynch/SOEStatus.


Needs:
------

- Possibility to register for notifications of server status changes;
- Reachability checks for known SOE servers to identify network outages vs server status.


1.9.1
-----
Improve chart label sizes, fix some missing values caused by a new server status code from SOE, and fix the summary hour average; the old calculation gave plausible looking numbers that were horribly wrong.
 
1.9
---
First version including population charts.  For every game and every server, shows a 30 day history of population, and an averaged population by hour.  Subsequent releases may change this to an In App Purchase.  However, source code will always be available on GitHub.


1.6.2
-----

Update messages for when SOE servers are unavailable.


1.6.1
-----

Handle iOS7's very awkward status bar clash with top toolbars, by using the iOS6/7 delta values.

1.6
---

Update for iOS7.  Still supports iOS6.  A lot of the changes are just launch images and icons in additional resolutions.  The popovers are now smarter at sizing themselves for their content.

1.5
---

This release for the iPhone tidies up some old code, and shouldn't have any obvious changes.  On the iPad, however, I was bored with the oversized iPhone UI.  This release moves the status information to a popover window, and fills the background with an animated, "Ken Burns" style, game appropriate, rotating set of images selected from Flickr.  Enjoy them while waiting for servers up!

Update iPad version to present the status information in a popover, and present a Ken Burns animation of relevant images from Flickr in the background.

Update various 3rd party code to modern iOS (ARC, etc), and remove obsolete code.

1.4.1
-----

Updates for Planetside 2.

1.4
---

Support for Xcode 4.5 building.

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

- AFNetworking
- Matt Drance's book "iOS Recipes"
- Apple (Reachability)
- PullRefreshTableViewController (Leah Culver)
- and a couple of others //TODO: update with details!

RESTful access is based on my own generic code (PLRestful), subclassed to add specific support for the SOE feed.

Connecting to GitHub:
http://www.leniel.net/2011/08/xcode-iphone-beginner-projects-git.html

[Markdown](http://daringfireball.net/projects/markdown/basics)

Response is a JSON object, containing keys representing games.  The game object contains regions, which contain servers.  
Servers have age (time, as hh:mm:ss) and status (low, medium, high, locked). I create in the server controller 
extra keys for sortKey (region/server) and date (actual NSDate timestamp).

Can download the json into unique timestamped files via:

/usr/bin/curl http://data.soe.com/json/status/ file_$(date +'%Y%m%d%H%M%S').json

e.g.

sudo touch /etc/crontab
crontab -e
MAILTO="paul@plsys.co.uk"
0 * * * * /usr/bin/curl http://data.soe.com/json/status/ > /Volumes/Macintosh_HD_2/Projects/SOE_logs/file_$(date +'%Y%m%d%H%M%S').json


