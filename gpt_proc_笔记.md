
下面我给你整理成一份**适合现在阶段复习的 Proc 笔记**。
我会尽量写成“你以后回头看也能一下想起来”的风格。

---

# Crystal `Proc` 笔记

## 1. `Proc` 到底是什么

**一句话：`Proc` 是“可调用对象”。**
它本质上代表“一段可以被保存、传递、返回、稍后再执行的代码”。
普通的 block 只是“跟着方法调用一起传进去的一段代码”；**当 block 被捕获后，它才会变成 `Proc`**。([The Crystal Programming Language][1])

最小例子：

```crystal
adder = ->(x : Int32, y : Int32) { x + y }
puts adder.call(1, 2)   # => 3
```

---

## 2. 先分清三个东西：block、`yield`、`Proc`

你可以先这样记：

* **block**：调用方法时顺手传进去的一段代码
* **`yield`**：方法内部执行这段 block 的方式
* **`Proc`**：被捕获后，变成对象形式的“代码值” ([The Crystal Programming Language][2])

最小例子：

```crystal
def test
  yield
end

test do
  puts "hello"
end
```

这里：

* `do ... end` 是 block
* `yield` 是执行 block
* 还**没有** `Proc`

---

## 3. `Proc` 和 block 的关系

这是最核心的一句话：

> **block 是“现场传入的代码”，`Proc` 是“被当成值保存下来的代码”。** ([The Crystal Programming Language][1])

也就是说：

* 你写 `test do ... end`，是在传 block
* 你写 `def test(&block : ...)`，是在**捕获 block**
* block 一旦被捕获，就可以当 `Proc` 用
* `Proc` 要用 `.call` 调用 ([The Crystal Programming Language][1])

例子：

```crystal
def capture(&block : Int32 -> Int32)
  block
end

p1 = capture { |x| x + 1 }
puts p1.call(10)   # => 11
```

---

# 4. 创建 `Proc` 的几种方式

## 4.1 用 `->` 直接创建

这是最直接的写法，也是最像“函数字面量”的写法。参数类型必须写，返回类型可以让 Crystal 推导，也可以手动写。([The Crystal Programming Language][3])

```crystal
double = ->(x : Int32) { x * 2 }
puts double.call(21)   # => 42
```

显式写返回类型：

```crystal
to_text = ->(x : Int32) : String { x.to_s }
puts to_text.call(5)   # => "5"
```

---

## 4.2 通过捕获 block 创建

这也是最重要的一种，因为它把 block 和 `Proc` 连起来了。
要捕获 block，需要在方法定义里写 `&block`，而且通常要写出输入输出类型。([The Crystal Programming Language][1])

```crystal
def make_proc(&block : Int32 -> Int32)
  block
end

p1 = make_proc { |x| x + 100 }
puts p1.call(1)   # => 101
```

---

## 4.3 从已有方法创建

你也可以把已经定义好的方法变成 `Proc`。
如果方法有参数，需要写参数类型。([The Crystal Programming Language][3])

```crystal
def plus_one(x)
  x + 1
end

p1 = ->plus_one(Int32)
puts p1.call(41)   # => 42
```

无参数方法：

```crystal
def hello
  "hi"
end

p1 = ->hello
puts p1.call   # => "hi"
```

---

## 4.4 用 `Proc(...).new`

官方文档也提供了这种形式，尤其在配合 `alias` 时比较有用。([The Crystal Programming Language][3])

```crystal
p1 = Proc(Int32, String).new { |x| x.to_s }
puts p1.call(7)   # => "7"
```

---

# 5. `Proc` 怎么调用

`Proc` 是对象，所以调用方式是：

```crystal
proc.call(...)
```

而且**参数个数和类型必须匹配**它的类型定义。([The Crystal Programming Language][3])

```crystal
sum = ->(x : Int32, y : Int32) { x + y }
puts sum.call(3, 4)   # => 7
```

---

# 6. `Proc` 的类型长什么样

`Proc` 的类型写法是：

```crystal
Proc(参数1类型, 参数2类型, 返回类型)
```

例如：

```crystal
Proc(Int32, String)
```

表示：

* 接收一个 `Int32`
* 返回一个 `String`

官方文档也给了简写语法，比如：

```crystal
Int32 -> String
```

和上面的意思一样。([The Crystal Programming Language][3])

例子：

```crystal
def use_it(&block : Int32 -> String)
  puts block.call(5)
end

use_it { |x| x.to_s }
```

---

# 7. `Proc` 的核心特性

## 7.1 它是“值”

这意味着它可以：

* 存进变量
* 当参数传递
* 作为返回值返回
* 存进实例变量，当回调用 ([The Crystal Programming Language][1])

最小例子：

```crystal
def build(&block : Int32 -> Int32)
  block
end

p1 = build { |x| x + 1 }
puts p1.call(3)   # => 4
```

---

## 7.2 它可以当回调

这是 `Proc` 很常见的用途。
官方文档就直接举了把捕获的 block 存成 callback 的例子。([The Crystal Programming Language][1])

```crystal
class Model
  def on_save(&block)
    @on_save_callback = block
  end

  def save
    if callback = @on_save_callback
      callback.call
    end
  end
end

m = Model.new
m.on_save { puts "saved" }
m.save
```

---

## 7.3 它可以形成闭包（closure）

这点特别重要。

`Proc` 不只是“一段代码”，它还能**记住定义时周围的变量**。
这就是闭包。Crystal 官方文档明确说，捕获到的局部变量会成为 `Proc` 的上下文数据。([The Crystal Programming Language][4])

```crystal
x = 0
counter = -> { x += 1; x }

puts counter.call   # => 1
puts counter.call   # => 2
puts x              # => 2
```

---

## 7.4 被 `Proc` 捕获的变量，类型推导会更“保守”

这是一个你现在先知道就行、以后会越来越重要的点。

如果变量只是普通 block 里改动，编译器还能较好地推断后续类型；
但如果变量被 `Proc` 捕获，编译器会认为它“以后任何时候都可能被改”，于是类型会更容易变成联合类型。([The Crystal Programming Language][4])

感受一下：

```crystal
def capture(&block)
  block
end

x = 1
capture { x = "hello" }
x = 'a'

# x 的类型会更宽一些
```

---

# 8. 捕获 block 时的返回值细节

这点很容易踩坑。

如果你写：

```crystal
def some_proc(&block : Int32 ->)
  block
end
```

这里的 `Int32 ->` 表示：

* 接收 `Int32`
* **不返回值**

所以即使 block 里面写了 `x + 1`，`proc.call` 结果也会是 `nil`。官方文档明确写了这一点。([The Crystal Programming Language][1])

例子：

```crystal
def some_proc(&block : Int32 ->)
  block
end

p1 = some_proc { |x| x + 1 }
p p1.call(1)   # => nil
```

如果你想保留返回值：

```crystal
def some_proc(&block : Int32 -> Int32)
  block
end
```

或者允许任意返回类型：

```crystal
def some_proc(&block : Int32 -> _)
  block
end
```

```crystal
def some_proc(&block : Int32 -> _)
  block
end

p1 = some_proc { |x| x.to_s }
p p1.call(1)   # => "1"
```

---

# 9. `yield` 和 `Proc.call` 的关系

你可以这么理解：

* `yield`：执行“当前方法调用附带的 block”
* `block.call`：执行“已经拿到手的 Proc 对象” ([The Crystal Programming Language][2])

例子 1：`yield`

```crystal
def twice
  yield
  yield
end

twice do
  puts "hi"
end
```

例子 2：`.call`

```crystal
p1 = -> { puts "hi" }
p1.call
p1.call
```

---

# 10. `yield` 的重要特性

## 10.1 `yield` 可以传参数给 block

```crystal
def twice
  yield 1
  yield 2
end

twice do |i|
  puts i
end
```

`yield` 很像方法调用，可以传一个或多个参数，block 用 `|...|` 接收。([The Crystal Programming Language][2])

---

## 10.2 `yield` 自己也有值

block 最后一行表达式的值，会成为这次 `yield` 的值。
这就是为什么 `map`、`select` 这种写法成立。([The Crystal Programming Language][2])

```crystal
def transform(x)
  result = yield x
  result * 10
end

puts transform(3) { |n| n + 1 }   # => 40
```

---

# 11. `do ... end` 和 `{ ... }`

这两种都可以传 block。
区别在于优先级：

* `do ... end` 绑定到最左边的方法调用
* `{ ... }` 绑定到最右边的方法调用 ([The Crystal Programming Language][2])

通常你先这么用就行：

* 多行：`do ... end`
* 一行：`{ ... }`

例子：

```crystal
[1, 2, 3].map do |x|
  x + 1
end

[1, 2, 3].map { |x| x + 1 }
```

---

# 12. `&block`、`&proc`、`&.upcase` 三个 `&` 的区别

这是最容易混的地方。

## 12.1 `def test(&block ...)`

这是**定义方法时**：

表示“把传进来的 block 捕获成一个名叫 `block` 的变量”。([The Crystal Programming Language][1])

```crystal
def test(&block : ->)
  block.call
end
```

---

## 12.2 `some_method(&proc)`

这是**调用方法时**：

表示“把一个已有的 `Proc`，当成 block 传进去”。
因为对方接收的是 block，不是普通参数。([The Crystal Programming Language][5])

```crystal
def invoke(&block)
  block.call
end

p1 = -> { puts "hello" }
invoke(&p1)
```

---

## 12.3 `array.map &.upcase`

这是**单参数 block 的语法糖**。

如果 block 只有一个参数，而且只是对这个参数调用一个方法，就可以写成 `&.方法名`。这只是语法糖，没有额外性能损失。([The Crystal Programming Language][2])

```crystal
langs = ["Java", "Go", "Crystal"]
p langs.map(&.upcase)
```

等价于：

```crystal
p langs.map { |lang| lang.upcase }
```

带参数也行：

```crystal
nums = [1, 2, 3]
p nums.map(&.+(10))   # => [11, 12, 13]
```

---

# 13. `break`、`next` 和 `Proc`

## 13.1 在普通 block 里

* `break`：提前退出外围方法
* `next`：提前结束当前这次 block 执行，不退出方法
  而且它们都可以带值。([The Crystal Programming Language][2])

`break` 例子：

```crystal
def twice
  yield 1
  yield 2
end

p twice { |i| break "stop" if i == 1; i + 1 }   # => "stop"
```

`next` 例子：

```crystal
def twice
  puts yield 1
  puts yield 2
end

twice do |i|
  next 10 if i == 1
  i + 1
end
```

---

## 13.2 在“被捕获的 block”里

这个一定要记住：

* **`return` 不能用**
* **`break` 不能用**
* **`next` 可以用** ([The Crystal Programming Language][1])

也就是说，一旦 block 被捕获成 `Proc`，它就不再是“当前方法调用现场的一部分”了，所以 `break` / `return` 那种“跳出当前方法控制流”的语义就不成立了。

---

# 14. Proc 的转发：`&proc`

如果你手里已经有一个 `Proc`，但某个方法要的是“block”，那就要写 `&proc`。
官方文档把这叫 block forwarding。([The Crystal Programming Language][5])

```crystal
def capture(&block)
  block
end

def invoke(&block)
  block.call
end

p1 = capture { puts "hello" }
invoke(&p1)
```

你不能直接写：

```crystal
invoke(p1)   # 不对
```

因为那是在传普通参数，不是在传 block。([The Crystal Programming Language][5])

---

# 15. 性能特点：什么时候该用 `yield`，什么时候该用 `Proc`

这是很实用的结论。

官方文档说明：

* **普通 `yield` block 是会被内联的**
* 不涉及 closure、函数指针之类的额外调用
* 所以性能非常好
* 如果只是“在当前方法里执行一段逻辑”，优先用 block + `yield`
* 只有在你真的需要“保存 / 返回 / 传递 / 延迟执行”时，再用 `Proc` ([The Crystal Programming Language][2])

最小对比：

### 适合 `yield`

```crystal
def twice
  yield
  yield
end

twice { puts "hi" }
```

### 适合 `Proc`

```crystal
def build_callback(&block : ->)
  block
end

cb = build_callback { puts "later" }
cb.call
```

---

# 16. 什么时候用 `Proc`

你可以这样判断：

## 用 `yield` / 普通 block 的情况

当你只是想：

* 临时把一段逻辑交给方法
* 让方法内部执行它
* 不需要把这段逻辑保存下来

```crystal
[1, 2, 3].map { |x| x + 1 }
```

---

## 用 `Proc` 的情况

当你需要：

* 把逻辑存进变量
* 把逻辑作为返回值返回
* 把逻辑存起来，等以后执行
* 做 callback / handler / strategy

```crystal
handler = ->(msg : String) { puts "recv: #{msg}" }
handler.call("hello")
```

---

# 17. 一套完整的思维链

以后你看到相关代码，就按这条链去想：

1. **调用时传 block**

```crystal
test { puts "hi" }
```

2. **方法里用 `yield` 执行**

```crystal
def test
  yield
end
```

3. **如果写 `&block`，就是在捕获**

```crystal
def test(&block : ->)
  block
end
```

4. **捕获后就变成 `Proc`**

```crystal
p1 = test { puts "hi" }
```

5. **`Proc` 用 `.call` 调**

```crystal
p1.call
```

6. **如果要把它再传给别的方法当 block，用 `&p1`**

```crystal
other_method(&p1)
```

---

# 18. 一份超短版结论

你现在可以先把 `Proc` 记成这句话：

> **`Proc` = 被对象化的代码块。**

它的核心能力是：

* 能保存
* 能传递
* 能返回
* 能调用
* 能记住外部变量（闭包） ([The Crystal Programming Language][1])

---

# 19. 最后给你一个背诵版口诀

你可以直接背这个：

**block 是现场代码，`yield` 是现场执行；
`&block` 是把 block 抓住；
抓住以后就变 `Proc`；
`Proc` 用 `.call`；
要把 `Proc` 再当 block 传出去，就写 `&proc`；
单参数调方法的 block，可以缩成 `&.方法名`。** ([The Crystal Programming Language][2])

---

你下一步最适合学的是：**“block 和 Proc 在设计方法 API 时到底怎么选”**。这一步一通，你以后看到 `map`、`each`、callback、DSL 风格代码就不容易乱了。

[1]: https://crystal-lang.org/reference/latest/syntax_and_semantics/capturing_blocks.html "Capturing blocks - Crystal"
[2]: https://crystal-lang.org/reference/latest/syntax_and_semantics/blocks_and_procs.html "Blocks and Procs - Crystal"
[3]: https://crystal-lang.org/reference/latest/syntax_and_semantics/literals/proc.html "Proc - Crystal"
[4]: https://crystal-lang.org/reference/latest/syntax_and_semantics/closures.html "Closures - Crystal"
[5]: https://crystal-lang.org/reference/latest/syntax_and_semantics/block_forwarding.html "Block forwarding - Crystal"
