-- Sets outlet on/off to signalize device presence on the network
--
-- add either to
--  * IncomingCgi, then you can turn it on/off
--       with /event?ping=start and /event?ping=stop CGI
-- or to
--  * SystemStart, in which case it loads up
--       automatically on system boot
--
-- We use global variable to maintain only one pinger instance
-- in the system. If you want more instances, you need to change that.

local port = 1
local address = "192.168.0.1"

-- ping interval in seconds, can differ per device current reachability
local pingInterval = {[true]=55, [false]=30}
local pingTimeout = 7 -- ping timeout in seconds

if event.name == "IncomingCgi" then
	if event.args.ping == "stop" then
		_G.currentPingerVersion = nil
		return
	elseif event.args.ping ~= "start" then
		return
	end
end


local ourVersion = {} -- just to monitor if we changed, for callbacks
_G.currentPingerVersion = ourVersion

local function pingCycle(o)
	if ourVersion ~= _G.currentPingerVersion then logf("pinger cycle abort"); return end
	if o == nil then
		-- we've slept, do the ping
		ping{address=address, timeout=pingTimeout, callback=pingCycle}
		return
	end
	
	-- we have ping result
	local portIsOn = (devices.system["output" .. port .. "_state"] ~= 'off')
	if o.success ~= portIsOn then
		logf("pinger update: presence %s", tostring(o.success))
		devices.system.SetOut{output=port, value=o.success}
	end
	
	delay(pingInterval[o.success] - pingTimeout, pingCycle)
end

logf("pinger cycle start for address %s and port %d", address, port)
pingCycle()
