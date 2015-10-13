#coding=utf8
"""
将请求从一台机器，复制到另外一台donkey-proxy机器，只进行url解析，不实际操作
"""
import sys
import urllib2

def parse_url(server_ip, host, path):
  req = urllib2.Request('http://'+server_ip+path)
  req.add_header('Host', host )
  req.add_header('x-parse-only', 1 )
  try:
    r = urllib2.urlopen(req)
    return r.read()
  except Exception,e:
    print e, path, 'failed'
    return 'error'
def run(server_ip):
  while True:
    l = sys.stdin.readline()
    ll = l.strip()
    # print ll
    vars = ll.split(' ')
    if not vars[4].startswith("["): continue
    if vars[6][1:4] != "GET": continue
    if not vars[7].startswith( "/"): continue
    if vars[7] == "/favicon.ico": continue
    if not vars[11] in ("200","302"): continue
    path = "http://"+vars[2]+vars[7]
    #print vars[6][1:],path, vars[11]
    o = parse_url(server_ip,vars[2], vars[7])
    if o.strip() != vars[13].strip():
      print "return ",o[:10]
      print "local pd=",vars[13], path
    #else:
    #  print 'ok'
if __name__ == "__main__":
  run(sys.argv[1])