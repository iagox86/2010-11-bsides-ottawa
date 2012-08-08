-- -*- mode: lua -*-
-- vim: set filetype=lua :
-- The preceding lines should be left intact to help vim/emacs do syntax
-- highlighting

description = [[
Perform a dns lookup against the hostname and scan the mail servers
]]

---
-- @usage
-- This section should simply be the Nmap command to run the script. eg:
-- nmap --script dns-demo <host>
--
-- @output
-- Host script results:
-- | dns-demo: 
-- | Found mail servers:
-- |   alt3.gmail-smtp-in.l.google.com
-- |   alt4.gmail-smtp-in.l.google.com
-- |   gmail-smtp-in.l.google.com
-- |   alt1.gmail-smtp-in.l.google.com
-- |_  alt2.gmail-smtp-in.l.google.com


-- Change the 'author' field to your name and handle. We no longer include email
-- addresses. 
author = "Ron and Bsides Audience"

-- Only change the license if you don't plan on submitting the plugin to be
-- included with Nmap. 
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"

categories = { "safe", "discovery" }

-- NSELib libraries should be included here.
require 'stdnse'
require 'dns'
require 'target'

---
-- Uncomment the following function to use a hostrule.
 hostrule = function( host )
   return true
 end

---
-- Finally, the action function. This is called once for each time the rule
-- function returns true. The host and/or port may be nil depending on what
-- type of rule fired. If you need more than one rule type (for example, a
-- prerule then a hostrule), scroll past this function. 
action = function( host, port )
  local status, result = dns.query(stdnse.get_hostname(host), {dtype='MX', retAll=true})

  if(not(status)) then
    return "Couldnot lookup server: " .. result
  end

  local response = {}
  response['name'] = "Found mail servers:"

  for _, address in ipairs(result) do
    address = stdnse.strsplit(":", address)[2]
    table.insert(response, address)

    if(target.ALLOW_NEW_TARGETS) then
      target.add(address)
    else
      stdnse.print_debug(1, "Couldn't add target")
    end
  end

  return stdnse.format_output(true, response)
end

