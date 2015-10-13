-- filter cookies
-- TODO: parse returned cookie
local log = require("dk_log")
local logger = log.getLogger("dk.cookie")

_COOKIES = {
	blacklist={

	},
	whitelist={

	}
}

function dk_cookie_parse(cookie_str)
	local parts = string.split(cookie_str,";")
	if #parts < 1 then 
		logger:warn("invalid set_cookie format:" .. cookie_str )
		return {}
	end
	local namevalue=string.split(parts[1],"=")
	if #namevalue ~= 2 then
		logger:warn("invalid set_cookie format:" .. cookie_str )
		return {}
	end
	local cookie = { name=string.ltrim(namevalue[1]), value=namevalue[2] }

	for i = 2,#parts do
		local kv = string.split(parts[i],"=")
		if #kv == 2 then
			cookie[string.ltrim(kv[1])] = kv[2]
		else
			cookie[string.ltrim(kv[1])] = true
			-- logger:warn("invalid set_cookie format:" .. cookie_str )
		end 
	end
	return cookie
end

function dk_load_cookies() 
	local cookies = {}
	local set_cookie = ngx.header['Set-Cookie']
	if type(set_cookie) == "string" then
		-- logger:info( "COOKIE:" .. set_cookie )
		return dk_cookie_parse(set_cookie)
	else
		if type(set_cookie) == "table" then
			for i,v in ipairs(set_cookie) do 
				table.insert(cookies, dk_cookie_parse(v) )
			end
		end
	end
	return cookies
end

function dk_dump_setcookie()
    cookies = dk_load_cookies()
    
    if #cookies >0 then
    	logger:debug(cookies)
    end
end

function dk_filter_setcookie()
    cookies = dk_load_cookies()
    for c in pairs(cookies) do
    	-- TODO: for global cookie
    end
end
