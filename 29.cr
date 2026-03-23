(1..100).each do |i|
  case {i % 3, i % 5}  # 一个tuple, 包含两个Int32, 并分别对3和5取余
  when {0, 0}          # 当tuple中的两个数都是0
    puts "#{i}可以同时除尽3和5"
  when {0, _}          # 只有第一个是0, 第二个是 _ ,也就是无所谓
    puts "#{i}能除尽3"
  when {_, 0}          # _ 这个语法跟go很像, 就是忽略,随意,无所谓
    puts "#{i}能除尽5"
  end
end
