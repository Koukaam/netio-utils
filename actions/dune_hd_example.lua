-- Netio4 is able to show pictures (and play videos too) on DuneHD media player throught outgoing CGI. It assumes that pictures are named 0000.jpg, 0011.jpg,..,1111.jpg and are stored on SD card plugged in DuneHD.
-- use "DO state changed" trigger on Netio4 

local port = nil;
local portStates = nil;
local request = "http://192.168.0.1/cgi-bin/do?cmd=start_file_playback&media_url=storage_uuid://aabb_ccdd/DCIM/"
local picture = "";
local worker = {};
for port=1,4 do
   portState=devices.system["output" ..port.. "_state"];
   if (portState == "on")  then portState = 1 end;
   if (portState == "off") or (portState == "starting") or (portState == "resetting") then portState = 0 end;
   --if (portState == "starting") or (portState == "resetting") then return; end;
   -- worker
   worker[port]=portState;
   for key,value in pairs(worker) do picture = picture .. value; end
        -- logf("Port %d has state %s", port, tostring(portState));
end
  
picture = string.sub(picture, -4,-1);
request = request .. picture .. ".jpg";
logf("request: %s", request);
devices.system.CustomCGI{url=tostring(request)};
