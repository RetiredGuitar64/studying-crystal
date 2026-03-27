def foo(**options)
  pp options
  pp typeof(options)
end

foo(x: 10, y: 20)
