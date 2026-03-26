def split_path(path)
  parts = path.split("/")
  {parts.last, parts.size}
end
name, depth = split_path("src/utils/test.cr")

pp name # => "test.cr"
pp depth # => 3

