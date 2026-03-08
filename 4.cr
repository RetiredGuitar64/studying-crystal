def a
  yield 1
end

l = ->(x : Int32) { print x }

a(&l)
