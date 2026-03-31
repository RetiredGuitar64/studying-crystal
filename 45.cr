def make_proc(&block : Int32 -> Int32) # 这里参数接收一个block,而且必须是输入值为int,返回值为int的block, 但是这个类型并不强制要写
  block # 这里就已经将block创建为proc, 并返回了这个proc(因为在代码的最后一行)
end

p1 = make_proc{|x| x + 1} # 将这个int, int的block传进去, 返回来的p1就是proc对象了
pp p1.call(1)  # => 2    调用proc
