
r = Random.new
num = r.rand   # 0-1 之间的随机小数
puts num
var = num > 0.5 ? 100 : "crystal"

case var
when String
  puts "var is #{var} and type is #{typeof(var)}"
when Int32
  puts "var is #{var} and type is #{typeof(var)}"
end
