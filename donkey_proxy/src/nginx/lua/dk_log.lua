--[[
 dk_log
 log data to a specific udp server for donkey-proxy access log
]]--

require("dk_util")

_LOG = {
	udpsock = nil,
	udp = {},
	ngxlog = false,
	level_default=15,  -- INFO
	levels= {},

	DEBUG=10,
	INFO=15,
	WARN=20,
	ERROR=25,
	FATAL=30,
}

_LOG_LEVELS = {
	[10]="DEBUG",
	[15]="INFO",
	[20]="WARN",
	[25]="ERROR",
	[30]="FATAL"
}

LOGGER = {}

function LOGGER:new(name, o)
  o = o or {data={},}
  o.name = name
  setmetatable(o, self)
  self.__index = self
  return o
end

function LOGGER:log(level, msg)
	_level = _LOG.levels[self.name]
	if _level == nil then
		_level = _LOG.level_default
	end
	if level>=_level then
		_LOG.log( self.name, tostring(level), msg) -- TODO , add level string
	end
end

function LOGGER:debug(msg)
	self:log( _LOG.DEBUG, msg )
end

function LOGGER:info(msg)
	self:log( _LOG.INFO, msg )
end

function LOGGER:warn(msg)
	self:log( _LOG.WARN, msg )
end

function LOGGER:error(msg)
	self:log( _LOG.ERROR, msg )
end

function LOGGER:fatal(msg)
	self:log( _LOG.FATAL, msg )
end

function _LOG.enableUdp(host, port)
	_LOG.udp = { host, port }
	local udpsock = ngx.socket.udp()
	local ok, err = udpsock:setpeername(host, port)
	if not ok then
        ngx.say("failed to connect to log server with udp ", err)
        return
    end
	_LOG.udpsock = udpsock
end

function _LOG.enableNgxLog()
	_LOG.ngxlog = true
end

function formatLevel(level)
	return _LOG_LEVELS[tonumber(level)] or ('unknown level' .. level )
end

function _LOG.log(name, level, line)
    if type(line) == "table" then
                line = format_lua_table( line , 1 )
    end
    level = level or ""
    name = name or ""
    line = line or ""

	if _LOG.ngxlog then
		ngx.log(ngx.INFO, name .. " [" .. formatLevel(level) .. "] " .. line)
	end
	if _LOG.udpsock then 
		local udpsock = _LOG.udpsock
		if udpsock then
			local ok, err = udpsock:send(line)
			if not ok then 
				ngx.say("send to udpsock failed", err)
			end
		end
	end
end

function _LOG.logAccess(uri,method,target,rule)
	_LOG.log()
end

function _LOG.getLogger(name)
	return LOGGER:new(name)
end

function _LOG.setLevel(name,level)
	_LOG.levels[name] = level
end

return _LOG
