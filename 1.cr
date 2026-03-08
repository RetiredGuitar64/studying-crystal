ch = Channel(String).new
puts "1" * 100
spawn { ch.send "hello" }
def sendhello(ch)
  ch.send "hello"
end

puts "2" * 100
puts ch.receive
puts "3" * 100
