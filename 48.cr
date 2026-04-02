p1 = ->(x : Int32, y : Int32) : String { (x + y).to_s} # 创建proc

pp p1.call(1, 2)  # => "3"  通过.call调用proc
