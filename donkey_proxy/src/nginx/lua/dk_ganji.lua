--
-- main entry for *.ganji.com
--

require "dk_util"
require "dk_req"
local sys = require("dk_sys")
local hosts = require("dk_hosts")
local category = require("dk_category")
local routes = require("dk_rewrite")
require("dk_antispam")
require "dk_dict"
require "dk_cookie"
require "dk_uuid"

local log = require("dk_log")
local logger = log.getLogger("dk.ganji")

local _GANJI_PC = {}
local VERIFY_PAGE_URL_WAP="http://wap.ganji.com/sorry/confirm.php"
local VERIFY_PAGE_URL_WEB="http://www.ganji.com/sorry/confirm.php"

local UNI_REQ_HEADER = "X-ganji-reqid"

--
-- initialize shared data, called during init_by_lua
--
function _GANJI_PC.init_ngx( sd_host, sd_category, persist_dir )
    _GANJI_PC.init( DICT:newFromSharedDict(sd_host), DICT:newFromSharedDict(sd_category))
    category.load( persist_dir .. "/category.json")
    hosts.load( persist_dir .. "/city.json")
    local _R = loadfile(persist_dir .. "/r.lua")
    routes.routes = _R()
end

function _GANJI_PC.init( sd_host, sd_category )
    if sd_host == nil then
        sys.error("sd_host not exists")
    end
  hosts.init( sd_host )

    if sd_category == nil then
        sys.error("sd_category not exists")
    end
  category.init( sd_category )
end

--
-- initialize per-worker 
--
function _GANJI_PC.init_worker()
    dk_uuid_init()
end

function _GANJI_PC.genReqId()
    -- generate unique request id if missing
    local headers = ngx.req.get_headers()
    if headers[UNI_REQ_HEADER] == nil then
        local reqid = dk_uuid_gen()
        ngx.req.set_header(UNI_REQ_HEADER, reqid )
        logger:debug("request id is :" .. reqid )
    end
end

function _GANJI_PC.handleNgx(parse_only, antispam)

    -- generate unique visitor id ???
    -- TODO

    -- call router
  local req = REQ:newFromNgx(ngx)
  local r = _GANJI_PC.handleReq(req, parse_only, antispam)
    return r
end

--[[
 确认请求是否需要过anti-spam
 HTTP_GET
 no valid cookie
 业务允许
]]--
function _GANJI_PC.shouldAntispam(req)
  -- if not get or don't allow antispam
  if not req:isGet() 
    -- or not req.info.antispam 
  then
    return false
  end

    if dk_txz_check(ngx.var.cookie__gj_txz) then 
        return false
    end
    return true
end

--
-- handle ganji_pc request
-- parse_only , do parse but not generate response
-- antispam, disable antispam in QA environment
--
function _GANJI_PC.handleReq( req, parse_only, antispam )
  --  logger:debug(req)

  --
  -- go thru custom route table
  --
  local r = routes.route(req)
  if r then
    req.info = r
  else
    -- logger:warn('unknown path')
    -- check /a/b/c => /a/b/c/
    local i = string.find(req.uri,"[%.%?&]")
    if i == nil and string.sub(req.uri, -1) ~= "/" then
      return ngx.redirect("http://".. req.host .. req.uri .. "/", ngx.HTTP_MOVED_PERMANENTLY)
    end
    req.info = nil
  end

  --
  -- 如果仅仅是解析，则直接返回
  --
  if parse_only then return r end

  if ngx then
    -- for subrequest, must read body first, required by Nginx
    ngx.req.read_body()
  end

  if antispam and _GANJI_PC.shouldAntispam(req) then
    -- no valid cookie, check spam service
    local body = sys.json_dump( dk_antispam_create() )

    local res = ngx.location.capture("/_/check-spider",
      { method = ngx.HTTP_POST, body=body } )

    if res.status ~= ngx.HTTP_OK then
      logger:error(' spider service response error,which http_status '..res.status)
      return req.info
    end
    
    --try catch json parse  error
    local try_parse_spider=function(res)
      if sys.json_loads(res.body)['status'] and
        tonumber(sys.json_loads(res.body)['status']) >4  then
        return true
      end
      return false
    end
    
    local is_json=pcall(try_parse_spider, res) --try parse 
    local is_spider=false
    if is_json then 
      is_spider=try_parse_spider(res)
    end 
       
    if is_spider then
      local _host_v=ngx.var.host
      if _host_v:match("[wap|3g]%.ganji") then
        return ngx.redirect(VERIFY_PAGE_URL_WAP .. "?from=wap&continue=" .. ngx.escape_uri(req.getFullUri()))
      end

      return ngx.redirect(VERIFY_PAGE_URL_WEB .. "?continue=" .. ngx.escape_uri(req.getFullUri()))
    end

    -- TODO: maybe don't check for a while?
  end
  return req.info
end

--
-- 处理通行证
--
function _GANJI_PC.handleWebCheckCode()
    local req = REQ:newFromNgx(ngx)
    local msg = ""
    local olduri = ""
    ngx.header.content_type = 'text/html; charset=utf-8';
    if req.method == "GET" then
        local args = ngx.req.get_uri_args()
        code = args['code'] or ""
        if dk_txid_check(code) then
            msg = '{"status":true}'
            dk_txz_install()
            ngx.print( msg )
            ngx.exit(200)
            return
        end
    end
    ngx.print( '{"status":false}' )
    ngx.exit(200)
    return

end

function _GANJI_PC.handleWapCheckCode()
    local req = REQ:newFromNgx(ngx)
    local msg = ""
    local olduri = ""
    if req.method == "GET" then
        local args = ngx.req.get_uri_args()
        code = args['code'] or ""
        if dk_txid_check(code) then
            dk_txz_install()
            return ngx.redirect( args['continue'] )
        end
    end
    return ngx.redirect( VERIFY_PAGE_URL_WAP )
end
--
-- 如果有cookie，则取之前的token
-- 如果没有cookie，或者token不存在，则生成新的token
--
function _GANJI_PC.handleImage()
    local code = dk_txid_install()
    return code
end

function _GANJI_PC.filterHeader()
    dk_dump_setcookie()
end
return _GANJI_PC
