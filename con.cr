require "http/client"

# response = HTTP::Client.get "www.baidu.com"
# p response

webs = [
  "www.baidu.com",
  "www.qq.com",
  "www.taobao.com",
  "www.jd.com",
  "www.tmall.com",
  "www.sina.com.cn",
  "www.sohu.com",
  "www.163.com",
  "www.ifeng.com",
  "www.bilibili.com",
  "www.zhihu.com",
  "www.douban.com",
  "www.weibo.com",
  "www.xiaohongshu.com",
  "www.dianping.com",
  "www.meituan.com",
  "www.alipay.com",
  "www.icbc.com.cn",
  "www.cmbchina.com",
  "www.ctrip.com",
  "www.58.com",
  "www.lagou.com",
  "www.jianshu.com",
  "www.csdn.net",
  "www.cnblogs.com",
  "www.gitee.com",
  "www.oschina.net",
  "www.hupu.com",
  "www.zcool.com.cn",
  "www.4399.com",
  "www.xunlei.com",
  "www.kugou.com",
  "www.qidian.com",
  "www.autohome.com.cn",
  "www.gmw.cn",
  "www.people.com.cn",
  "www.xinhuanet.com"
]
result = ""

ch = Channel(String).new

webs.each do |web|
  spawn getweb(web, ch)
end

def getweb(web, ch)
  response = HTTP::Client.get(web)
  ch.send response.body
  puts "body of #{web}"
end

webs.size.times do 
  result += ch.receive
end

pp result
