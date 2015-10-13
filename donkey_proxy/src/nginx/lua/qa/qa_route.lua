-- 为了方便大家切换测试环境和开发环境，提供了一个动态切换机制
-- read from config folder
-- get 
local sys = require "dk_util"
local qa = require "qa_base"
local user_addr = ngx.var.remote_addr

local BUSINESS = {
	common="公共",
	zp="招聘",
	ad="自助",
	wu="jiaoyi.二手",
	huodong="jiaoyi.活动",
	jiaoyou="jiaoyi.同乡",
	piaowu="jiaoyi.票务",
	chongwu="jiaoyi.宠物",
	che="jiaoyi.车",
	fw="服务",
	love="交友",
	api="??",
	vip="会员中心",
	bangbang="帮帮",
	fang="房产",
	pay="支付"	
}

if string.len(user_addr)==0 then
  	ngx.say("no remote_addr found, pls contact SA for help!!!")
  	ngx.exit(ngx.HTTP_FORBIDDEN)
end
local method = ngx.req.get_method()

function render_get()
	local config = qa.getconfig(user_addr)
	ngx.header.content_type = 'text/html; charset=utf-8';
	-- render page here
	local content = '		\
	<html><body><span>请选择需要切换到开发环境的项目：</span>			\
	<form action="." method="POST">					\
	<table>					\
	'

	function format_input(k,v)
		local r = '<tr><td>' .. v .. '</td><td><input type="checkbox" name="'.. k .. '" value="' .. v .. '" '
		if config[k] ~= nil then
			r = r .. "checked"
		else

		end
		r = r .. "></input></td></tr>"
		content = content .. r
	end

	table.foreach( BUSINESS, format_input)

	content = content .. '		\
	<tr><td><input type="submit"></input></td></tr> \
	</table></form>						\
	</body></html>				\
		'
	ngx.say(content)
end

function render_post()
	ngx.req.read_body()	
	ngx.header.content_type = 'text/html; charset=utf-8';
	local args, err = ngx.req.get_post_args()
	-- table.foreach( args, function(k,v) ngx.say(k..v) end )
	qa.setconfig(user_addr, args)
	ngx.say("set success!");
end

if method == "GET" then
	render_get()
else
	render_post()
end