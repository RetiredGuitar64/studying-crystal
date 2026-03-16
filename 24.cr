enum Color
  Red
  Blue
  Green
end

def paint(color : Color)
  puts "color is #{color}"
end

paint Color::Red
paint :Blue
