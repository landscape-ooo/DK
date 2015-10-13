--
-- dk rewrite
-- 
local sys=require("dk_sys")
local hosts = require("dk_hosts")
local category = require("dk_category")
local log = require("dk_log")
local logger = log.getLogger("dk.rewrite")

local _ROUTES = { }
-- {p=pattern, domain=pattern, }

local _FUNCTIONS = {}
local _PLUGINX = {}

local function match_cat(uri)
	local paths = string.split(uri,"/")
	if #paths < 2 then 
		return false
	end
	local path_info = category.getPathInfo( paths[2] )
	return path_info
end

local function match_city(host)
	local host_info = hosts.getHostInfo(host)
	-- print_lua_table("====>",host, host_info)
	return host_info
end

local function match_str(input, pattern)
	return ( not pattern ) or ( input == pattern )
end

local function match_re(input, pattern)
	if not pattern then
		return true 
	end
	if input == nil then
		return false
	end
	local r = sys.re_match(input, pattern)
	--print(input, pattern, r)
	return r
end

--
-- iterator thru pattern hierachy
-- each pattern contans domain, domain_r, uri, uri_r, method, method_r
--
local function recur_match(req, routes, _target)
  for i,r in ipairs(routes) do
    if r then
      local req_uri = req.uri
      local req_host = req.host
      if r.uri_modify or r.domain_modify  then 
         -- domain
         if  _PLUGINX[r.domain_modify] 
          and pcall(_PLUGINX[r.domain_modify] ,req_host) then 
           req_host=_PLUGINX[r.domain_modify](req_host)
         end  
         --domain
         if  _PLUGINX[r.uri_modify] 
          and pcall(_PLUGINX[r.uri_modify] ,req_uri) then 
           req_uri=_PLUGINX[r.uri_modify](req_uri)
         end  
      end   
      local target = _target or {}
      local m_host=false
      local m5=false
      local m_url=false
      -- print_lua_table(r )
      local m_pdt=match_str(req.pdt, r.pdt) and match_re( req.pdt, r.pdt_r)
      if r.city then
        -- 处理城市站匹配
        local t = match_city( req_host )
        if t then
          --table.merge(target, r.city)
          m_host = true
        end
      else 

        m_host = match_str( req_host, r.domain ) and match_re( req_host, r.domain_r )
      end

      if r.cat then
        -- 处理类目url
        local t = match_cat( req_uri )
        if t then
          -- 如果匹配，保存target
          table.merge(target, t)
          m_url = true
        end
      else
        -- support flex uri matching
          -- print_lua_table( r )
        if r.uri_f then
          local t = _FUNCTIONS[r.uri_f](req_uri)
          if t then
            table.merge(target,t)
            m_url = true
          end
        else
          m_url = match_str( req_uri, r.uri ) and match_re( req_uri, r.uri_r)
        end
      end

      -- 处理其它url
      m5 = not r.method or ( req.method == r.method )
      -- print(m_host,m_url,m5,m_pdt)
      -- print( "DEBUG:", req_uri, "->",format_lua_table(r,1))
                        logger:debug( {uri=req_uri, info=r})

      if m_host and m_url and m5 and m_pdt then
        table.merge(target, r.target or {} )
        -- if nested , move on
        if target.mapping then
           if  _PLUGINX[target.mapping] 
              and pcall(_PLUGINX[target.mapping] ,target) then 
                target=_PLUGINX[target.mapping](target)
           end  
        end 
        if r._ then 
          return recur_match( req, r._, target )
        end
        logger:debug( r )
        return target
      end
    end
  end
  return nil
end

--
-- 匹配规则
-- TODO: 暂不支持嵌套的匹配
--
function _ROUTES.route( req )
	return recur_match( req, _ROUTES.routes )
end

---
--@param str
--@desc 
-- uri: delete {city}_ or {city}/  in uri 
-- eg:/bj_zpsiji/ ===> /zpsiji/
---
local function WAP_MODIFY_URI(req_origin_uri)
  local uri_modify_r={'^/([a-z]+)[_|/]','/'} --/bj_zpsiji/ ===>  /zpsiji/
  return string.gsub(req_origin_uri,uri_modify_r[1],uri_modify_r[2])
end

_PLUGINX['wap_modify_url'] = WAP_MODIFY_URI

---
--@param string
--@desc 
-- host: long level to 2 level
-- eg:sss.3g.ganji.com ===> 3g.ganji.com
---
local function WAP_MODIFY_DOMAIN(req_origin_host)
   local host_modify_r ={'(.+%.)(3g%.ganji)','%2'} 
   req_origin_host=string.gsub(req_origin_host,host_modify_r[1],host_modify_r[2])
   host_modify_r={'(.+%.)(wap%.ganji)','%2'} 
   req_origin_host=string.gsub(req_origin_host,host_modify_r[1],host_modify_r[2])
   return req_origin_host
end

_PLUGINX['wap_modify_domain'] = WAP_MODIFY_DOMAIN

---
--@param parseInfo as target
--  :group
--@desc   
--wap's group director
-- who merge pc to wap ,then set table_wap_server.{key}=false, or delete it
--   when u do that  , upstream will pass to match's pc group 
---
local function WAP_GROUP_MAPPING(parseInfo)
  local table_wap_server={
--    wu='wap', chongwu='wap', che='wap', piaowu='wap', huodong='wap',jiaoyou='wap',
--    common='wap', zp='wap', fw='wap', fang='wap',ad="ad",
  }
  if parseInfo.group and table_wap_server[parseInfo.group] then 
    parseInfo.group=table_wap_server[parseInfo.group]
  end   
  return parseInfo;
end 
_PLUGINX['wap_group_mapping'] = WAP_GROUP_MAPPING


return _ROUTES
