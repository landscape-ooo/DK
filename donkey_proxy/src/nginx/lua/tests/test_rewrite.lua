--
--
--
package.path=package.path .. ";../?.lua"


local routes = require("dk_rewrite")
local hosts = require("dk_hosts")

require("init")

-- 简单url的正则匹配
function testUri()
	routes.routes = { 
		{ 
		  uri="/",
		  target={ group="v3"} 
		},
		{ 
		  uri_r="^/ganji/[0-9]+/\\w+",
		  target={ group="v2"} 
		},
		{ 
		  uri_r="^/ganji/[0-9]+$",
		  target={ group="v1"} 
		},
		{  -- no ^ , will match any level
		  uri_r="/ganji2/[0-9]+",
		  target={ group="verr"} 
		}		
	}
	local r = routes.route({ uri="/ganji/12345", host="bj.ganji.com"})
	assertEquals( r.group, "v1" )
	local r = routes.route({ uri="/ganji/12345abc", host="bj.ganji.com"})
	assertEquals( r, null)
	local r = routes.route({ uri="/abc/ganji2/12345", host="bj.ganji.com"})
	assertEquals( r.group, "verr"  )
	local r = routes.route({ uri="/ganji/12345/abc", host="bj.ganji.com"})
	assertEquals( r.group, "v2" )
	local r = routes.route({ uri="/", host="bj.ganji.com"})
	assertEquals( r.group, "v3" )
end

-- 简单host匹配
function testHost()
	routes.routes = { 
		{ 
		  domain_r="^\\w+\\.ganji\\.com$",
		  target={ group="ganji_com"} 
		},
		{ 
		  domain_r="^\\w+\\.ganji\\.com.cn$",
		  target={ group="ganji_com_cn"} 
		}
	}
	local r = routes.route({ host="bj.ganji.com"})
	assertEquals( r.group, "ganji_com" )
	local r = routes.route({ host="bj.ganji.com.cn"})
	assertEquals( r.group, "ganji_com_cn" )
	local r = routes.route({ host="bj.ganji1.com"})
	assertEquals( r , nil)
end

function testMethod()
	routes.routes = {
		{ 
		  method="GET",
		  target={ group="get"} 
		},
		{ 
		  method="POST",
		  target={ group="post"} 
		},
	}
	local r = routes.route({ method="GET"})
	assertEquals( r.group, "get" )
	local r = routes.route({ method="POST"})
	assertEquals( r.group, "post" )
	local r = routes.route({ })
	assertEquals( r , nil )
end

-- 嵌套规则
function testNested()
	routes.routes = {
		{ 
		  uri="/ganji1",
		  _={
		  		{
		  			method="POST",
		  			target={ group="ganji1.post"} 
		  		},
		  		{
		  			method="GET",
		  			target={ group="ganji1.get"}
		  		}
		  	}
		},
	}
	local r = routes.route({ uri="/ganji1", host="bj.ganji.com", method="POST"})
	assertEquals( r.group, "ganji1.post" )
	local r = routes.route({ uri="/ganji1", host="bj.ganji.com", method="GET"})
	assertEquals( r.group, "ganji1.get" )
	assertEquals( routes.route({ uri=nil,}),nil)
end

function testPdt()
	routes.routes = {
		{ 
		  pdt="house",
		  target={ group="h"} 
		},
		{ 
		  pdt="pet",
		  target={ group="p"} 
		},
		{ 
		  pdt_r="abc|def",
		  target={ group="re"} 
		},
	}
	local r = routes.route({ uri="/hello", pdt="house"})
	assertEquals( r.group, "h" )
	local r = routes.route({ uri="/hello", pdt="pet"})
	assertEquals( r.group, "p" )
	local r = routes.route({ uri="/hello", pdt="pet1"})
	assertEquals( r , nil )
	local r = routes.route({ uri="/hello", pdt="def"})
	assertEquals( r.group, 're' )
	local r = routes.route({ uri="/hello", pdt=nil})
	assertEquals( r, nil )
end


-- 城市
function testCity()
	routes.routes = {
		{
			city=1,
			target={city=1,}
		}
	}
	local r = routes.route({ host="bj.ganji.com"})
	assertEquals( r.city, 1)
	local r = routes.route({ host="hk.ganji.com"}) -- not in test data
	assertEquals( r, nil)
	local r = routes.route({ host="123.ganji.com"})
	assertEquals( r, nil)
end

-- 城市嵌套
function testCity2()
	routes.routes = {
		{
			city=1,
			target={city=1,},
			_={
		  		{
		  			domain="bj.ganji.com",
		  			target={ group="bj"} 
		  		},
		  		{
		  			domain="sh.ganji.com",
		  			target={ group="sh", location="south"}
		  		}
		  	}
		}
	}
	local r = routes.route({ host="bj.ganji.com"})
	assertEquals( r.group, "bj")
	assertEquals( r.city, 1)
	local r = routes.route({ host="sh.ganji.com"}) -- not in test data
	assertEquals( r.group, "sh")
	assertEquals( r.city, 1)
	assertEquals( r.location, "south" )
	local r = routes.route({ host="123.ganji.com"})
	assertEquals( r, nil)
end

function testCategory()
	routes.routes = {
		{
			cat=1,
			target={group="cat"}
		}
	}
	local r = routes.route({ uri="/linlin"} )
	assertEquals( r.group, "cat" )
	local r = routes.route({ uri="/jiajia"} ) -- not in test data
	assertEquals( r.group, "cat" )
	local r = routes.route({ uri="/linjia"} )
	assertEquals( r, nil )
end

function testCombo()
	routes.routes = {
		{
			cat=1,
			city=1,
			target={city=1,group="ganji_city"}
		}
	}
	local r = routes.route({ uri="/linlin", host="bj.ganji.com"} )
	assertEquals( r.group, "ganji_city" )
	local r = routes.route({ uri="/jiajia",host="sz.ganji.com"} ) -- not in test data
	assertEquals( r, nil )
	local r = routes.route({ uri="/jiajia/hello",host="bj.ganji.com"} ) -- not in test data
	assertEquals( r.group, "ganji_city" )
end

require("luaunit")
os.exit( LuaUnit.run() )
