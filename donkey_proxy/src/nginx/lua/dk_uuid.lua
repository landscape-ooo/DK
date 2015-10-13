local log = require("dk_log")
local logger = log.getLogger("dk.random")

-- 使用/dev/urandom初始化随机数
-- 应该在lua_init_worker中调用
function dk_uuid_init()
	d = io.open("/dev/urandom", "r"):read(4)
	math.randomseed(os.time() + d:byte(1) + (d:byte(2) * 256) + (d:byte(3) * 65536) + (d:byte(4) * 4294967296))
end

-- 生成uuid
function dk_uuid_gen()
	local template ="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	return string.gsub(template, "x", function (c)
      local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
      return string.format("%x", v)
      end)
end