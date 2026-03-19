ntuple = {
  name: "Conor",
  age: 20
}

pp ntuple[:name]
pp typeof(ntuple)
pp typeof(ntuple[:name])


# 这是哈希
hash = {
  :name => "Conor",
  :age => 20
}

pp hash[:name]


nstuple = {
  "name": "Conor",
  "age": 20
}

pp nstuple["name"] 
