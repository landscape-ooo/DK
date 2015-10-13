local _R = {
{
  domain_r="^.*guazi\\.com",
  target={ group="che"}
  },
{
  domain_r="^.*haozu\\.com",
  target={ group="kuaizu"}
  },  
-- special domain goes here
{
	domain_r="^(ganlanshu|zpwx|hrvip)\\.",
	target={ group="zp"}
	},
{
	domain_r="^(jiazheng|zuche|zhuangxiu|xs|xiche|school|xc|fwapi)\\.",
	target={ group="fw"}	
	},
{
	domain_r="^secondmarket\\.",
	target={ group="wu"}	
	},
{
	domain_r="^(haoche|chesupai)\\.",
	target={ group="che"}	
	},
{
	domain_r="^(union|cp)\\.ganji\\.com",	
	target={ group="ad"}	-- ad
	},
{
	domain_r="^.*yiliao\\.ganji\\.com",
	target={ group="ad"}	
	},
{
	domain="love.ganji.com",
	target={ group="love"},
	},
{
	domain="jiaoyou.ganji.cn",
	target={ group="jiaoyou"},
	},
{
	domain="api.weizhan.ganji.com",
	target={ group="fw"},
	},
{
	domain="duanzu.ganji.com", 
	target={ group="common"},
	},
{
	domain="api.ganji.com",
	target={ group="api" },
	},
-- VIP
{
	domain="vip.ganji.com",
	target={ group="vip", },
	},

{
  domain_modify="wap_modify_domain",
  domain_r="^(wap|3g)\\.ganji",
  target={ city=1, antispam=1 ,mapping='wap_group_mapping'},
  -- when wap is separated , goes here
  _= {
        --- wap pdt specified
      {
        pdt="fang",
        target={ group="fang" },
        },
      { 
        pdt_r="(zhaopin|qiuzhi)",
        target={ group="zp" },
        },
      {
        pdt="huodong",
        target={ group="huodong" },
        },
      {
        pdt="wu",
        target={ group="wu" },
        },
      {
        pdt="jiaoyou",
        target={ group="jiaoyou" },
        },
      {
        pdt_r="che|vehicle",
        target={ group="che" },
        },
      {
        pdt_r="chongwu|pet",
        target={ group="chongwu" },
        },
      {
        pdt="piaowu",
        target={ group="piaowu" },
        },
      {
        pdt_r="self_sticky|self_direction|self_premier|self_refresh|self_resume|self_service",
        target={ group="ad" },
        },
      ---wap _pdt end 
      {
        uri_r="^/zhuangxiu\\w/?",--root path
        target={ group="fw" }
        },
      {
        uri_r="^/(fangweixin|chuzu)/",--root path
        target={ group="fang" }
        }, 
      { -- home page 
        uri_modify="wap_modify_url",
        uri="/",
        target={ group="common", },
        },
      { 
        uri_r="^/(stick|refresh|direction|sticky|tuiguang|yiliao|trading|self_\\w+)/",
        target={ group="ad", },
        },  
      { -- ad 
        uri_modify="wap_modify_url",
        uri_r="^/(refresh|direction|yiliao|tuiguang|stick.*|self_\\w+)/",
        target={ group="ad", },
        },  
      { --fw from pc 
        uri_modify="wap_modify_url",
        uri_r="^/(shenghuo|bendi|training|service_.*|fuwu_.*|jiancaimall|jiazheng|kuaijipx"..
          "|shangwu|fw_pm|\\w+_gs|\\w+_fx|zhuangxiu.*|school|fangxin)/",
        target={ group="fw", }
        },  
      { -- che
        uri_modify="wap_modify_url",
        uri_r = "^/(zuche|vehicle.*|.*haoche.*|fangxinche)/",
          target={ group="che", }
        },                   
      { 
        -- fang special url
        uri_modify="wap_modify_url",
        uri_r='^/(housing|.*fang.*|.*chuzu'..
        '|hezu|loupan|duanzu|qiuzu|xiezilouchushou'..
        '|shangpucs|shengyizr|dianpuzr|'..
        '|cangku|tudi|chewei|xiaoqu)/',
        target={ group="fang", }
        },        
      { --zp
        uri_modify="wap_modify_url",
        uri_r="^/(.*findjob|.*wanted|jianli|resumes|dagongwuyou|cooperation"..
        "|gongsi|zp.*|jz.*|qz.*|qjz.*|zhaopin.*|zhaopinjie|mingqizhaopin"..
        "|qiu.*zhi|jobfairs|dagongwuyou|gz_.*|yizhaopin)/",
        target={ group="zp", },
        },
      { -- wu
        uri_modify="wap_modify_url",
        uri_r = "^/(secondmarket|zq_.*|shouji|zhishi"..
        "|zuche|vehicle.*|.*haoche.*|lieche|brand)/",
          target={ group="wu", }
        },  
      { -- wu
        uri_modify="wap_modify_url",
        uri_r = "^/(pet|chongwu)/",
        target={ group="chongwu", }
        },  
      { -- wu
        uri_modify="wap_modify_url",
        uri_r = "^/(ticketing|piaowu)/",
        target={ group="piaowu", }
        },   
      { -- wu
        uri_modify="wap_modify_url",
        uri_r = "^/(event|huodong)/",
        target={ group="huodong", }
        },  
      { -- wu
        uri_modify="wap_modify_url",
        uri_r = "^/(personals|jiaoyou)/",
        target={ group="jiaoyou", }
        },       
      { -- comm
        uri_modify="wap_modify_url",
        uri_r = "^/(user|search|jinrong|map|fav|nav|link"..
          "|recommend|down|appdown|jianyi|helper|wb|redirect)/",
        target={ group="common", }
        },   
--     { -- comm
--        uri_r = "^/(\\w+).([a-z]+)$",
--        --any case  end with ".php",will be pushed to common
--        --but just  contains one "/"
--        target={ group="common", }
--        },  
      { -- url and tags based on category
        uri_modify="wap_modify_url",
        cat=1,
        target={},
        },
      {
        target={ group="wap", },-- same as common_default
        },
    },
  },
{
	domain="ganji.cn",
	target={ group="wap",}
	},
{
	domain_r="^(mobile|m|mwap|w)\\.ganji",
	target={ group="wap", }
	},
{
        domain_r=".*\\.w\\.ganji",
        target={ group="wap", }
        },
{
	domain_r=".*\\.?ganji\\.com\\.cn",
	target={ group="bangbang",}
	},

{
	uri_r="^/check_idc.js$",
	target={ group="common"},
	},
-- pdt specified
{
	pdt="fang",
	target={ group="fang" },
	},
{	
	pdt_r="(zhaopin|qiuzhi)",
	target={ group="zp" },
	},
{
	pdt="huodong",
	target={ group="huodong" },
	},
{
	pdt="wu",
	target={ group="wu" },
	},
{
	pdt="jiaoyou",
	target={ group="jiaoyou" },
	},
{
	pdt_r="che|vehicle",
	target={ group="che" },
	},
{
	pdt_r="chongwu|pet",
	target={ group="chongwu" },
	},
{
	pdt="piaowu",
	target={ group="piaowu" },
	},
{
	pdt_r="self_sticky|self_direction|self_premier|self_refresh|self_resume|self_service",
	target={ group="ad" },
	},
{
        uri="/ajax.php",
        target={ ajax=1, },
        _= {
	        {
        		target={ group="common_default", },
        		},
        	},
	},
{
	uri_r="^/(v|quanzhi|gongzuo|yingpin|canyinzhaopin)/",
        target={ group="zp",}
        },
{--exclude
        uri_r="^/(huochepiao|lieche|piao|train)/",
        target={ group="common_default",}
        },
{
	uri_r="^/(sorry|common|tel_img|utils|swftool|js|tel|user|vip|help|misc)/",
        target={ group="common",}
        },
-- 城市域名，类目页面(列表，详情)
{  
  	city=1,
  	target={ city=1, antispam=1 },
  	_=	{
  			{	-- home page 
  				uri="/",
  				target={ group="common", },
  				},
  			{	 
  				uri="/search.php",
  				target={ group="common", },
  				},
  			{	
  				uri_r="^/(tuiguang|trading|sticky|self_\\w+)/",
  				target={ group="ad", },
  				},
  			{	-- url and tags based on category
  				cat=1,
  				target={},
  				},
  			{	-- wanted special url
  				uri_r="^/(wanted|jianli|gongsi|zp.*|jz.*|qz.*|qjz.*|zhaopin.*|zhaopinjie|zpjie|mingqizhaopin|qiujianzhi|jobfairs|dagongwuyou|gz_.*|yizhaopin)", --|zpwuyeguanli|qzwuyeguanli|zpbiaoqian|jzbiaoqian
  				target={ group="zp", }
  				},
  			{	-- wanted special url
  				uri_r="^/(fang.*|zufang|reci|shangpu|xiezilou|housing|xinloupan|xiaoquzufang|ershoufang|xinfang)",
  				target={ group="fang", }
  				},  	
  			{
  				uri_r="^/(secondmarket|zq_.*)/",
  			 	target={ group="wu", }
  			 	},
  			{
  				uri_r="^/(service_store|fuwu_.*|jiancaimall|jiazheng|kuaijipx|shangwu|fw_pm|\\w+_gs|\\w+_fx)/",
  				target={ group="fw", }
  				},
            {	
				uri_r = "^/xiaoqu/",
				target={ group="fang", },
				},
            {	
				uri_r = "^/(jinrong|sms|site|pub|passport)/",
				target={ group="common", },
				},
            {	-- COMMON_5  
				uri_r = "^/\\w+\\.html$",
				target={ group="common", },
				},
 			}
	},
-- 公共域名，类目页面
{
	domain="www.ganji.com",
	_={
		{	
			uri="/",
			target={ group="common", },
			},
		{	
			uri_r="^/(tuiguang|trading|sticky|self_\\w+)/",
			target={ group="ad", },
			},
		{	
			uri_r="^/vip/",
			target={ group="vip", },
			},
  		{
  			-- 城市域名公共页面
			uri_r = "^/(aboutus|user|pub)/",
  			target={ group="common", }
  			},
  		{
  			-- help/d-d.html
			uri_r = "^/(\\w+)/\\d+-(\\d+).html?$",
  			target={ group="common", }
  			},
                {
			cat=1,
			target={},
			},
                {       -- quanguo tuiguang 
                        uri_r="^/(quanguo_tuiguang)/",
                        target={ group="common", }
                        },
                {       -- wanted special url
                        uri_r="^/(housing)/",
                        target={ group="fang", }
                        },
		{
			uri_r="^/job/topic/",  -- special
			target={ group="zp", },
			},
		{
			uri_r="^/(resumes|cooperation|wanted|findjob|jianli|gongsi|jobfairs|qiujianzhi|dagongwuyou)/",
			target={ group="zp", },
			},
                {
                        uri_r="^/(lieche)/",
                        target={ group="piaowu", }
                        },
                {
                        uri_r="^/(shoujixinghao|brand)/",
                        target={ group="wu", }
                        },
                {
                        uri_r="^/(service_store|fuwu_dian|training)/",
                        target={ group="fw", }
                        },
		{
			uri_r="^/pay/",
			target={ group="pay",antispam=1 }
			},
		{
			uri_r="^/content/",
			target={ group="common" }   -- ad 联盟
			},
		{
		        cat=1,	
			target={}
			},
		{
		 	target={ group="common_default", },
		 	},
		}
	}

-- end of all
}

return _R
