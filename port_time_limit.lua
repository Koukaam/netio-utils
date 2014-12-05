-- This will ensure given outlet will not stay on longer than given time
-- Add this to system's "DO state change" event.
local port = 1
local time_limit_sec = 30 * 60

-- The code
local function check(powered_on)
	if _G.powered_on[port] == powered_on then
  		devices.system.SetOut{output=port, value=false}
  	end
end

if _G.powered_on == nil then _G.powered_on = {} end
if devices.system['output' .. port .. '_state'] == 'on' then
  	if _G.powered_on[port] == nil then
		local now = os.time()
  		_G.powered_on[port] = now
		delay(time_limit_sec, function() check(now) end)
    end
else
	_G.powered_on[port] = nil
end
