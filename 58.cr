def show(x : Int32)
  puts "#{x} 是整数"
end

def show(x : String)
  puts "#{x} 是字符串"
end

x = rand < 0.5 ? 21 : "Conor"

pp typeof(x)
puts show(x)
pp x.class
