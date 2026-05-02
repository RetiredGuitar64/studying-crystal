require "wait_group"

def collatz(seed : Int64)
  steps = 0_i64

  while seed > 1
    while seed % 2 == 0
      steps &+= 1
      seed //= 2
    end

    if seed > 1
      steps &+= 1
      seed = seed &* 3 &+ 1
    end
  end

  steps
end

def calculate(total_seeds, batch_size, worker_size, batches)
  channel = Channel({Int64, Int64}).new(batches + 1)
  wg = WaitGroup.new(worker_size)

  p! batch_size
  p! batches

  mt = Fiber::ExecutionContext::Parallel.new("test", maximum: worker_size)

  worker_size.times do |i|
    mt.spawn(name: "WORKER-#{i}") do
      while (r = channel.receive?)
        (r[0]...r[1]).each do |seed|
          steps = collatz(seed)

          if seed % 1_000_000 == 0
            print "Seed: #{seed} Steps: #{steps}\r"
          end
        end
      end
    ensure
      wg.done
    end
  end

  start = Time.measure do
    r0 = 0_i64

    batches.times do
      r1 = r0 &+ batch_size
      channel.send({r0, r1})
      r0 = r1
    end

    if total_seeds - batch_size &* batches > 0
      channel.send({r0, total_seeds})
    end

    channel.close
    wg.wait
  end

  puts "\ncollatz took: #{start}"
end

total_seeds = 5_00_000_000_i64
worker_size = ENV.fetch("CRYSTAL_WORKERS").to_i

p! total_seeds
p! worker_size

batches = ARGV[0]?.try &.to_i || 2000
batch_size = (total_seeds // batches).to_i32
calculate(total_seeds, batch_size, worker_size, batches)
