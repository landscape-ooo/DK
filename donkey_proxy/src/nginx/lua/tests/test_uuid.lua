--[[
unittest for dk_log module
]]--

package.path=package.path .. ";../?.lua"

require("dk_uuid")
dk_uuid_init()

function testSpeed()
	local x1 = os.clock()
	for i = 1, 100000 do
		dk_uuid_gen()
	end
	local x2 = os.clock()
	print(string.format("elapsed time: %.2f\n", x2 - x1))
	assertTrue( x2-x1 < 2 )
end

require("luaunit")
os.exit( LuaUnit.run() )