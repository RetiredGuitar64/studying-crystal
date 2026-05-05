def method(a, b)



  yield a,b
  




end


puts method(3,5) { |a, b|
  a + b
}

puts method(3,5) { |a, b|
  a * b
}
