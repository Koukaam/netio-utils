-- This script allows to set all ports with one cgi request
-- Set this to activate on system's CGI input event, and set the password below.
-- Then you can for example turn on port 2 and reset ports 3 and 4 with the following
-- CGI: http://<netio_ip>/event?port=x1ii&pass=password

-- Set here your password. The password will be required in the incoming CGI request for this action to work.
local accepted_pass="password"

-- function for parsing port arg value and performing its action
local function portparse(s)
	local portnumber = 1;
	for c in string.gmatch(s, "%w") do -- accept only alphanumerical chars
		if portnumber > 4 then return end; -- break
		if c=="0" then
			devices.system.SetOut{output=portnumber, value=false}
		elseif c=="1" then
			devices.system.SetOut{output=portnumber, value=true}
		elseif c=="i" then
			devices.system.ResetOut{output=portnumber}
		else -- do nothing
		end
		portnumber = portnumber+1
	end
end

local port=event.args.port
local pass=event.args.pass

-- Comment out the following block of code if you are using more than one CGI-triggered action.
if (not port) or (not pass) then
	log("CGI parser: PORT and/or PASS argument missing, please check your CGI command. Use following syntax for the control CGI http(s)://netio.ip/event?port=10iu&pass=password where accepting arguments for port 1 to 4 are: 0...off, 1...on, i...interrupt (reset), any other char for port skip (unused)")
	return -- break (end of action)
end

if (pass==accepted_pass) then
	portparse(port)
else
	log("CGI parser: Wrong password")
end
