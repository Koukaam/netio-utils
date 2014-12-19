-- use trigger "Incomming CGI request" in Netio4
-- don't forget to add the second needed action named "dead_man_trigger_update" to your Netio4
-- HOWTO USE:
---send CGI  http://netio.ip/event?status=1 for activation of "dead man" action
-- for deactivation send CGI eg. http://netio.ip/event?status=0
-- send CGI for dead man action (as button press in train) http://ip.netia/event

if deadStatus == nil then deadStatus=0; end
triggerTime = os.time(); -- sets global variable for use in another action - eg. in dead_man_trigger_update
deadStatus = tonumber(event.args.status); -- receives value of the CGI argument variable "status"
logf("status %d", deadStatus); -- debug only, can be commented out

