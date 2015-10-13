--
-- all hosts data goes here
--
local sys = require("dk_sys")

local _HOSTS = {}
-- local _cities = {0, "bj", "sh" }
-- local _data = {}

function _HOSTS.init( shared_obj )
	_HOSTS.city = shared_obj
    shared_obj:set('test','yes')
end

function _HOSTS.getHostInfoShort(host)
	return _HOSTS.city:get(host)
end

function _HOSTS.getHostInfo(host)
	-- .ganji.com = 10
	if string.sub(host,-10) ~= ".ganji.com" then return nil end
	local p = string.split(host,'.')
	if #p<3 then return nil end

	host = string.lower(p[#p-2])
	return _HOSTS.city:get(host)
end

--
-- sync with master config server
--
function _HOSTS.sync()
end

--
-- load
-- load from fs for fast startup
-- 
function _HOSTS.load(persistFile)
	-- simple version
    if persistFile then
	    _HOSTS.loadFromStale(persistFile)
    end
end

function _HOSTS.loadFromStale(persistFile)
    local city= sys.read_json_file(persistFile)
	for i,v in ipairs(city) do 
		-- print( v )
		_HOSTS.city:set(v, { short=v,} )
	end
end

return _HOSTS
