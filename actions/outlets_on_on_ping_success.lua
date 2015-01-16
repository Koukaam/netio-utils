-- This script turns on all outlets when given IP address starts to respond to ping
-- Add this on "DO state changed" event (you will need to turn some outlet on/off
-- for the action to take effect).

local device = "192.168.1.1" -- Change ping destination address here
local timeoutSec = 15 -- ping timeout in seconds

local function someOutletsOff()
    for port = 1, 4 do
        if devices.system["output" .. port .. "_state"] == 'off' then return true end
    end
    return false
end

local function pingResult(o)
    if not someOutletsOff() then
        -- someone turned it on already, stop pinging
        _G.pingActive = false
        return
    else
        if o.success then
            logf("ping %s OK, some outlets off, turning all on", device);
            for port = 1, 4 do
                devices.system.SetOut{output=port, value=true};
            end
            _G.pingActive = false
            return
        else
            -- try ping again
            ping{address=device, timeout=timeoutSec, callback=pingResult}
        end
    end
end

if someOutletsOff() and not _G.pingActive then
    ping{address=device, timeout=timeoutSec, callback=pingResult}
    _G.pingActive = true
end
