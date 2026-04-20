def greet(name : String)
  "Hello, #{name}"
end

def greet(times : Int32)
  "Hi " * times 
end

puts greet("Conor")
puts greet(2)
