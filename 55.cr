mutex = Mutex.new
x = 0

spawn do
  mutex.synchronize do
    x = x + 1
    puts "fiber 1: #{x}"
  end
end

spawn do
  mutex.synchronize do
    x = x + 2
    puts "fiber 2: #{x}"
  end
end

sleep 1.second
puts x
