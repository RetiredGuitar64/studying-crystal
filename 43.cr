num = 10

add = ->(x : Int32) do
  num = x * num
end

pp add.call(3)
pp add.call(3)

