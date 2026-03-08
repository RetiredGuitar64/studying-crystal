require "wait_group"

# 消费者创建 8 个 scheduler, 允许运行在最大 8 个 Thread 之上
consumers = Fiber::ExecutionContext::Parallel.new("consumers", 8)
puts "before spawn: size=#{consumers.size}, capacity=#{consumers.capacity}" # before spawn: size=0, capacity=8

channel = Channel(Int32).new(64) # 典型的，生产者 buffered channel 入队的场景。见 （1）
wg = WaitGroup.new(32) # 这里增加基数，确保执行 32 次 wg.done 之后，主 Fiber 才会退出。见 （2）,（3）

result = Atomic.new(0) # 因为是 parallel, 所以必须使用 Atomic 避免数据竞争、保证原子更新。

32.times do |i|
  consumers.spawn name: "fiber-#{i}" do # 新建一个 fiber, 并且加入到 consumers 这个 EC

    if sch = Fiber::ExecutionContext::Scheduler.current?
	  # 打印 debug 信息，看看到底有启动几个 scheduler
      puts "Fibers: [#{Fiber.current.name}] scheduler=#{sch.name} status=#{sch.status}"
    end

    while value = channel.receive?
      result.add(value)
    end
  ensure
    wg.done # (3) 每个 fiber 内，退出 while 才会执行 wg.done
  end
end

puts "after spawn: size=#{consumers.size}, capacity=#{consumers.capacity}" # after spawn: size=2, capacity=8，size 是变化的

1024.times { |i| channel.send(i) } # (1) 生产者入队

puts "after produce: size=#{consumers.size}, capacity=#{consumers.capacity}" # after produce: size=8, capacity=8，size 是变化的

channel.close # 入队完之后，关闭通道，最终，消费完后，channel.receive? 都会返回 nil

wg.wait  # (2) wait for all workers to be done

# after wait: size=8, capacity=8，size 是变化的，但是和 after produce 完全一致
#  因为 size 表示启动过(started)的线程，虽然活已经干完了，但这些线程/对应 scheduler 还没有被销毁，甚至可能只是空闲/暂停
puts "after wait: size=#{consumers.size}, capacity=#{consumers.capacity}" 

p result.get # => 523776，从 0 加 到 1023 的结果
