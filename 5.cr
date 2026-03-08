ch = Channel(String).new
arr = ["a","b","c"] of String

while 1
  arr.each do |s|
    spawn do
      ch.send(s)
    end
  end

  3.times { puts ch.receive }
end
