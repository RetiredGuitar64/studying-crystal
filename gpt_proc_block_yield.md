
好，我们按“先翻译，再讲透”的顺序来。你这段其实正卡在 Crystal 里一个特别关键的分界线上：

**block 是“跟着方法调用走的一段代码”，Proc 是“可以被当成值来存储、传递、稍后再调用的函数对象”。**
很多语法看起来像一团，其实都是围着这条线在转。Crystal 官方文档也正是这样区分的：方法可以直接接收 block 并用 `yield` 执行；如果把 block 捕获下来，它就会变成 `Proc`；单参数 block 还能用 `&.方法名` 写成语法糖。([Crystal 程式語言][1])

---

## 一、先把你这段翻译成自然中文

虽然**有名字的方法**通常是程序的核心，但有时候你会希望逻辑能更灵活地被操作。
`Proc` 可以把一段逻辑——甚至是已有的方法——放进一个“像变量一样”的结构里，这样你就能把它在程序里传来传去，并在之后显式调用，或者通过 `yield` 触发。和方法一样，`Proc` 也可以接收参数、返回值。

这对 Ruby 程序员来说是家常便饭；但如果你不是 Ruby 背景，第一次学这个会有点绕。对非 Ruby 学习者来说，从 “Using Procs” 那一节开始会更好理解，虽然写起来会稍微啰嗦一点。

`block` 让你可以在**不专门定义正式方法**的情况下复用代码，只要你掌握了它的语法。你已经在用 block 了，只不过它还有更多写法。你可以用 `{ ... }` 或 `do ... end` 把一行或多行代码包成一个代码块。

和 Ruby 一样，这些代码块也能作为**方法调用时的参数**。比如如果有个方法叫 `testing`，你就可以这样调用它：

```crystal
testing do
  puts "in code block"
end
```

如果你定义了这个方法，那么在方法内部写 `yield`，就会执行传进来的那段 block：

```crystal
def testing
  puts "at top of method"
  yield
  puts "back inside method"
  yield
  puts "at end of method"
end
```

执行结果就是：

```text
at top of method
in code block
back inside method
in code block
at end of method
```

`yield` 很像一次方法调用，所以你也可以给它传参数。block 那边就用 `do |n| ... end` 来接：

```crystal
def testing
  puts "at top of method"
  yield 1
  puts "back inside method"
  yield 2
  puts "at end of method"
end

testing do |n|
  puts "in code block #{n}"
end
```

结果是：

```text
at top of method
in code block 1
back inside method
in code block 2
at end of method
```

在 block 里，`break` 可以让你**提前退出整个方法流程**；`next` 则只是**提前结束当前这次 block 执行**，但方法本身还会继续往后跑。

那代码块本身是不是对象？**严格说，不是。**
但如果你在定义方法时写成 `def testing(&block)`，你就把这个 block **捕获**下来了。这样传进来的代码块会变成一个 `Proc` 对象。
一旦变成 `Proc`，它就可以像普通对象一样被保存、传参、返回；但这时调用它就不能写 `yield` 了，而要写 `block.call`。

```crystal
def testing(&block)
  puts "at top of method"
  block.call
  puts "back inside method"
  block.call
  puts "at end of method"
end
```

如果 block 很短，也可以用 `{ ... }` 把逻辑写在调用旁边，更紧凑：

```crystal
langs = %w[Java Go Crystal]
langs.map { |lang| lang.upcase }  # => ["JAVA", "GO", "CRYSTAL"]
```

如果这个 block **只有一个参数**，并且只是“对这个参数调用一个方法”，Crystal 还提供了更简洁的写法：

```crystal
langs.map &.upcase
```

它和上面的 `map { |lang| lang.upcase }` 是一样的。

这个方法也可以是运算符，也可以带参数：

```crystal
nums = [42, 43, 44]
nums.map { |num| num + 2 }  # => [44, 45, 46]
nums.map &.+(2)             # => [44, 45, 46]
```

而且这种简写还可以继续链式调用。

---

## 二、先给你一个总图：把这些概念一把串起来

你先记这一条主线：

**调用方法时传进去的那段代码，叫 block。**
**方法内部用 `yield` 执行它。**
**如果方法把这段 block 抓出来放进变量 `&block`，那它就会变成一个 `Proc`。**
**Proc 是对象，所以你要用 `.call` 去调用。**
**如果你已经手里有一个 Proc，还想把它重新当 block 传给别的方法，就写 `&proc`。**
**如果 block 只有一个参数，并且只是对这个参数调方法，就可以用 `&.xxx` 简写。** ([Crystal 程式語言][1])

你可以把它想成两层：

1. **block 层**：偏“语法现场”
2. **Proc 层**：偏“对象和值”

---

## 三、先讲最核心的：`test do ... end` / `test { ... }` 到底是什么

当你写：

```crystal
testing do
  puts "hello"
end
```

意思不是“调用 `testing`，再在后面随便写一段代码”。

它真正的意思是：

**调用 `testing` 这个方法，并把后面这段代码作为一个 block 一起传进去。**
Crystal 官方文档明确说：方法可以接收 block，方法内部用 `yield` 执行它；调用时可以用 `do ... end` 或 `{ ... }` 来传 block。([Crystal 程式語言][1])

最小例子：

```crystal
def testing
  puts "before"
  yield
  puts "after"
end

testing do
  puts "inside block"
end
```

运行顺序：

```text
before
inside block
after
```

这里你先不要想“对象”。
先把它当成：

**“调用者额外塞进来的一段待执行代码”。**

---

## 四、`yield` 到底是什么

`yield` 就是：

**在方法内部，执行调用者传进来的 block。**

而且 `yield` 很像一次方法调用，所以你可以给它传参数。官方文档明确写了：`yield` 可以带参数，block 用 `|x|`、`|x, y|` 来接。([Crystal 程式語言][1])

最小例子：

```crystal
def give_number
  yield 10
end

give_number do |n|
  puts n * 2
end
```

输出：

```text
20
```

这里你可以把它理解成：

* `give_number` 里说：我现在把 `10` 交给外面的那段 block
* block 说：好，我用 `|n|` 接住它

再看一个两参数版本：

```crystal
def pair
  yield 3, 4
end

pair do |a, b|
  puts a + b
end
```

输出：

```text
7
```

---

## 五、`yield` 不只是“执行”，它自己也有返回值

这是你很容易忽略、但特别重要的一点。

`yield` 不只是把 block 跑一下；
**block 最后一行表达式的值，会成为这次 `yield` 的值。** 官方文档专门强调了这一点。([Crystal 程式語言][1])

最小例子：

```crystal
def transform(x)
  result = yield x
  result * 10
end

puts transform(3) { |n| n + 1 }
```

输出：

```text
40
```

过程是：

* `yield x` 把 `3` 交给 block
* block 算出 `3 + 1`，得到 `4`
* 所以 `result = 4`
* 最后返回 `40`

所以很多集合方法本质上就是这样工作的，比如 `map`、`select`。([Crystal 程式語言][1])

---

## 六、block 不是对象；那 `Proc` 到底是啥

这是你最想搞清楚的点。

### 1）一句人话定义

**Proc 就是“可调用对象”。**
它代表一段代码，而且这段代码可以：

* 存进变量
* 当参数传
* 当返回值返回
* 以后再调用
* 还能记住外部变量（形成 closure / 闭包） ([Crystal 程式語言][2])

官方文档对 `Proc` 的描述是：它表示一个函数指针，并且还能带着自己的上下文，也就是闭包数据。([Crystal 程式語言][3])

最小例子：

```crystal
adder = ->(x : Int32, y : Int32) { x + y }
puts adder.call(1, 2)
```

输出：

```text
3
```

这时候 `adder` 就是一个 `Proc` 对象。

---

### 2）为什么 block 和 Proc 要分开看

因为：

* **普通 block** 更像“语法上的附加代码”
* **Proc** 更像“真正的值 / 对象”

官方文档说得很清楚：
block 可以被 **captured（捕获）** 并转成 `Proc`；一旦捕获，就可以存起来、返回出去、稍后再调用。([Crystal 程式語言][2])

最小例子：

```crystal
def make_proc(&block : Int32 -> Int32)
  block
end

p1 = make_proc { |x| x + 1 }
puts p1.call(10)
```

输出：

```text
11
```

这里发生了什么？

* 调用时，你传进去的是一个 block
* 但 `make_proc` 用 `&block` 把它抓住了
* 抓住以后，它就变成了 `Proc`
* 所以返回值 `p1` 是个对象，可以 `call`

---

## 七、`&block` 到底是什么意思

你现在看到 `&block`，不要急着把所有 `&` 都混在一起。
在**方法定义里**，`&block` 的意思是：

**“把调用时传进来的 block 绑定到一个名叫 `block` 的变量上。”** ([Crystal 程式語言][1])

比如：

```crystal
def run_twice(&block)
  block.call
  block.call
end

run_twice do
  puts "hi"
end
```

输出：

```text
hi
hi
```

这里 `block` 就是那个被捕获后的 `Proc`。

---

### 一个非常容易混淆的细节

你书里的写法会让人以为：

> 只要写了 `def testing(&block)`，就一定要 `block.call`

其实更准确的理解是：

* `def testing(&block)` 只是**给 block 起了名字**
* 如果你在方法体里直接用 `yield`，也可以
* 但如果你真的把 `block` 当值用起来，比如返回它、存它、传它，或者对它调用方法，那么它就是 `Proc` 语义了 ([Crystal 程式語言][1])

简单例子：

```crystal
def demo(&block)
  yield
end

demo do
  puts "hello"
end
```

这仍然是合法思路：你声明了 `&block`，但实际执行还是靠 `yield`。

而下面这个，才是明显进入 `Proc` 世界：

```crystal
def demo(&block)
  block.call
end

demo do
  puts "hello"
end
```

---

## 八、为什么 `Proc` 要用 `.call`

因为 `Proc` 是对象。
对象的方法当然要通过方法调用来执行，所以是 `.call`。官方文档里 `Proc` 的基本调用方式就是 `proc.call(...)`。([Crystal 程式語言][3])

最小例子：

```crystal
printer = ->{ puts "hello" }
printer.call
```

输出：

```text
hello
```

再看带参数：

```crystal
square = ->(x : Int32) { x * x }
puts square.call(5)
```

输出：

```text
25
```

---

## 九、`test { ... }` 和 `test do ... end` 有什么区别

它们都能传 block。
但 Crystal 官方文档特别强调了一点：

* `do ... end` 绑定到**最左边**的方法调用
* `{ ... }` 绑定到**最右边**的方法调用 ([Crystal 程式語言][1])

这会影响优先级。

看这个例子：

```crystal
foo bar do
  puts "x"
end
```

等价于：

```crystal
foo(bar) do
  puts "x"
end
```

而这个：

```crystal
foo bar { puts "x" }
```

等价于：

```crystal
foo(bar { puts "x" })
```

所以经验上你先记：

* **多行 block，经常用 `do ... end`**
* **短小的一行 block，经常用 `{ ... }`**
* **嵌套调用时要特别小心优先级** ([Crystal 程式語言][1])

最小例子：

```crystal
[1, 2, 3].map { |x| x + 1 }
```

这个就很适合花括号。

---

## 十、`&proc` 又是什么

这个 `&` 和定义里的 `&block` 不是一回事。

在**调用位置**写 `&proc`，意思是：

**“把这个已经存在的 Proc，当作一个 block 传进去。”** 官方文档把这叫做 block forwarding 的一部分。([Crystal 程式語言][4])

最小例子：

```crystal
def capture(&block : ->)
  block
end

def twice
  yield
  yield
end

p1 = capture { puts "hello" }
twice &p1
```

输出：

```text
hello
hello
```

这里过程是：

* `capture` 把 block 变成 `Proc`
* `p1` 现在是个 Proc
* `twice` 需要的是 block，不是普通参数
* 所以你要写 `twice &p1`，把这个 Proc 重新当作 block 传进去 ([Crystal 程式語言][4])

如果你写成：

```crystal
twice(p1)
```

那就不是传 block，而是在传普通参数了，语义不对。官方文档也明确给了这种错误对比。([Crystal 程式語言][4])

---

## 十一、`&.upcase` 又是什么鬼

这是 Crystal 很好用的语法糖。

如果一个 block：

* 只有 **一个参数**
* block 体只是**对这个参数调一个方法**

那么可以缩写成 `&.方法名`。官方文档把这叫 **Short one-argument syntax**。([Crystal 程式語言][1])

例如：

```crystal
langs = ["Java", "Go", "Crystal"]

p langs.map { |lang| lang.upcase }
p langs.map &.upcase
```

这两行等价。([Crystal 程式語言][1])

---

### 还能带参数

```crystal
nums = [1, 2, 3]
p nums.map &.+(10)
```

输出：

```text
[11, 12, 13]
```

官方文档明确说：这种简写不仅能调用普通方法，也能调用运算符，还能带参数。([Crystal 程式語言][1])

---

### 你要把它脑补成什么

把：

```crystal
nums.map &.+(10)
```

脑补成：

```crystal
nums.map { |x| x.+(10) }
```

再脑补成：

```crystal
nums.map { |x| x + 10 }
```

这样你就不容易晕。

---

## 十二、Proc 还可以直接写出来，不一定要靠 block 捕获

除了从 block 捕获，官方文档还说明了两种常见创建方式：

1. 用 `->(...) { ... }` 直接写 Proc literal
2. 从已有方法创建 Proc，比如 `->method_name(Type)` ([Crystal 程式語言][3])

### 1）直接写 Proc

```crystal
double = ->(x : Int32) { x * 2 }
puts double.call(21)
```

输出：

```text
42
```

### 2）从已有方法变成 Proc

```crystal
def add_one(x)
  x + 1
end

p1 = ->add_one(Int32)
puts p1.call(41)
```

输出：

```text
42
```

这个特别适合你已经有现成方法、只是想把它当回调传来传去的时候。([Crystal 程式語言][3])

---

## 十三、和 Ruby 背景最容易混的一个点：Crystal 里“捕获 block”更正式

Crystal 是静态类型语言，所以**一旦你要把 block 捕获成 Proc，类型信息就变得更重要**。
官方文档写得很明确：如果你要捕获 block，就要在方法签名里写出 block 参数类型和返回类型；如果省略返回类型，那么这个捕获到的 Proc 会被当成不返回值（`Void`）；如果你想允许任意返回类型，可以写 `_`。([Crystal 程式語言][2])

### 例子 1：明确返回 `Int32`

```crystal
def build(&block : Int32 -> Int32)
  block
end

p1 = build { |x| x + 1 }
puts p1.call(5)
```

输出：

```text
6
```

### 例子 2：如果不写返回类型，返回值会丢掉

```crystal
def build(&block : Int32 ->)
  block
end

p1 = build { |x| x + 1 }
p p1.call(5)
```

这里你不要期待拿到 `6`；这种签名表示“这个 Proc 不关心返回值”。([Crystal 程式語言][2])

### 例子 3：允许任意返回类型

```crystal
def build(&block : Int32 -> _)
  block
end

p1 = build { |x| x.to_s }
p p1.call(5)
```

输出：

```text
"5"
```

---

## 十四、`break` 和 `next` 在 block 里怎么理解

你书里那句“`break` 退出方法，`next` 退出 block”你可以这么记：

* `next`：这次 block 到此为止
* `break`：更强，直接结束外围那层迭代 / 控制流
  而且 `next` 还可以带值，那个值会作为 `yield` 的结果返回。官方文档明确写了这一点。([Crystal 程式語言][5])

### `next` 的直觉例子

```crystal
def demo
  puts yield
  puts "after yield"
end

demo do
  next "hello"
  "world"
end
```

输出：

```text
hello
after yield
```

因为 `next "hello"` 直接结束了 block，这次 `yield` 的值就是 `"hello"`。([Crystal 程式語言][5])

---

### 但有个很重要的扩展点

**在被捕获的 block 里，`return` 和 `break` 不能用。`next` 可以。**
这是官方文档明说的，也是很多人一开始会踩的坑。([Crystal 程式語言][2])

也就是说：

```crystal
def make(&block : Int32 -> Int32)
  block
end

p1 = make do |x|
  next x + 1
end

puts p1.call(3)
```

这个思路是对的。

但如果你试图在这种被捕获的 block 里写 `break` / `return`，就会出问题。原因很直觉：它已经不是“当场执行的普通 block”了，而是一个可能以后才调用的 `Proc`。([Crystal 程式語言][2])

---

## 十五、再往前拓展一步：Proc 为什么还能“记住外部变量”

这就是 closure（闭包）。

官方文档说，`Proc` 可以带着自己的上下文；被捕获的局部变量会成为闭包数据。([Crystal 程式語言][2])

最小例子：

```crystal
x = 0
adder = ->(n : Int32) { x += n }

puts adder.call(1)
puts adder.call(10)
puts x
```

输出：

```text
1
11
11
```

这里 `adder` 不只是“一段代码”，它还记住了外面的 `x`。这就是为什么 `Proc` 特别适合做回调、延迟执行、状态累积。([Crystal 程式語言][6])

---

## 十六、你现在最该建立的“脑内分层”

你以后看到这些写法，就按这个顺序判断：

### 1）这是在“传 block”吗？

```crystal
test do
  puts "hi"
end
```

是。
最小例子：

```crystal
def test
  yield
end

test { puts "hi" }
```

### 2）这是在“用 yield 执行 block”吗？

```crystal
def test
  yield
end
```

是。
最小例子：

```crystal
def test
  yield 100
end

test { |n| puts n }
```

### 3）这是在“把 block 捕获成 Proc”吗？

```crystal
def test(&block : Int32 -> Int32)
  block
end
```

是。
最小例子：

```crystal
def test(&block : Int32 -> Int32)
  block
end

p1 = test { |x| x + 1 }
puts p1.call(5)
```

### 4）这是在“调用 Proc 对象”吗？

```crystal
p1.call(5)
```

是。
最小例子：

```crystal
p1 = ->(x : Int32) { x * 2 }
puts p1.call(5)
```

### 5）这是在“把已有 Proc 再当 block 传进去”吗？

```crystal
twice &p1
```

是。
最小例子：

```crystal
def twice
  yield
  yield
end

p1 = ->{ puts "go" }
twice &p1
```

### 6）这是在“单参数 block 语法糖”吗？

```crystal
arr.map &.upcase
```

是。
最小例子：

```crystal
p ["a", "b"].map &.upcase
```

---

## 十七、给你一个“一锅端”的总例子

把今天这些点全放进一个短程序里：

```crystal
def with_number
  result = yield 10
  puts "yield returned: #{result}"
end

def capture_it(&block : Int32 -> Int32)
  block
end

def run_twice
  yield
  yield
end

# 1) 普通 block + yield
with_number do |n|
  n + 5
end

# 2) 捕获成 Proc
p1 = capture_it do |n|
  n * 2
end

puts p1.call(3)

# 3) Proc 再转回 block
run_twice &->{ puts "hello" }

# 4) 单参数语法糖
p [1, 2, 3].map &.+(1)
```

你可以这样读它：

* `with_number`：现场执行 block，用 `yield`
* `capture_it`：把 block 抓成 `Proc`
* `p1.call`：调用 Proc
* `run_twice &...`：把 Proc 当 block 再传回去
* `map &.+(1)`：block 语法糖

---

## 十八、最后给你一个现阶段最实用的结论

你现在先不要把所有写法都当成“同一种东西”。
你只要把它们分成这两类，很多雾就散了：

### A. 当场执行的 block

关键词：`do ... end`、`{ ... }`、`yield`

```crystal
def each_twice
  yield
  yield
end

each_twice { puts "x" }
```

### B. 被当成值使用的 Proc

关键词：`&block`、`->`、`.call`、`&proc`

```crystal
p1 = ->{ puts "x" }
p1.call
```

然后再记一句桥梁：

**block 一旦被 `&block` 捕获，就进入 Proc 世界。** ([Crystal 程式語言][2])

---

## 十九、顺手补一个“你现在还不一定会主动问，但很常用”的点

Crystal 官方文档还提到：
如果一个方法“有 block 版本”和“没 block 版本”，它们可以算不同重载；而且在 block 里用到的变量、尤其是被 Proc 捕获的变量，类型推导会比你直觉里更保守。也就是说，一旦变量被 Proc 捕获，编译器往往会把它看成“未来任何时刻都可能被这段 Proc 改掉”，于是类型会变宽。([Crystal 程式語言][1])

最小感受例子：

```crystal
def capture(&block)
  block
end

x = 1
capture { x = "hello" }
x = 'a'
```

这里 `x` 的类型推导会比你想象得“混合”一些，因为它被 Proc 捕获过。这个点你以后学类型系统时会越来越重要。([Crystal 程式語言][7])

---

你这一段学完后，下一步最适合继续追的是：

**“什么时候该用 `yield`，什么时候该用 `&block` / `Proc`？”**

这会把今天这堆语法真正落到设计思路上。

[1]: https://tw.crystal-lang.org/docs/syntax_and_semantics/blocks_and_procs.html "Blocks and Procs · GitBook"
[2]: https://tw.crystal-lang.org/docs/syntax_and_semantics/capturing_blocks.html "Capturing blocks · GitBook"
[3]: https://tw.crystal-lang.org/docs/syntax_and_semantics/literals/proc.html "程序 (Proc) · GitBook"
[4]: https://tw.crystal-lang.org/docs/syntax_and_semantics/block_forwarding.html "Block forwarding · GitBook"
[5]: https://tw.crystal-lang.org/docs/syntax_and_semantics/next.html "next · GitBook"
[6]: https://tw.crystal-lang.org/docs/syntax_and_semantics/closures.html?utm_source=chatgpt.com "Closures · GitBook - tw.crystal-lang.org"
[7]: https://tw.crystal-lang.org/docs/syntax_and_semantics/closures.html "Closures · GitBook"



