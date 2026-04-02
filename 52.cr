x = 1
changer = -> do
  x = "Hello"
end

p typeof(x) # => (Int32 | String) 可以看到,在changer运行以前, x的编译类型就已经为联合类型了
p x.class   # => Int32            尽管它的实际类型只是Int32

changer.call # 改变类型

p typeof(x) # => (Int32 | String) 改变后依然是联合类型
p x.class   # => String
