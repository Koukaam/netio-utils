-- use trigger "System started" in Netio4
-- it can be used for Netio4 restart when DHCP server is not available after Netio4 boots up

local device = "192.168.10.1" -- Change ping destination address here

local function pingAndReboot(o)
	if o.success then
    log("PING OK, target: " .. device .. ", " .. o.duration .. "ms"); 	
  else
    log("PING FAIL, target: " .. device .. ", " .. o.errorInfo);
	  devices.system.Reboot{}; -- reboot if no ping
 	end
end

-- main program with the callback function pingAndReboot
ping{address=device, timeout=10, callback=pingAndReboot}
