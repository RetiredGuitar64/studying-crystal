t1 = Thread.new {sleep 1.second; puts 1}
t2 = Thread.new {sleep 1.second; puts 2}
t3 = Thread.new {sleep 1.second; puts 3}

[t1,t2,t3].each(&.join)
