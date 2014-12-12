-- use trigger "System variables updated" in Netio4 All

local function returnState()
  -- stores actual connection state of the BT device named "sensorboard"
  local actState=devices.sensorboard.connected;  
  if prevState == nil then prevState = false; end;
  -- logf("actState=%s", tostring(actState)); -- debug only
  -- logf("prevState=%s", tostring(prevState)); -- debug only
  if actState == true and prevState == false then -- actual state connected, previous state unreachable
    retState = true; -- output should be ON
  elseif actState == false and prevState == true then -- actual state unreachable, previous state connected
    retState = false; -- output should be OFF
  else 
    retState = nil; -- both states are still the same
  end
  prevState = actState; -- stores actual state as previous
  -- logf("retState=%s", tostring(retState)); -- debug only
  return retState;
end

-- Main program
local state = returnState()
if state ~= nil then
  devices.system.SetOut{output=1, value=state}; --change number of controlled port here
end
