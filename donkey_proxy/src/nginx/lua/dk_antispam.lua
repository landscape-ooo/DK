-- antispam service
require "dk_util"
local sys = require "dk_sys"
-- local memcached = require "resty.memcached"
local logger = require("dk_log").getLogger("dk.antispam")

local SECRET_KEY='DHTuv108TNdL20KAG4CO354fGbCLQ8'
local TXZ_EXPIRE=600   -- valid for 600s

--[[
  1:string ip,
  2:string domain,
  3:string time_str,
  4:string req_method,
  5:string req_str,
  6:string referer,
  7:string user_agent,
  8:string category_major,
  9:string uuid,
  10:string sid,
 --]]

--[[
根据req，创建一个antispam服务的请求对象，包含了antispam服务所需要的信息
]]-- 
function dk_antispam_create()
 	local headers = ngx.req.get_headers()
 	local query = ""
 	table.foreach( ngx.req.get_uri_args(), function(k,v) query = query .. "&" .. k .."="..string.urlencode(v) end )
	local req = { ip=(headers['gj_client_ip']) or (ngx.var.remote_addr),
		time_str=os.date("%Y%m%d%H%M%S"),
		domain=(headers['Host']) or (''),
		req_method = (ngx.var.method) or (''),
		req_str = ngx.var.uri .. "?" .. query,
		referer = (headers['Referer']) or (''),
		user_agent = (headers['User-Agent']) or (''),
		uuid = (ngx.var.cookie___utmganji_v20110909) or (''),
		sid = (ngx.var.cookie_GANJISESSID) or (''),
		category_major = '',
	}
	return req
end

math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 

--[[
使用随机数，初始化一个赶集通行证的cookie：_gj_txz
并把初始化随机数保存在memcached中
]]--
-- function _dk_antispam_init()
-- 	local txid = math.random(987564325)
--   local code = math.random(9999)
--   dk_antispam_settoken(txid, code, 0)
-- 	ngx.header['Set-Cookie'] = {"_gj_txid=" .. txid,}
--   return { txid=txid, code=code }
-- end

-- --[[
-- 从memcached中获取通行证的初始随机数
-- ]]--
-- function _dk_antispam_gettoken(txid)

--   local memc, err = memcached:new()
--   if not memc then
--       logger:error( "failed to instantiate memc: " .. err )
--       return nil
--   end

--   local ok, err = memc:connect("127.0.0.1", 11211)
--   if not ok then
--       logger:error( "failed to connect to memcached: " .. err )
--       return nil
--   end

--   local res, flags, err = memc:get(txid)
--   if err then
--       logger:error( "failed to get clientIP " .. err )
--       return nil
--   end
--   if res then
--      return sys.json_loads( res )
--   end
--   return nil
-- end

-- --[[
-- 将信息保存在memcached中，以通行证为key，json数据格式
-- ]]--
-- function _dk_antispam_settoken(txid, code, pass)
--   local memc, err = memcached:new()
--   if not memc then
--       logger:error( "failed to instantiate memc: " .. err )
--       return
--   end

--   local ok, err = memc:connect("127.0.0.1", 11211)
--   if not ok then
--       logger:error( "failed to connect: " .. err )
--       return
--   end

--   local res, flags, err = memc:set(txid, 
-- 				sys.json_dump({code=code,pass=pass}), 
-- 				3600)
--   if err then
--       logger:error( "failed to get clientIP " .. err )
--       return
--   end
--   return res
-- end

-- --[[
-- 获取用户输入的antispam验证码信息，并进行校验
-- 返回成功失败
-- ]]--
-- function _dk_antispam_check(txid, code)
--   --local args, err = ngx.req.get_post_args()
--   local msg = "";
--   --local txz = ngx.var.cookie__gj_txz
--   local token = nil
--   -- local code = ""
--   -- if not args then 
--   --   msg = "no post data"
--   --   goto fail 
--   -- end

--   if not txid then
--     msg = "no txz found in cookie _ganji_txid"
--     return false
--   end

--   token = dk_antispam_gettoken(txid)
--   if not token then
--     msg = "no token found in mc:" .. txid
--     return false
--   end
--   -- 如果没有提交，返回失败
--   -- !!! must tonumber, maybe because charset encoding issue
--   -- i thinks convert to str with .. and compare also works
--   if tonumber(token.code) ==tonumber( code) then
--     -- 验证通过
--     dk_antispam_settoken( txid, code, 1)
--     return true
--   end
--   msg = "don't match:" .. "," .. code .. string.len(code) .. "," .. token.code .. string.len(token.code)

--   logger:error( msg )
--   return false
-- end 

--
--
--
function dk_txid_install()
  local code = math.random(8999)+1000
  local txid = ngx.encode_base64( ngx.hmac_sha1(SECRET_KEY, tostring(code)) )
  ngx.header['Set-Cookie'] = {"_gj_txid=" .. txid }
  return code
end

function dk_txid_check(code)
  local txid = ngx.encode_base64( ngx.hmac_sha1(SECRET_KEY, tostring(code)) )
  -- logger:error( txid .. ":" .. ngx.var.cookie__gj_txid or '')
  return txid == ngx.var.cookie__gj_txid
end
--
-- 注入 ganji.com/ 的_gj_txz的cookie
--
function dk_txz_install()
  local dt = os.time()+TXZ_EXPIRE
  local txz = ngx.encode_base64( tostring(dt) .. ":" .. ngx.hmac_sha1(SECRET_KEY, tostring(dt)) )
  ngx.header['Set-Cookie'] = {"_gj_txz=" .. txz .. "; expires=" .. ngx.cookie_time(dt) .. "; path=/; domain=ganji.com"}
  return txz
end

--
-- validate txz
--
function dk_txz_check(txz)
    local hmac = ""
    local timestamp = ""
    txz = ngx.decode_base64(txz)
    -- Check that the cookie exists.
    if txz ~= nil and txz:find(":") ~= nil then
        -- If there's a cookie, split off the HMAC signature
        -- and timestamp.
        local divider = txz:find(":")
        hmac = txz:sub(divider+1)
        timestamp = txz:sub(0, divider-1)

        -- Verify that the signature is valid.
        if ngx.hmac_sha1(SECRET_KEY, timestamp) == hmac and tonumber(timestamp) >= os.time() then
            return true
        end
    end  
    return false
end
