def test
  yield 1
  yield 2
  yield 3
end

test do |n|
  next if n == 2
  puts "in the block #{n}"
end
