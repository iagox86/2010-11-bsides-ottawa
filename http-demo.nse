-- -*- mode: lua -*-
-- vim: set filetype=lua :
-- The preceding lines should be left intact to help vim/emacs do syntax
-- highlighting

description = [[
Get the mac address of the target, and geolookup. 
]]

---
-- @usage
-- This section should simply be the Nmap command to run the script. eg:
-- nmap --script http-demo <host>
--
-- @output
--

-- Change the 'author' field to your name and handle. We no longer include email
-- addresses. 
author = "Ron and Bsides Audience"

-- Only change the license if you don't plan on submitting the plugin to be
-- included with Nmap. 
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"

categories = { "safe", "discovery", "external" }

-- NSELib libraries should be included here.
require 'stdnse'
require 'json'
require 'http'

---
-- Uncomment the following function to use a hostrule.
 hostrule = function( host )
   return true
 end

action = function( host, port )
  if(not(host.mac_addr)) then
    return 'error'
  end

  -- aa:bb:cc:dd:ee:ff
  local mac = ''
  for i=1, 5, 1 do
    mac = mac ..string.format("%02x:", string.byte(host.mac_addr, i))
  end
  -- Linksys has the bssid = mac + 2, so add 2 to the last byte of the mac_addr
  mac = mac ..string.format("%02x", string.byte(host.mac_addr, 6)+2)

  stdnse.print_debug(1, "Checking mac: %s", mac)

  local json_query = [[
 {
   "host" : "code.google.com",
   "radio_type" : "unknown",
   "request_address" : true,
   "version" : "1.1.0",
   "wifi_towers" :
   [ 
     {
       "mac_address" : "]] ..  mac .. [[",
       "signal_strength" : -80
     }
   ] 
 }
]]

  local response = http.post("www.google.com", 80, "/loc/json", nil, nil, json_query)

  local status, result = json.parse(response.body)

  return string.format("http://maps.google.ca/maps?q=%s,%s", result.location.latitude, result.location.longitude)

end

