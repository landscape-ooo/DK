local hosts =require("dk_hosts")
local sys = require("dk_sys")
local categorys = require("dk_category")

require("dk_dict")

-- init city
init_func = function ()
	local city = DICT:new()
	local citys = sys.read_json_file("test_city.json")
	for i,v in ipairs(citys) do
		city:set(v ,{short=v,})
	end
	hosts.init( city )

	local cats = DICT:new()
	local category = sys.read_json_file("test_cat.json")
	for k,v in pairs(category) do
		cats:set(k,v)
	end
	categorys.init( cats )
end

init_func()