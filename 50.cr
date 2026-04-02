x = 1

add = -> do  # 这里就是无参数的proc, -> {} , ->后面直接跟的block
  x = x + 1
  x
end

p add.call # => 2
p add.call # => 3
p add.call # => 4
p add.call # => 5
p x        # => 5
