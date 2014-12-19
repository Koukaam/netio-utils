-- use trigger "System variable updated" in Netio4
-- don't forget to add the second needed action named "dead_man_trigger_cgi" to your Netio4

if triggerTime == nil then triggerTime = os.time(); end;
if deadStatus == nil then deadStatus = 0; end;

now = os.time();
interval = 60; -- here edit max interval in sec when the CGI http://netio.ip/event must arrive

if ((now-triggerTime) > interval) and (deadStatus == 1) then -- checks if the triggerTime is in interval range
    log("Restarting outlet");	-- debug only, can be commented out
    devices.system.ResetOut{output=1}; -- reset of the port nr. 1
    triggerTime = now;
    deadStatus = 0; -- IF Condition will no longer be met (same as CGI http://netio.ip/event?status=0)
else log("do nothing"); -- debug only, log command can be commented out
end
