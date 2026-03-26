def rect(name, *, width, height)  # 裸*后面的参数必须要手动指定
  "#{name} is #{width}x#{height}"
end

puts rect("box", width: 10, height: 21)  # 不写命名会报错expected named argument
