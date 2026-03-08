module HasNumber
  def double_number 
    number * 2
  end
end

class Mineral
  include HasNumber

  getter number
  
  def initialize(@name : String, @number : Int32)
  end
end

min = Mineral.new("iron", 2)
pp min.double_number
