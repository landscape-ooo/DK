package.path=package.path .. ";../?.lua"

local hosts =require("dk_hosts")
local sys = require("dk_sys")

require("dk_dict")
require("init")

function testCityMatch()
	assertEquals( hosts.getHostInfo("tokyo"), nil )
	assertEquals( hosts.getHostInfo("sh.ganji.com"), {short="sh"} )

end

require("luaunit")
os.exit( LuaUnit.run() )