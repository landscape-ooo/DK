--[[
 dk_dict
 mimic ngx.shared.DICT
]]--
local sys = require("dk_sys")
DICT = {}

function DICT:new (o)
  o = o or {data={},}
  setmetatable(o, self)
  self.__index = self
  return o
end

function DICT:newFromSharedDict(sd)
  o = {sd=sd,}
  setmetatable(o,self)
  self.__index = self
  return o
end

function DICT:set (k,v)
	if type(k) ~= "string" then
		sys.error("DICT:set key must be string")
		return
	end
	
	v = sys.json_dump( v )
	if self.sd then
		self.sd:set(k,v)
	else
  		self.data[k] = v
  	end
end

function DICT:get (k)
	if type(k) ~= "string" then
		sys.error("DICT:get key must be string")
		return
	end
    local r=nil
    if self.sd then
       	r = self.sd:get(k)
    else
   		r = self.data[k]
    end
	if r then
		return sys.json_loads( r )
	end
	return nil
end


