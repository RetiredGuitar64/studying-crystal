output = IO::Memory.new
error = IO::Memory.new

status = Process.run(
  "fc-match",
  ["-f", "%{file}", "sans-serif"],
  output: output,
  error: error
)
path = output.to_s.chomp

puts path
