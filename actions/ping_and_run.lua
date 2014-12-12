-- use trigger "System variable updated" in Netio4

local port = 4 -- Change output number of controlled port here
local device = "192.168.0.1" -- Change ping destination address here

local function pingAndRun(o)
	local portState = devices.system["output" ..port.. "_state"]; -- two dots ".." for concatenation of the system variable name eg. output4_state
  	if o.success and (portState == "off") then
      	logf("PING OK, state of output %d is %s, Enabling port %d", port, portState, port); 	
      	devices.system.SetOut{output=port, value=true};
  	elseif o.success and (portState ~= "off") then
      	logf("PING OK, but state of output %d is %s, Do nothing", port, portState); -- do nothing if ping success and portState is different than "off" 
    else
      -- do nothing if the device is unreachable
    	-- or you can turn off the same output by uncommenting of the following command
    	-- devices.system.SetOut{output=port, value=false};
    	logf("PING FAIL, state of output %d is %s", port, portState); 
  	end
end

-- main program with the callback function pingAndRun
ping{address=device, timeout=5, callback=pingAndRun}
