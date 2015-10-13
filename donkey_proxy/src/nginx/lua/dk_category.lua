-- category
local sys = require("dk_sys")
local io = require("io")

local _CATEGORY = {}

function _CATEGORY.init( shared_obj )
	_CATEGORY.data = shared_obj;
end

function _CATEGORY.getPathInfo(path1)
	--sys.debug( _CATEGORY.data )
    return _CATEGORY.data:get(path1)
end

--
-- load
-- load from fs for fast startup
-- 
function _CATEGORY.load(persistFile)
	-- simple version
	if persistFile then
		_CATEGORY.loadFromStale(persistFile)
	end
end

--
-- TODO: load from disk 
--
function _CATEGORY.loadFromStale(persistFile)
	-- local category = _CATEGORY.data
	local category = sys.read_json_file(persistFile)
    if category == nil then
         sys.error( "load file " .. persistFile .. " failed" )
         return
    end
	for k,v in pairs(category) do 
		_CATEGORY.data:set(k,v )
	end
end

--
-- sync with master config server
-- using nginx's upstream for data transfer
--
function _CATEGORY.sync()
end

return _CATEGORY
