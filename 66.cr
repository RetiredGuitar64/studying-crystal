class Animal
  property name
  def initialize(@name : String)
  end

  def hello
    puts "Hi from #{@name}"
  end
end

class Dog < Animal
  def initialize
    super
  end
end

d = Dog.new("dog")
d.hello
