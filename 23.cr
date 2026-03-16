enum Direction
  North # => 0
  East  # => 1
  West  # => 2
  South # => 3
end

pp Direction::South.value  # => 3

direct = Direction::North



enum TrafficLight
  Red
  Yellow
  Green
end

light = TrafficLight::Red

case light
when TrafficLight::Red
  puts "停"
when TrafficLight::Yellow
  puts "注意"
when TrafficLight::Green
  puts "走"
end
