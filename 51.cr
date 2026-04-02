def make_counter(start : Int32)
  x = start
  -> {
    x += 1
  }
end


c1 = make_counter(0)
c2 = make_counter(100)

puts c1.call   # => 1
puts c1.call   # => 2
puts c2.call   # => 101
puts c2.call   # => 102

