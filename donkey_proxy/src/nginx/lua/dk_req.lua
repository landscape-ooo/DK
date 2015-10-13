--
-- request object
--
local sys = require("dk_sys")

-- { 
--   uri,host,method, (input )
--   cookie_Antispam,
--   info={
--     group=group name where to dispatch
--     antispam=true/false, allow to do anti-spam detect?
--   }
--}
REQ = {}
if ngx ~= nil then
    REQ.HTTP_GET = ngx.HTTP_GET
	REQ.HTTP_POST = ngx.HTTP_POST
else
	REQ.HTTP_GET = 1
	REQ.HTTP_POST = 2
end

function REQ:new(o) 
	o = o or {}
  	setmetatable(o, self)
  	self.__index = self
  	return o
end

--
-- create a req from nginx 
-- 
function REQ:newFromNgx(ngx)
	local req = REQ:new()
  	headers = ngx.req.get_headers()
	req.uri = ngx.var.uri
    req.headers = headers
	req.host = headers["Host"]
	req.method = ngx.req.get_method()
    local args = ngx.req.get_uri_args()
    -- BUG: 2 _pdt will cause args._pdt be a table
    local pdt = args._pdt or args.dir
    if( type(pdt) == "table" ) then
        req.pdt = pdt[1]
    else 
    	req.pdt = pdt
    end
	return req
end

--
-- Any better way
--
function REQ:getFullUri()
 	-- local query = ""
 	-- table.foreach( ngx.req.get_uri_args(), function(k,v) query = query .. "&" .. k .."="..string.urlencode(v) end )
 	-- )
 	local fullpath=  ngx.var.scheme ..'://'..ngx.var.host ..ngx.var.request_uri
   	return fullpath 
end

function REQ:getHost()
	return self.headers["Host"]
end

function REQ:isGet()
	return self.method == "GET" 
end

function REQ:return404()
	ngx.status = ngx.HTTP_NOT_FOUND
    ngx.say("not found")
    -- to cause quit the whole request rather than the current phase handler
    ngx.exit(ngx.HTTP_OK)
end

function REQ:returnOk()
	local r = self.info.group
	ngx.say("success:", r)
	ngx.exit(ngx.HTTP_OK)
end


-- function dk_doReq( req )
-- 	sys.debug("dk_404")
-- 	local group = nil
-- 	if req.info ~= nil and req.info.group then
-- 		-- send to group 
-- 		group = req.info.group
-- 	else
-- 		group = "common"
-- 	end

-- 	-- dispatch to specific group
-- 	dk_dumpReq( req )
-- end
