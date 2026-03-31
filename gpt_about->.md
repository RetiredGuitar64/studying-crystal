
不是“接收 block 的方法的返回值”。

在 Crystal 里，`->` **主要表示 Proc（可调用对象 / 函数对象）**，你可以把它先理解成：

**“把一段代码变成一个值”**。
官方文档里，`Proc literal` 就是用 `->` 来写的；被捕获的 block，本质上也等价于一个 Proc。([Crystal 程式語言][1])

你现在看到的 `->`，常见有 3 种用法。

---

## 1）`->(...) { ... }`：直接创建一个 Proc

这是最核心的用法。

```crystal
adder = ->(x : Int32, y : Int32) { x + y }
puts adder.call(1, 2)  # => 3
```

这里的意思是：

* `->(...) { ... }`：创建一个 Proc
* `adder`：这个变量里装着那段逻辑
* `adder.call(...)`：执行这段逻辑

Crystal 官方文档就是这么定义 Proc literal 和 `.call` 的。([Crystal 程式語言][2])

---

## 2）`Type1, Type2 -> ReturnType`：这是 **Proc 的类型写法**

这个最容易误会成“箭头返回值语法”，但它其实是在写 **Proc 的类型签名**。

比如：

```crystal
def make_adder(&block : Int32 -> Int32)
  block
end
```

这里：

```crystal
Int32 -> Int32
```

意思不是“这个方法返回 Int32”。

而是：

**这个 `block` / Proc 接收一个 `Int32` 参数，并返回一个 `Int32`。**
官方文档在 capturing blocks 里就是这么写的。([Crystal 程式語言][3])

你可以把它读成：

> “从 Int32 到 Int32 的一个函数”

最小例子：

```crystal
def build(&block : Int32 -> Int32)
  block
end

p1 = build { |x| x + 1 }
puts p1.call(5)   # => 6
```

这里 `build` 返回的不是普通值，而是一个 `Proc(Int32, Int32)`。([Crystal 程式語言][3])

---

## 3）`->method_name(...)`：把已有方法变成 Proc

Crystal 官方文档还说明，`Proc` 也可以从**现有方法**创建。([Crystal 程式語言][1])

例如：

```crystal
def add_one(x)
  x + 1
end

p1 = ->add_one(Int32)
puts p1.call(10)   # => 11
```

这里的 `->add_one(Int32)` 意思是：

**把 `add_one` 这个方法，包装成一个 Proc。**

所以你以后看到 `->方法名(...)`，要想到：

不是“调用方法”，而是“拿这个方法做成一个可传递的函数对象”。([Crystal 程式語言][2])

---

# 你现在最该分清的两件事

## A. block

调用方法时顺手带进去的一段代码：

```crystal
def twice
  yield
  yield
end

twice do
  puts "hi"
end
```

这里是 block，方法内部用 `yield` 执行它。([Crystal 程式語言][4])

---

## B. Proc

能存进变量、能传来传去、能 `.call` 的对象：

```crystal
p1 = ->{ puts "hi" }
p1.call
```

这里 `->` 就是在创建 Proc。([Crystal 程式語言][2])

---

# 它和 `&block` 的关系是什么

这也是你现在最需要连起来的点：

```crystal
def capture(&block : Int32 -> Int32)
  block
end
```

这里调用时传进来的是 **block**，
但因为你写了 `&block`，它被**捕获**了，于是就变成了 **Proc**。官方文档明确说：captured block 等价于声明一个 Proc literal 再传进去。([Crystal 程式語言][1])

最小例子：

```crystal
def capture(&block : Int32 -> Int32)
  block
end

p1 = capture { |x| x * 2 }
puts p1.call(3)   # => 6
```

你可以这样理解：

* `do ... end` / `{ ... }`：先传进来的是 block
* `&block`：把它抓住
* 被抓住后：就成了 Proc
* Proc：就用 `.call`

---

# 所以 `->` 不是“方法返回值箭头”

Crystal 里普通方法返回值不是这么写的。
你现在看到的 `->`，几乎都该优先理解成：

1. **创建 Proc**
2. **描述 Proc 类型**
3. **把方法转换成 Proc** ([Crystal 程式語言][1])

---

# 给你一个对照，马上就不容易混了

## 这是 block

```crystal
[1, 2, 3].map { |x| x + 1 }
```

## 这是 Proc

```crystal
inc = ->(x : Int32) { x + 1 }
[1, 2, 3].map(&inc)
```

这两种都能表达“+1 的逻辑”，
但前者是**现场写 block**，后者是**先做成 Proc 再传**。而 `&inc` 的意思是：把这个 Proc 当 block 传进去。([Crystal 程式語言][5])

---

# 你现阶段记这一句就够了

**`->` 基本上就是“函数对象 / Proc”的标志。**
看到它，优先想：

* “是不是在创建一个 Proc？”
* “是不是在写一个 Proc 的类型？”
* “是不是把一个现有方法变成 Proc？”

而不是想“是不是返回值箭头”。

最小总结例子：

```crystal
# 1) 创建 Proc
p1 = ->(x : Int32) { x + 1 }

# 2) 调用 Proc
puts p1.call(5)

# 3) Proc 类型
def build(&block : Int32 -> Int32)
  block
end

# 4) 方法转 Proc
def add_one(x)
  x + 1
end

p2 = ->add_one(Int32)
puts p2.call(5)
```

你要的话，我下一条可以专门给你画一个：

**`block -> &block -> Proc -> .call -> &proc`**

的流程图式讲解，把这几个符号一次性彻底串起来。

[1]: https://tw.crystal-lang.org/docs/syntax_and_semantics/proc_literal.html?utm_source=chatgpt.com "Proc literal · GitBook - tw.crystal-lang.org"
[2]: https://tw.crystal-lang.org/docs/syntax_and_semantics/literals/proc.html?utm_source=chatgpt.com "程序 (Proc) · GitBook"
[3]: https://tw.crystal-lang.org/docs/syntax_and_semantics/capturing_blocks.html?utm_source=chatgpt.com "Capturing blocks · GitBook - Crystal 程式語言"
[4]: https://tw.crystal-lang.org/docs/syntax_and_semantics/blocks_and_procs.html?utm_source=chatgpt.com "Blocks and Procs · GitBook - Crystal 程式語言"
[5]: https://tw.crystal-lang.org/docs/syntax_and_semantics/block_forwarding.html?utm_source=chatgpt.com "Block forwarding · GitBook - tw.crystal-lang.org"
