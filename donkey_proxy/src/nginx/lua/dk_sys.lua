--
--
--

require("dk_util")
local io = require("io")
local cjson = require("cjson")
_SYS = {}
if ngx == nil then
	_SYS.rex = require("rex_pcre")
end

function _SYS.json_loads( json )
	return cjson.decode(json)
end

function _SYS.json_dump( json )
	return cjson.encode(json)
end

function _SYS.read_json_file( file )
	local f = io.open(file,"r")
	if f == nil then return nil end
	local jsons = f:read("*a")
	local table = _SYS.json_loads(jsons)
	return table
end

function _SYS.re_find(subj, patt, cf)
	local from, to, caps
    if ngx == nil then
	  from, to, caps = _SYS.rex.find(subj,patt,0)
    else
	  from, to, caps = ngx.re.find(subj,patt,0)
    end
  
	if from then
		return from, to, nil
	end
	return nil
end

function _SYS.re_match(subj, patt)
	local r,err
    if ngx == nil then
	  r = _SYS.rex.match(subj,patt)
          return r
    else
	  local m,err = ngx.re.match(subj,patt)
          -- print( err, subj, patt )
          return (not err) and (m ~=nil) 
    end
end

function _SYS.debug( o )
	if( type(o) == "table" ) then
            if ngx == nil then
		print_lua_table( o , 4 )
            else
                print( format_lua_table( o , 1 ))
            end
	else
		print( o )
	end
end

function _SYS.info( o )
end

function _SYS.warn( o )
end

function _SYS.error( o )
    if ngx == nil then
        print( o )
    else
       if( type(o) == "table") then
		ngx.log( ngx.ERR, format_lua_table( o , 1 ) )
       else
                ngx.log( ngx.ERR, o )
       end
    end
end

function _SYS.fatal( o )
end

-- init
return _SYS
