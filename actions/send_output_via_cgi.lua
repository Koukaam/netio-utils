-- this will send socket and consumption status updates via CGI
-- to given address. Associate with 'DO state changed' event
-- to status updates when something changes

local address='192.168.0.1'
local path = '/script.php'


local output = {}
for i = 1, 4 do
    local varname = string.format('output%d_state', i, what)
    table.insert(output, varname..'='..tostring(devices.system[varname]))
end

local qs = table.concat(output, '&')
local url = string.format('http://%s%s?%s', address, path, qs)
devices.system.CustomCGI{url=url}
