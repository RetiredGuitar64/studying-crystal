class Downloader
  def on_finish(&block : String ->) # 这个事件, 用于在下载完成后执行, 但是执行什么呢, 由后面的外部决定, 
    @on_finish = block  # 将传入的block转为proc, 并保存在@on_finish中
  end

  def download
    puts "Downloading..."
    file = "xxx.pdf" # 下载流程, 文件只是举例, 为String
    sleep 2   # 下载

    # download方法是知道何时下载完的, 下载完就执行下面的if 来处理下载完成后需要干嘛
    if proc = @on_finish # 假如@on_finish不为nil, 就执行
      proc.call(file) # 这里会call之前已经注册好的proc, proc里面就是外部传进来的代码(也就是在下载完后打算执行的内容(puts ...) )
    end

  end
end

d = Downloader.new
d.on_finish {|filename| puts "#{filename} 下载完成!"} # 注册一个proc到@on_finish中
# 这一行会把下载完成后,想要执行的逻辑传给on_finish方法, 并注册一个proc, 然后将这个proc保存到@on_finish里面

d.download # download知道多会下载完, 下载完就执行上面已经提前写好的逻辑了, 这就是callback 

解释:
这里的意义就是：

- Downloader 知道“下载什么时候结束”
- 但它不想写死“结束后要干嘛”
- 所以它开放一个口子：on_finish
- 外面谁想订阅这个事件，就塞一段逻辑进来

这就是 callback 的典型价值：
让对象提供“事件点”，让外部决定“事件发生后做什么”。
