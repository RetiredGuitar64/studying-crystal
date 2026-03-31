def use_proc(&block)
  block
end

proc = use_proc {puts "212313"}
pp typeof(proc)
proc.call

