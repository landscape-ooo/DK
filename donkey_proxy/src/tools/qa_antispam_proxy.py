#coding=utf-8
"""
qa 环境下antispam服务代理
"""
import web
import StringIO
import simplejson as json
from PIL import Image,ImageDraw,ImageFont  
import random  
import math 

urls = (
    '/antispam', 'antispam',
    '/sorry/confirm.php', 'confirm',
)
app = web.application(urls, globals())

class antispam:
    def POST(self):
        data = web.data()
        print data 
        r = json.loads(data)
        if r['req_str'].find("spam")>=0: return "spam"
        return "ok"
class confirm:
    def GET(self):
        print web.req
        return "ok"
if __name__ == "__main__": 
    app.run()
