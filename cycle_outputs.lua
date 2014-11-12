-- Use eg. trigger "Incomming CGI request" in Netio4 and CGI http://netio.ip/event for triggering

local function cycler(n)
   local function sw(z, state) devices.system.SetOut{output=z, value=state} end
   if n <= 0 then _G.cycler_active = false; return end
   if n % 2 == 1 then -- if n is odd number (modulo is used)
       sw(1, true); sw(2, true); sw(3, false); sw(4, false); 
    	-- outputs actions
   else
       sw(1, false); sw(2, false); sw(3, true); sw(4, true); -- outputs actions
   end
   delay(10, function() cycler(n-1) end) -- delay between on/off states in seconds
end

if not _G.cycler_active then
   _G.cycler_active = true
   cycler(5) -- how many times
end
