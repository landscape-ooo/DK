package.path=package.path .. ";../?.lua"

local categorys =require("dk_category")
local io = require("io")
local sys = require("dk_sys")

require("dk_dict")
require("init")

function testUrlMatch()
	assertEquals( categorys.getPathInfo("linlin"), {1} )
	assertEquals( categorys.getPathInfo("jiajia"), {2} )

end

require("luaunit")
os.exit( LuaUnit.run() )