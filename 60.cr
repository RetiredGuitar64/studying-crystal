original = {"foo" => [1, 2, 3]}

shallow = original.dup
deep = original.clone

original["foo"] << 4

pp shallow # {"foo" => [1, 2, 3, 4]}
pp deep    # {"foo" => [1, 2, 3]}

# shallow["foo"] 和 original["foo"] 指向同一个数组
# deep["foo"] 是一个新的数组副本
