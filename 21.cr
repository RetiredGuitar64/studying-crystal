class Worker
  getter status
  def initialize
    @status = :stop
  end

  def start
    @status = :running
  end

  def stop
    @status = :stop
  end
end

work = Worker.new
puts work.status  # => stop

work.start
puts work.status  # => running
