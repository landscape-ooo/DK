-- test for dict
-- test for dict
package.path=package.path .. ";../?.lua"

require("dk_dict")

function testBasic()
	local dict = DICT:new()
	dict:set("name",{myname="caifeng"})
	assertEquals( dict:get("name").myname, "caifeng" )
end

require("luaunit")
os.exit( LuaUnit.run() )