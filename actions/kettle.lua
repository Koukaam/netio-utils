-- This is for NETIO4-ALL, used for boiling kettle detection.
-- Add on "System variables update", and update kettle port and handlers
-- to do what you want.

local kettle_port = 2

local function signalise_start()
  -- send a CGI command to voice syntesiser
  devices.system.CustomCGI{url="http://192.168.1.2/?lang=en&message=kettle%20is%20on"};
  
  -- blink output 3 twice
  devices.system.SetOut{output=3, value=true};
  delay(2, function () devices.system.ResetOut{output=3} end)
  delay(4, function () devices.system.SetOut{output=3, value=false} end);
end

local function signalise_end()
  -- turn output 3 on for 5 seconds
  devices.system.SetOut{output=3, value=true};
  delay(5,function () devices.system.SetOut{output=3, value=false} end);

  -- play fanfare, instruct another NETIO4 to blink with light, send e-mail notification
  devices.system.CustomCGI{url="http://192.168.1.2/?sound=tada.wav"};
  devices.system.CustomCGI{url="http://192.168.1.3/event?action=blink"}
  mail("developer@example.com", "Watter is boiling", "Time to make tea")
end

-- Detection code is below

local function get_kettle()
  -- kettle is on if it eats more than 0 Watts
  return devices.system['output' .. kettle_port .. '_consumption'] > 0
end

-- init our global variable
if kettle_was_on == nil then
  kettle_was_on = get_kettle()
end

-- now just check if the state has changed
local kettle_on = get_kettle()

if kettle_on and not kettle_was_on then
  signalise_start()
elseif not kettle_on and kettle_was_on then
  signalise_end()
end

kettle_was_on = kettle_on
