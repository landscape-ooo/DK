--[[
unittest for dk_log module
]]--

package.path=package.path .. ";../?.lua"

local log = require("dk_log")
local logger = log.getLogger("test")

logger:debug('hello')

require("luaunit")
os.exit( LuaUnit.run() )
