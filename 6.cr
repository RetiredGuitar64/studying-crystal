require "http"

web = "https://zhjw.nuc.edu.cn/jwglxt/xsxk/zzxkyzb_cxZzxkYzbIndex.html?gnmkdm=N253512&layout=default"

ch = Channel(String).new(10)
time : Int32 = 100

time.times do
  spawn getweb(web, ch)
end

def getweb(web, ch)
  response = HTTP::Client.get(web)
  ch.send response.body
  puts response
end

time.times do
  ch.receive
end
