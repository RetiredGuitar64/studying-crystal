def add(x, y)
  x + y
end
pair = {2, 3}  # tuple

pp result = add(*pair)  # => 5
# 可以通过 * 把tuple展开为参数, 传递给方法

