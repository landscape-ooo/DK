
local sys = require "dk_sys"
require "dk_util"
local CONFIG_PATH="/data/nginx/qa"

local _QA = {}
function _QA.getconfig(user_addr) 
	local config = sys.read_json_file( CONFIG_PATH .. "/" .. user_addr)
	if config == nil then
		config = {}
		-- if no config found , give a page for select
	end
	return config
end

function _QA.setconfig(user_addr, cfg)
	local r = sys.json_dump(cfg)
	io.writefile( CONFIG_PATH .. "/" .. user_addr, r)
end

return _QA