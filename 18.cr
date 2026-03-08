module Find
  def known?(name : String)
    @@known.includes?(name)
  end
end

class Mineral
  extend Find

  @@known = [] of String
  def initialize(@name : String)
    @@known << @name
  end
end

iron = Mineral.new("iron")

pp Mineral.known?("iron")
pp Mineral.known?("redstone")

