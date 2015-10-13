import web
import StringIO
import simplejson as json
from PIL import Image,ImageDraw,ImageFont  
import random  
import math 

urls = (
    '/sorry', 'sorry',
    '/captcha/(.*)', 'captcha',
    '/antispam', 'antispam',
    '/cookie/(\d+)/', 'cookie',
    '/(.*)', 'hello',
)
app = web.application(urls, globals())

class hello:
    def GET(self, name):
        i = web.input(times=1)
        web.setcookie('age', i, 3600)
        if not name: name = 'world'
        for c in xrange(int(i.times)): print 'Hello,', name+'!'

class cookie:
    def GET(self,i):
        for n in xrange(int(i)):
            web.setcookie('age'+str(n), i,3600, "test.ganji.com", True)
        return "<html><body>done</body></html"

class antispam:
    def POST(self,name):
        data = web.data()
        print data 
        r = json.loads(data)
        if r['req_str'].find("spam")>=0: return "spam"
        web.setcookie('age', 41, 3600)
        return "ok"

class captcha:
    def GET(self,code):
        output = StringIO.StringIO()
        width = 100  
        height = 40  
        bgcolor = (255,255,255)  
        image = Image.new('RGB',(width,height),bgcolor)  
        #font = ImageFont.truetype('FreeSans.ttf',30)  
        fontcolor = (0,0,0)  
        draw = ImageDraw.Draw(image)  
        draw.text((0,0),code,fill=fontcolor)  
        del draw
        image.save( output,"PNG")
        return output.getvalue() 

class sorry:
    def GET(self):
        return """
<html><body><img src="/code.png" /><span>MSG</span><form action="/sorry.htm" method="POST"><input type="hidden" value="OLDURI" name="_uri"><input name="code"></input><input type="submit"></form></body></html>
"""
if __name__ == "__main__": 
    app.run() 
