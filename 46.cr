def plus(x, y)
  x + y
end

p2 = ->plus(Int32, Int32) #将方法里的逻辑创建为一个proc
        # 因为这个方法有两个参数, 所以创建的proc也要有两个参数, 而且要说明类型, 即 Int32, Int32
        # 如果方法没有参数, 那就proc也不需要参数, 直接 ->plus 就行
pp p2.call(2, 3) # => 5
