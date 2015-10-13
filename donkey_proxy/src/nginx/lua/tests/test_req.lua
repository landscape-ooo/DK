--
--
--
package.path=package.path .. ";../?.lua"

require("dk_req")

function testMethod()
	local req = REQ:new()
end

function testNgx()
	local ngx={}
	ngx.var = {	uri="/abc",
				method=REQ.HTTP_GET,
				cookie_Antispam="cookie"
				}
	ngx.req = { get_headers=function() 
					return {Host="bj.ganji.com"}
				end,
				get_method=function() 
					return REQ.HTTP_GET
				end,
				get_uri_args=function()
					return { a="a",b="b" }
				end
				}

	local req = REQ:newFromNgx(ngx)
	assertEquals( req.method, REQ.HTTP_GET)
	assertEquals( req.host, "bj.ganji.com")
end

require("luaunit")
os.exit( LuaUnit.run() )