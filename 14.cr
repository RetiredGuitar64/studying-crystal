hash = {
  "Bob" => 1,
  "Nick"=> 2
}

p hash["Bob"]   # => 1
p typeof(hash)  # => Hash(String, Int32)

p hash.has_key? "Amy"  # => false

hash["Amy"] = 3
p hash.has_key?("Amy") # => true
