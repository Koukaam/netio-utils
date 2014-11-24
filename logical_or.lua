-- This will make one output work as logical OR of other outputs.
-- Add to Netio's "DO state changed" event.
local sources = {1, 2, 4}
local destination = 3


local desired_out = false
for _, port in pairs(sources) do
  local state = devices.system["output" .. port .. "_state"]
  if state == 'on' then
    desired_out = true
  end
end

local cur_out = (devices.system["output" .. destination .. "_state"] ~= "off")
if cur_out ~= desired_out then
  devices.system.SetOut{output=destination, value=desired_out}
end
