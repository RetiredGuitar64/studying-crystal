def add(x, y)
  x + y
end

def add(x : String, y : String)
  x + y + " From the second add"
end

puts add(1, 2)    # => 3
puts add("A", "B") # => AB From the second add
