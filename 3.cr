ch = Channel(Nil).new

puts 1

spawn(name: "fibera") do
puts 2
  spawn(name: "fiberb") do
  puts 3
    sleep 1.second
    puts 4
  end
  puts 5
  ch.receive
puts 6
end

puts 7
ch.send nil
puts 8


