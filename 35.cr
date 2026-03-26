def add(*numbers)
  pp typeof(numbers)  # Tuple(Int32, Int32, Int32, Int32)
  numbers.reduce() { |acc, num| acc + num}  # 迭代器, 把所有数字加起来, 并返回这个值
end

pp add(1,1,1,2) # => 5
pp add(2,2,2,2,2) # => 10
