README for Daybreak Status
==========================

An iPhone/iPad app to check the status of Daybreak Games game servers.

If you use this app and find it helpful, please take the time to give us a good review.  Good reviews encourage us to keep adding new features!

If you find any problems, please use the Feedback menu to report them to me directly.  Or fix them yourself - the code is, as ever, available for you on github at https://github.com/pauldlynch/SOEStatus.

If you want to receive notifications when your servers go up or down, just tap on the icon at the right of the server cell.  You will see a green tick mark before the server name if this is active.  Notifications will only be sent when the app isn't currently active, and only if you have given the app permission to send you notifications.  If you want to change your mind for any reason, look in Settings->Notifications.

We added a great new tool to get information about your server: just tap on the server name to see a chart of the last thirty days, and a 24 hour average population by hour.  This lets you see when any server is most active, and how much downtime there has been in the past month.


Needs:
------

- Reachability checks for known Daybreak servers to identify network outages vs server status.


3.2
----
Minor update to add in iPhone X launch images and change History location url.


3.1
-----

iPad game images are now sourced from imgur as well as flickr. These are pulled up in random order now.


3.0
_____


Revised the UI to allow access to the sliding images view for iPhone users.  The makes use of UISplitViewController, and necessitates a minimum OS level of iOS 8.  The image view will also persist images for the last game that you selected, making things better for people who only play one game.

If you read the code, there are some situations where I have delegate methods in controllers where they don't belong; I'd like to refactor that at some point.

2.2.1
-----
Fix for iPad version so that menu displays by default on launch


2.2
---

Switch to census.daybreakgames.com from data.soe.com.  This was an unannounced change by Daybreak: although actually, it was announced - "It was on display in the bottom of a locked filing cabinet stuck in a disused lavatory with a sign on the door saying ‘Beware of the Leopard.” - better known as the Planetside2 forums.


2.1
---

Rebuild to use auto-layout to correct some intractable view resizing issues.  Took the opportunity to catch up with the name change from SOE to Daybreak Games.


2.0.2
-----

Bug fixes, including possible crash when monitoring historical data for H1Z1.  Also adds in H1Z1.

2.0
---

Further changes to better support iOS 8 and the forced updates to nibs for the latest builds of Xcode.  General refactoring to create an SOEServer class.  Code to support local notifications for changes in server status (up/down).

1.9.3
-----

Add share as PDF option for charts.

1.9.2
-----
No changes to binary: update needed in app store to show new screenshots.

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


