--
package.path=package.path .. ";../?.lua"

local url = require("socket.url")
local _r = require "r"
require("dk_dict")


-- print( arg[1] )

local routes = require "dk_rewrite"
local hosts = require("dk_hosts")
local category = require("dk_category")

function _init()
	hosts.init( DICT:new() )
	category.init( DICT:new() )

	hosts.load( "./city.json" )
	category.load(  "./category.json" )

	routes.routes = _r
	routes.debug = true
end
_init()

-- start of the check
function decode_url( aurl )
	local parsed_url = url.parse(aurl)
	local kv = {}
	if parsed_url.query then
		local params = lua_string_split( parsed_url.query, "&")
		-- print_lua_table( params )
		for i,v in ipairs(params) do 
			local k = lua_string_split( v, "=")
			kv[k[1]] = k[2]
		end
		-- print_lua_table( kv )
	end

	local req = {
		host=parsed_url.authority, 
		uri=parsed_url.path or "/", 
		pdt=kv._pdt or kv.dir
	}

	return { routes.route(req), req }
end
function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    directory=(directory:gsub("^%s*", "")) 
    for filename in popen('ls -a "'..directory..'"'):lines() do
        if(filename:match('.*.dat'))  then --end with *.data
                i = i + 1
                t[i] =directory..'/'.. filename
        end
    end
    return t
end
function is_dir(path)
    f = io.open(path)
    return not f:read(0) and f:seek("end") ~= 0
end

if #arg <1 then
	-- run test 
	local c = io.readfile("test.dat")
	local lines = string.split(c,"\n")
	for i = 1 , #lines do 
		local l = lines[i]
		local p = string.split(string.trim(l)," ")
		if #p == 2 then
			-- print( p[1] )
			r = decode_url(p[1])
			group = r[1] and r[1]['group'] or 'bye,bye'
			if group ~= p[2] then
				-- print_lua_table( r )
				print( l , "====>", group )
			end
		end
	end
else
        -- run test
	local name=arg[1]
	local filelist={};
	if  is_dir(name) then 
	   local filelist_t=scandir(name)
	   if filelist_t then 
		   for k,v in pairs(filelist_t)  do 
			table.insert(filelist,v)
		   end
	   else
		   print("----not filepath ,exit")
		   os.exit()
	   end
	else
	    table.insert(filelist,name)
	end	
	
	local log_metux={};
	for k,file_n in pairs(filelist) do	
		log_metux[file_n]={};
	        local c = io.readfile(file_n)
        	local lines = string.split(c,"\n")
	        for i = 1 , #lines do
        	        local l = lines[i]
	                local p = string.split(string.trim(l)," ")
        	        if #p == 2 then
                	        -- print( p[1] )
                        	r = decode_url(p[1])
	                        group = r[1] and r[1]['group'] or 'bye,bye'
        	                if group ~= p[2] then
                	                -- print_lua_table( r )
					table.insert(log_metux[file_n],l .."====>".. group)
                        	        --print( l , "====>", group )
                        	end
               		end
	        end
	  end --for filelist
	  for k_s,v_s in pairs(log_metux) do 
		if v_s and #v_s>0 then 
		print('========'..k_s); 
			for kss,vss in pairs(v_s) do 
				print(vss)
			end
		print('====================================='.."\n\n\n"); 
		end
	  end
end
