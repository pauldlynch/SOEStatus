Needs:

Icon! 57x, 114x, 75x, 512x
review for iPad usage

Accesses the SOE server status data at https://lp.soe.com/json/status/, correctponding to the server status page at http://www.soe.com/status/

Uses code from:

ASIHTTPRequest
Matt Drance's book "iOS Recipes"
Stig Brautaset's JSON library
Apple (Reachability)
PullRefreshTableViewController (Leah Culver)
and a couple of others //TODO: update with details!

Connecting to GitHub:
http://www.leniel.net/2011/08/xcode-iphone-beginner-projects-git.html

Response is a JSON object, containing keys representing games.  The game object contains regions, which contain servers.  
Servers have age (time, as hh:mm:ss) and status (low, medium, high, locked). I create in the server controller 
extra keys for sortKey (region/server) and date (actual NSDate timestamp).