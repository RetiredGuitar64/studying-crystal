p1 = -> {puts "hello"} # 注册一个proc, 输出hello

def invoke(&block) # 方法要求接收一个block
  block.call  #把这个block再变成proc然后call
end

invoke(&p1) # 这里需要加 &p1, 把p1这个proc变成block, 再传给invoke方法, 不加的话,会报错 Error: 'invoke' is expected to be invoked with a block, but no block was given
