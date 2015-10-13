--
--
--
package.path=package.path .. ";../?.lua"

local pc = require("dk_ganji")

require "dk_dict"
require "dk_req"

require "init"


function testReqProcess()
	local req = {
		uri = "/linlin/hello.world",
	 	host = "bj.ganji.com" 
	 }
	print_lua_table( pc.handleReq( req ) )
end

-- start unittest
require("luaunit")
os.exit( LuaUnit.run() )
