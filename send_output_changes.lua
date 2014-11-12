--  use trigger "DO state changed" in NETIO4

local port = nil;
local portState = "";
local state = "";

for port=1,4 do
	portState=devices.system["output" ..port.. "_state"];
	state = state .. " " .. portState; -- " " is a space separator
end

_G.lastPortState = state; -- store as global variable for delayed port state check

delay(5, function()
	if state == _G.lastPortState then
		mail("someone@some.where", "State changed:${_G.lastPortState}", "State changed:${_G.lastPortState}");
      logf("State changed: %s", _G.lastPortState);
	end
end);
