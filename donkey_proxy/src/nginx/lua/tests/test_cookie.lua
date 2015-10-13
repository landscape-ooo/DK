-- test for dict
package.path=package.path .. ";../?.lua"

require("dk_cookie")

function testParse()
	local str = "age0=2; Domain=test.ganji.com; expires=Mon, 13 Apr 2015 07:06:47 GMT; Path=/; secure"
	local cookie = dk_cookie_parse(str)
	-- print(format_lua_table(cookie,1))
	assertEquals( cookie.name, "age0" )
	assertEquals( cookie.value, "2" )
	assertEquals( cookie.expires, "Mon, 13 Apr 2015 07:06:47 GMT" )
	assertEquals( cookie.Path, "/" )
	assertEquals( cookie.Domain, "test.ganji.com" )
	assertEquals( cookie.secure, true )
end

function testMultiLine()
end

require("luaunit")
os.exit( LuaUnit.run() )