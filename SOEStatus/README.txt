Needs:

better sort of servers, allowing for region/name
refresh control within server list
display of age, taking into account time of last refresh


Accesses the SOE server status data at https://lp.soe.com/json/status/, correctponding to the server status page at http://www.soe.com/status/

Uses code from:

ASIHTTPRequest
Matt Drance's book "iOS Recipes"
Stig Brautaset's JSON library
Apple (Reachability)
PullRefreshTableViewController (Leah Culver)
and a couple of others //TODO: update with details!

Response is a JSON object, containing keys representing games.  The game object contains regions, which contain servers.  
Servers have age (time, as hh:mm:ss) and status (low, medium, high, locked).