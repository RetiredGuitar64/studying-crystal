def split_path(path)
  parts = path.split("/")
  {filename: parts.last, filedepth: parts.size}
end   # 这里返回一个namedtuple, 分别保存split后的最后一部分,和有几层

info = split_path("src/utils/test.cr")

pp typeof(info)  # => NamedTuple(filename: String, filedepth: Int32)

pp name = info[:filename]    # => "test.cr"
pp depth = info[:filedepth]  # => 3         用symbol类型的key去获取
