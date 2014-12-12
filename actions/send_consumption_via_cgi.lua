-- this will send socket and consumption status updates via CGI
-- to given address. Associate with 'System variables update' event
-- to get consumption updates when they show up

local address='192.168.0.1'
local path = '/script.php'


local output = {}
for i = 1, 4 do for _, what in pairs({'state', 'consumption'}) do
    local varname = string.format('output%d_%s', i, what)
    table.insert(output, varname..'='..tostring(devices.system[varname]))
end end

local qs = table.concat(output, '&')
local url = string.format('http://%s%s?%s', address, path, qs)
devices.system.CustomCGI{url=url}
