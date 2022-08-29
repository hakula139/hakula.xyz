---
title: CS:APP - Bomb Lab
date: 2019-10-23T01:27:00+08:00

tags: [CS:APP, 汇编]
categories: [note]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/csapp.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

Introduction to Computer Systems I (H) @ Fudan University, fall 2019.

<!--more-->

## 实验简介

{{< admonition info 参见 >}}
[CS:APP3e, Bryant and O'Hallaron - CMU](http://csapp.cs.cmu.edu/3e/labs.html)
{{< /admonition >}}

浏览 `bomb.c` 文件可知，Bomb Lab 总共有 6 个关卡，每个关卡的流程如下所示（以 Phase 1 为例）：

```c
/* Hmm...  Six phases must be more secure than one phase! */
input = read_line();             /* Get input                    */
phase_1(input);                  /* Run the phase                */
phase_defused();                 /* Drat! They figured it out!
                                  * Let me know how they did it. */
printf("Phase 1 defused. How about the next one?\n");
```

1. 读入一行字符串 `input` 作为本关密码；
2. 通过函数 `phase_1` 检验密码正确性；
3. 如果密码正确，则通过本关，并输出一行提示文本（否则炸弹爆炸）。

除此以外无其他提示信息。我们的目标即通过所有关卡，解除炸弹。

## 实验报告

### 准备工作

使用 objdump[^objdump] 反汇编 `bomb` 程序，并将输出重定向到 `bomb.asm`。之后此文件将作为解题的重要参考。

```bash
objdump -d bomb > bomb.asm
```

使用 gdb[^gdb] 调试 `bomb`，游戏开始。

```bash
gdb bomb
```

[^objdump]: [objdump 二进制文件分析 - Linux Tools Quick Tutorial](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/objdump.html)
[^gdb]: [用 GDB 调试程序 - Ubuntu 中文](https://wiki.ubuntu.org.cn/%E7%94%A8GDB%E8%B0%83%E8%AF%95%E7%A8%8B%E5%BA%8F)

### Phase 1: string comparison

#### 1.1 本关密码

`Border relations with Canada have never been better.`

#### 1.2 解题过程

##### 1.2.1 观察函数 `main`

在 `bomb.asm` 中找到函数 `main` 对应的汇编语句，注意到其中片段：

```text
  400e32:   e8 67 06 00 00          callq  40149e <read_line>
  400e37:   48 89 c7                mov    %rax,%rdi
  400e3a:   e8 a1 00 00 00          callq  400ee0 <phase_1>
  400e3f:   e8 80 07 00 00          callq  4015c4 <phase_defused>
  400e44:   bf a8 23 40 00          mov    $0x4023a8,%edi
  400e49:   e8 c2 fc ff ff          callq  400b10 <puts@plt>
```

可见这就是 Phase 1 的部分。

`400e37`: `mov %rax,%rdi` 将函数 `read_line` 的返回值（即 `input`）传给了 `%rdi` 寄存器。

{{< admonition note 寄存器状态 >}}
`%rdi` = `input`
{{< /admonition >}}

##### 1.2.2 观察函数 `phase_1`

在 `bomb.asm` 中找到函数 `phase_1` 对应的汇编语句：

```text
0000000000400ee0 <phase_1>:
  400ee0:   48 83 ec 08             sub    $0x8,%rsp
  400ee4:   be 00 24 40 00          mov    $0x402400,%esi
  400ee9:   e8 4a 04 00 00          callq  401338 <strings_not_equal>
  400eee:   85 c0                   test   %eax,%eax
  400ef0:   74 05                   je     400ef7 <phase_1+0x17>
  400ef2:   e8 43 05 00 00          callq  40143a <explode_bomb>
  400ef7:   48 83 c4 08             add    $0x8,%rsp
  400efb:   c3                      retq
```

`400ef2`: `callq 40143a <explode_bomb>` 调用函数 `explode_bomb`。从函数名推测这可能就是引爆炸弹的函数，谨慎起见先在函数 `explode_bomb` 的入口处设置一个断点。

```text
(gdb) b explode_bomb
```

`400ee4`: `mov $0x402400,%esi` 将地址 `0x402400` 传给了 `%esi` 寄存器。

{{< admonition note 寄存器状态 >}}
`%esi` = `0x402400`
{{< /admonition >}}

`400ee9`: `callq 401338 <strings_not_equal>` 调用函数 `strings_not_equal`。从函数名推测其作用可能为检查两个字符串是否（不）相等。

`400eee`: `test %eax,%eax` 和 `400ef0`: `je 400ef7 <phase_1+0x17>` 判断返回值是否为 `0`，是则直接跳到 `400ef7`: `add $0x8,%rsp` 弹栈返回，否则执行 `400ef2`: `callq 40143a <explode_bomb>` 引爆炸弹。

其实到这里基本已经可以猜到答案了。但严谨起见，接下来将完整分析各个函数的具体作用与实现，以验证我们的推测是否正确。如果觉得这些分析没有必要，可以直接跳到 [1.2.6](#126-回到函数-phase_1) 节。

##### 1.2.3 观察函数 `strings_not_equal`

在 `bomb.asm` 中找到函数 `strings_not_equal` 对应的汇编语句：

```text
0000000000401338 <strings_not_equal>:
  401338:   41 54                   push   %r12
  40133a:   55                      push   %rbp
  40133b:   53                      push   %rbx
  40133c:   48 89 fb                mov    %rdi,%rbx
  40133f:   48 89 f5                mov    %rsi,%rbp
  401342:   e8 d4 ff ff ff          callq  40131b <string_length>
  401347:   41 89 c4                mov    %eax,%r12d
  40134a:   48 89 ef                mov    %rbp,%rdi
  40134d:   e8 c9 ff ff ff          callq  40131b <string_length>
  401352:   ba 01 00 00 00          mov    $0x1,%edx
  401357:   41 39 c4                cmp    %eax,%r12d
  40135a:   75 3f                   jne    40139b <strings_not_equal+0x63>
  40135c:   0f b6 03                movzbl (%rbx),%eax
  40135f:   84 c0                   test   %al,%al
  401361:   74 25                   je     401388 <strings_not_equal+0x50>
  401363:   3a 45 00                cmp    0x0(%rbp),%al
  401366:   74 0a                   je     401372 <strings_not_equal+0x3a>
  401368:   eb 25                   jmp    40138f <strings_not_equal+0x57>
  40136a:   3a 45 00                cmp    0x0(%rbp),%al
  40136d:   0f 1f 00                nopl   (%rax)
  401370:   75 24                   jne    401396 <strings_not_equal+0x5e>
  401372:   48 83 c3 01             add    $0x1,%rbx
  401376:   48 83 c5 01             add    $0x1,%rbp
  40137a:   0f b6 03                movzbl (%rbx),%eax
  40137d:   84 c0                   test   %al,%al
  40137f:   75 e9                   jne    40136a <strings_not_equal+0x32>
  401381:   ba 00 00 00 00          mov    $0x0,%edx
  401386:   eb 13                   jmp    40139b <strings_not_equal+0x63>
  401388:   ba 00 00 00 00          mov    $0x0,%edx
  40138d:   eb 0c                   jmp    40139b <strings_not_equal+0x63>
  40138f:   ba 01 00 00 00          mov    $0x1,%edx
  401394:   eb 05                   jmp    40139b <strings_not_equal+0x63>
  401396:   ba 01 00 00 00          mov    $0x1,%edx
  40139b:   89 d0                   mov    %edx,%eax
  40139d:   5b                      pop    %rbx
  40139e:   5d                      pop    %rbp
  40139f:   41 5c                   pop    %r12
  4013a1:   c3                      retq
```

`40133c`: `mov %rdi,%rbx` 和 `40133f`: `mov %rsi,%rbp` 将 `%rdi` 和 `%rsi` 寄存器保存的地址分别传给了 `%rbx` 和 `%rbp` 寄存器。

{{< admonition note 寄存器状态 >}}
`%rbx` = `%rdi` = `input`  
`%rbp` = `%rsi` = `0x402400`
{{< /admonition >}}

`401342`: `callq 40131b <string_length>` 调用函数 `string_length`。从函数名推测其作用可能为求字符串的长度。

##### 1.2.4 观察函数 `string_length`

```text
000000000040131b <string_length>:
  40131b:   80 3f 00                cmpb   $0x0,(%rdi)
  40131e:   74 12                   je     401332 <string_length+0x17>
  401320:   48 89 fa                mov    %rdi,%rdx
  401323:   48 83 c2 01             add    $0x1,%rdx
  401327:   89 d0                   mov    %edx,%eax
  401329:   29 f8                   sub    %edi,%eax
  40132b:   80 3a 00                cmpb   $0x0,(%rdx)
  40132e:   75 f3                   jne    401323 <string_length+0x8>
  401330:   f3 c3                   repz retq
  401332:   b8 00 00 00 00          mov    $0x0,%eax
  401337:   c3                      retq
```

`40131b`: `cmpb $0x0,(%rdi)` 和 `40131e`: `je 401332 <string_length+0x17>` 判断 `%rdi` 寄存器指向的内容是否为 `'\0'`（字符串结束符），是则直接跳到 `401332`: `mov $0x0,%eax` 将 `%eax` 寄存器（即函数返回值）设置为 `0` 后返回，否则继续执行之后的语句。

```text
  401320:   48 89 fa                mov    %rdi,%rdx
  401323:   48 83 c2 01             add    $0x1,%rdx
  401327:   89 d0                   mov    %edx,%eax
  401329:   29 f8                   sub    %edi,%eax
  40132b:   80 3a 00                cmpb   $0x0,(%rdx)
  40132e:   75 f3                   jne    401323 <string_length+0x8>
  401330:   f3 c3                   repz retq
```

容易发现这是一个循环结构，试译成 C 语言代码：

```c
index = start_pos;                  // index in %rdx, start_pos in %rdi
do {
    ++index;
    result = index;                 // result in %eax
    result -= start_pos;
} while (*index != '\0');
return result;
```

可见，函数 `string_length` 的作用为求 `%rdi` 寄存器指向的字符串的长度。

##### 1.2.5 回到函数 `strings_not_equal`

```text
  40133c:   48 89 fb                mov    %rdi,%rbx
  40133f:   48 89 f5                mov    %rsi,%rbp
  401342:   e8 d4 ff ff ff          callq  40131b <string_length>
  401347:   41 89 c4                mov    %eax,%r12d
```

由上一节的分析，我们知道 `401342`: `callq 40131b <string_length>` 的返回值就是字符串 `input` 的长度。`401347`: `mov %eax,%r12d` 将该返回值传给了 `%r12d` 寄存器。

{{< admonition note 寄存器状态 >}}
`%r12d` = `%eax` = `strlen(input)`
{{< /admonition >}}

```text
  40134a:   48 89 ef                mov    %rbp,%rdi
  40134d:   e8 c9 ff ff ff          callq  40131b <string_length>
```

`40134a`: `mov %rbp,%rdi` 将 `%rbp` 寄存器保存的地址（`0x402400`）传给了 `%rdi` 寄存器。

{{< admonition note 寄存器状态 >}}
`%rdi` = `%rbp` = `0x402400`
{{< /admonition >}}

于是我们知道，`0x402400` 这个地址指向的是一个字符串，而 `40134d`: `callq 40131b <string_length>` 返回的就是这个字符串的长度。

{{< admonition note 寄存器状态 >}}
`%eax` = `strlen(0x402400)`
{{< /admonition >}}

```text
  401352:   ba 01 00 00 00          mov    $0x1,%edx
  401357:   41 39 c4                cmp    %eax,%r12d
  40135a:   75 3f                   jne    40139b <strings_not_equal+0x63>
  ...
  40139b:   89 d0                   mov    %edx,%eax
  40139d:   5b                      pop    %rbx
  40139e:   5d                      pop    %rbp
  40139f:   41 5c                   pop    %r12
  4013a1:   c3                      retq
```

`401352`: `mov $0x1,%edx` 将 `%edx` 寄存器赋值为 `1`。

`401357`: `cmp %eax,%r12d` 和 `40135a`: `jne 40139b <strings_not_equal+0x63>` 比较 `%r12d` 和 `%eax` 寄存器的值是否相等（也就是比较两个字符串的长度是否相等），是则继续执行之后的语句，否则直接跳到 `40139b`: `mov %edx,%eax` 将 `%eax` 寄存器（即函数返回值）设置为 `1` 后返回。

从这里可以看出，函数 `strings_not_equal` 在两个字符串不相等时将返回 `1`。

```text
  40135c:   0f b6 03                movzbl (%rbx),%eax
  40135f:   84 c0                   test   %al,%al
  401361:   74 25                   je     401388 <strings_not_equal+0x50>
  ...
  401388:   ba 00 00 00 00          mov    $0x0,%edx
  40138d:   eb 0c                   jmp    40139b <strings_not_equal+0x63>
  ...
  40139b:   89 d0                   mov    %edx,%eax
  40139d:   5b                      pop    %rbx
  40139e:   5d                      pop    %rbp
  40139f:   41 5c                   pop    %r12
  4013a1:   c3                      retq
```

`40135c`: `movzbl (%rbx),%eax` 将 `%rbx` 寄存器指向的内容（字符串 `input` 的第一个字符）传递给 `%eax` 寄存器（做零扩展）。

{{< admonition note 寄存器状态 >}}
`%eax` = `*input`
{{< /admonition >}}

`40135f`: `test %al,%al` 和 `401361`: `je 401388 <strings_not_equal+0x50>` 判断 `%al` 寄存器保存的内容（字符串 `input` 的第一个字符）是否为 `'\0'`（字符串结束符），是则直接跳到 `401388`: `mov $0x0,%edx` 将 `%edx` 寄存器赋值为 `0`（从之后的语句可以看出函数将返回，返回值为 `0`），否则继续执行之后的语句。

```text
  401363:   3a 45 00                cmp    0x0(%rbp),%al
  401366:   74 0a                   je     401372 <strings_not_equal+0x3a>
  401368:   eb 25                   jmp    40138f <strings_not_equal+0x57>
  ...
  401372:   48 83 c3 01             add    $0x1,%rbx
  ...
  40138f:   ba 01 00 00 00          mov    $0x1,%edx
  401394:   eb 05                   jmp    40139b <strings_not_equal+0x63>
  ...
  40139b:   89 d0                   mov    %edx,%eax
  40139d:   5b                      pop    %rbx
  40139e:   5d                      pop    %rbp
  40139f:   41 5c                   pop    %r12
  4013a1:   c3                      retq
```

`401363`: `cmp 0x0(%rbp),%al`, `401366`: `je 401372 <strings_not_equal+0x3a>` 和 `401368`: `jmp 40138f <strings_not_equal+0x57>` 比较 `%rbp` 寄存器指向的内容（`0x402400` 指向的字符串的第一个字符）和 `%al` 寄存器保存的内容（字符串 `input` 的第一个字符）是否相等，是则跳到 `401372`: `add $0x1,%rbx`，否则跳到 `40138f`: `mov $0x1,%edx` 将 `%edx` 寄存器赋值为 `1`（从之后的语句可以看出函数将返回，返回值为 `1`）。

```text
  40136a:   3a 45 00                cmp    0x0(%rbp),%al
  40136d:   0f 1f 00                nopl   (%rax)
  401370:   75 24                   jne    401396 <strings_not_equal+0x5e>
  401372:   48 83 c3 01             add    $0x1,%rbx
  401376:   48 83 c5 01             add    $0x1,%rbp
  40137a:   0f b6 03                movzbl (%rbx),%eax
  40137d:   84 c0                   test   %al,%al
  40137f:   75 e9                   jne    40136a <strings_not_equal+0x32>
  401381:   ba 00 00 00 00          mov    $0x0,%edx
  401386:   eb 13                   jmp    40139b <strings_not_equal+0x63>
  ...
  401396:   ba 01 00 00 00          mov    $0x1,%edx
  40139b:   89 d0                   mov    %edx,%eax
  40139d:   5b                      pop    %rbx
  40139e:   5d                      pop    %rbp
  40139f:   41 5c                   pop    %r12
  4013a1:   c3                      retq
```

容易发现这是一个循环结构，试译成 C 语言代码：

```c
do {
    if (*password != cur_char)      // password in %rbp, cur_char in %al
        return 1;
    ++input;                        // input in %rbx
    ++password;
    cur_char = *input;
} while (cur_char != '\0');
return 0;
```

可见，函数 `strings_not_equal` 的作用为检查 `%rdi` 和 `%rsi` 寄存器指向的字符串是否相等，是则返回 `0`，否则返回 `1`。

##### 1.2.6 回到函数 `phase_1`

```text
0000000000400ee0 <phase_1>:
  400ee0:   48 83 ec 08             sub    $0x8,%rsp
  400ee4:   be 00 24 40 00          mov    $0x402400,%esi
  400ee9:   e8 4a 04 00 00          callq  401338 <strings_not_equal>
  400eee:   85 c0                   test   %eax,%eax
  400ef0:   74 05                   je     400ef7 <phase_1+0x17>
  400ef2:   e8 43 05 00 00          callq  40143a <explode_bomb>
  400ef7:   48 83 c4 08             add    $0x8,%rsp
  400efb:   c3                      retq
```

由之前的分析，我们确定了函数 `strings_not_equal` 的具体作用。此时寄存器内保存的信息为：

{{< admonition note 寄存器状态 >}}
`%rdi` = `input`  
`%esi` = `0x402400`
{{< /admonition >}}

可见，函数 `phase_1` 的作用为检查输入的字符串和 `0x402400` 指向的字符串是否相等，是则直接返回，否则引爆炸弹。

##### 1.2.7 使用 gdb 查看内容

因此 Phase 1 的密码就是 `0x402400` 指向的字符串。使用 gdb 查看该地址存放的内容：

```text
(gdb) x/s 0x402400
```

输出信息：

```text
0x402400:       "Border relations with Canada have never been better."
```

##### 1.2.8 测试

在 gdb 中输入 Phase 1 的密码：

```text
Border relations with Canada have never been better.
```

输出信息：

```text
Phase 1 defused. How about the next one?
```

### Phase 2: loops

#### 2.1 本关密码

`1 2 4 8 16 32`

#### 2.2 解题过程

{{< admonition note 寄存器状态 >}}
`%rdi` = `input`
{{< /admonition >}}

##### 2.2.1 观察函数 `phase_2`

在 `bomb.asm` 中找到函数 `phase_2` 对应的汇编语句：

```text
0000000000400efc <phase_2>:
  400efc:   55                      push   %rbp
  400efd:   53                      push   %rbx
  400efe:   48 83 ec 28             sub    $0x28,%rsp
  400f02:   48 89 e6                mov    %rsp,%rsi
  400f05:   e8 52 05 00 00          callq  40145c <read_six_numbers>
  400f0a:   83 3c 24 01             cmpl   $0x1,(%rsp)
  400f0e:   74 20                   je     400f30 <phase_2+0x34>
  400f10:   e8 25 05 00 00          callq  40143a <explode_bomb>
  400f15:   eb 19                   jmp    400f30 <phase_2+0x34>
  400f17:   8b 43 fc                mov    -0x4(%rbx),%eax
  400f1a:   01 c0                   add    %eax,%eax
  400f1c:   39 03                   cmp    %eax,(%rbx)
  400f1e:   74 05                   je     400f25 <phase_2+0x29>
  400f20:   e8 15 05 00 00          callq  40143a <explode_bomb>
  400f25:   48 83 c3 04             add    $0x4,%rbx
  400f29:   48 39 eb                cmp    %rbp,%rbx
  400f2c:   75 e9                   jne    400f17 <phase_2+0x1b>
  400f2e:   eb 0c                   jmp    400f3c <phase_2+0x40>
  400f30:   48 8d 5c 24 04          lea    0x4(%rsp),%rbx
  400f35:   48 8d 6c 24 18          lea    0x18(%rsp),%rbp
  400f3a:   eb db                   jmp    400f17 <phase_2+0x1b>
  400f3c:   48 83 c4 28             add    $0x28,%rsp
  400f40:   5b                      pop    %rbx
  400f41:   5d                      pop    %rbp
  400f42:   c3                      retq
```

`400efe`: `sub $0x28,%rsp` 和 `400f02`: `mov %rsp,%rsi` 分配了一块 40 bytes 大小的空间，并将其地址传给了 `%rsi` 寄存器。

{{< admonition note 寄存器状态 >}}
`%rsi` = `%rsp`
{{< /admonition >}}

`400f05`: `callq 40145c <read_six_numbers>` 调用函数 `read_six_numbers`。从函数名推测其作用可能是读入 6 个数。

类似地，接下来我们将完整分析该函数的具体作用与实现，以验证我们的推测是否正确。如果觉得这些分析没有必要，可以直接跳到 [2.2.3](#223-回到函数-phase_2) 节。

##### 2.2.2 观察函数 `read_six_numbers`

在 `bomb.asm` 中找到函数 `read_six_numbers` 对应的汇编语句：

```text
000000000040145c <read_six_numbers>:
  40145c:   48 83 ec 18             sub    $0x18,%rsp
  401460:   48 89 f2                mov    %rsi,%rdx
  401463:   48 8d 4e 04             lea    0x4(%rsi),%rcx
  401467:   48 8d 46 14             lea    0x14(%rsi),%rax
  40146b:   48 89 44 24 08          mov    %rax,0x8(%rsp)
  401470:   48 8d 46 10             lea    0x10(%rsi),%rax
  401474:   48 89 04 24             mov    %rax,(%rsp)
  401478:   4c 8d 4e 0c             lea    0xc(%rsi),%r9
  40147c:   4c 8d 46 08             lea    0x8(%rsi),%r8
  401480:   be c3 25 40 00          mov    $0x4025c3,%esi
  401485:   b8 00 00 00 00          mov    $0x0,%eax
  40148a:   e8 61 f7 ff ff          callq  400bf0 <__isoc99_sscanf@plt>
  40148f:   83 f8 05                cmp    $0x5,%eax
  401492:   7f 05                   jg     401499 <read_six_numbers+0x3d>
  401494:   e8 a1 ff ff ff          callq  40143a <explode_bomb>
  401499:   48 83 c4 18             add    $0x18,%rsp
  40149d:   c3                      retq
```

先看开始的部分（`40145c` ~ `40147c`）：

```text
  40145c:   48 83 ec 18             sub    $0x18,%rsp
  401460:   48 89 f2                mov    %rsi,%rdx
  401463:   48 8d 4e 04             lea    0x4(%rsi),%rcx
  401467:   48 8d 46 14             lea    0x14(%rsi),%rax
  40146b:   48 89 44 24 08          mov    %rax,0x8(%rsp)
  401470:   48 8d 46 10             lea    0x10(%rsi),%rax
  401474:   48 89 04 24             mov    %rax,(%rsp)
  401478:   4c 8d 4e 0c             lea    0xc(%rsi),%r9
  40147c:   4c 8d 46 08             lea    0x8(%rsi),%r8
```

直观起见，试译成 C 语言代码[^size-of-ptr]：

```c
int* pos[3];                        // pos in %rsp, 0x18 bytes = 3 * sizeof(int*)
num0_pos = start_pos;               // num0_pos in %rdx, start_pos in %rsi
num1_pos = start_pos + 1;           // num1_pos in %rcx, 0x4 bytes = 1 * sizeof(int)
tmp_pos  = start_pos + 5;           // tmp_pos in %rax
pos[1]   = tmp_pos;
tmp_pos  = start_pos + 4;
pos[0]   = tmp_pos;
num3_pos = start_pos + 3;           // num3_pos in %r9
num2_pos = start_pos + 2;           // num2_pos in %r8
```

于是得到各地址保存的位置：

{{< admonition note 寄存器状态 >}}
`%rdx` = `%rsi`  
`%rcx` = `%rsi + 4`  
`%r8` = `%rsi + 8`  
`%r9` = `%rsi + 12`  
{{< /admonition >}}

{{< admonition note 栈状态 >}}
`0x0(%rsp)` = `%rsi + 16`  
`0x8(%rsp)` = `%rsi + 20`
{{< /admonition >}}

由上一节知，`%rsi` 寄存器存放的是调用者 `%rsp` 寄存器中的内容，因此这 6 个地址分别对应调用者栈里开始的 6 个连续 int 的地址。

再看中间的部分（`401480` ~ `40148a`）：

```text
  401480:   be c3 25 40 00          mov    $0x4025c3,%esi
  401485:   b8 00 00 00 00          mov    $0x0,%eax
  40148a:   e8 61 f7 ff ff          callq  400bf0 <__isoc99_sscanf@plt>
```

又出现了一个诡异的地址 `0x4025c3`，经测试发现其指向的是一个字符串。使用 gdb 查看该地址存放的内容：

```text
(gdb) x/s 0x4025c3
```

输出信息：

```text
0x4025c3:       "%d %d %d %d %d %d"
```

这是一个 C 语言中的格式化字符串。结合之后 `40148a`: `callq 400bf0 <__isoc99_sscanf@plt>` 调用的系统函数 `sscanf`，推测这部分的作用是对输入的字符串以这个格式进行解析，读取 6 个整数，并保存在之前 6 个参数所提供的 6 个地址中（函数 `sscanf` 总共传入了 8 个参数）。

因此，本关密码如果需要读入 6 个整数，就应当以这个格式进行输入（相邻整数间有且仅有一个空格）。

由于 `sscanf` 是系统函数，通过 `bomb.asm` 的汇编语句无法得知其具体作用与实现，这里我们只能止步于以上推测。

最后看结尾的部分（`40148f` ~ `40149d`）：

```text
  40148f:   83 f8 05                cmp    $0x5,%eax
  401492:   7f 05                   jg     401499 <read_six_numbers+0x3d>
  401494:   e8 a1 ff ff ff          callq  40143a <explode_bomb>
  401499:   48 83 c4 18             add    $0x18,%rsp
  40149d:   c3                      retq
```

`40148f`: `cmp $0x5,%eax` 和 `401492`: `jg 401499 <read_six_numbers+0x3d>` 判断函数 `sscanf` 的返回值是否大于 `5`，是则直接跳到 `401499`: `add $0x18,%rsp` 弹栈返回，否则执行 `40143a`: `callq 40143a <explode_bomb>` 引爆炸弹。

由于系统函数 `sscanf` 的返回值为其成功解析并读取（converted and assigned）的次数[^sscanf]，这部分的作用即检查是否成功读入了超过 5 个整数，如果不成功则直接引爆炸弹。

[^size-of-ptr]: 实际上，`int*` 的大小是 4 / 8 bytes 取决于环境。使用 gdb 查看 `sizeof(int*)` 在当前环境下的值，输出为 `8`，可知在当前环境下 `int*` 的大小确实为 8 bytes。当然如果是 4 bytes 题目也就出问题了。
[^sscanf]: [sscanf() - Read Data - IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_72/rtref/sscanf.htm)

##### 2.2.3 回到函数 `phase_2`

由之前的分析，我们确定了函数 `read_six_numbers` 的具体作用。此时栈内保存的信息为：

{{< admonition note 栈状态 >}}
`0x0(%rsp)` = `nums[0]`  
`0x4(%rsp)` = `nums[1]`  
`0x8(%rsp)` = `nums[2]`  
`0xc(%rsp)` = `nums[3]`  
`0x10(%rsp)` = `nums[4]`  
`0x14(%rsp)` = `nums[5]`
{{< /admonition >}}

其中，`nums[0]` ... `nums[5]` 表示输入的字符串中解析得到的（前）6 个整数。

```text
  400f0a:   83 3c 24 01             cmpl   $0x1,(%rsp)
  400f0e:   74 20                   je     400f30 <phase_2+0x34>
  400f10:   e8 25 05 00 00          callq  40143a <explode_bomb>
  400f15:   eb 19                   jmp    400f30 <phase_2+0x34>
  400f17:   8b 43 fc                mov    -0x4(%rbx),%eax
  400f1a:   01 c0                   add    %eax,%eax
  400f1c:   39 03                   cmp    %eax,(%rbx)
  400f1e:   74 05                   je     400f25 <phase_2+0x29>
  400f20:   e8 15 05 00 00          callq  40143a <explode_bomb>
  400f25:   48 83 c3 04             add    $0x4,%rbx
  400f29:   48 39 eb                cmp    %rbp,%rbx
  400f2c:   75 e9                   jne    400f17 <phase_2+0x1b>
  400f2e:   eb 0c                   jmp    400f3c <phase_2+0x40>
  400f30:   48 8d 5c 24 04          lea    0x4(%rsp),%rbx
  400f35:   48 8d 6c 24 18          lea    0x18(%rsp),%rbp
  400f3a:   eb db                   jmp    400f17 <phase_2+0x1b>
  400f3c:   48 83 c4 28             add    $0x28,%rsp
  400f40:   5b                      pop    %rbx
  400f41:   5d                      pop    %rbp
  400f42:   c3                      retq
```

这段的结构比较复杂。我们先直译成含 `goto` 语句的 C 语言代码：

```c
    if (nums[0] == 1)               // nums in %rsp
        goto L_400f30;
    explode_bomb();
    goto L_400f30;
L_400f17:                           // 0x400f17
    target = *(cur_pos - 1);        // target in %eax, cur_pos in %rbx
                                    // 0x4 bytes = 1 * sizeof(int)
    target *= 2;
    if (*cur_pos == target)
        goto L_400f25;
    explode_bomb();
L_400f25:                           // 0x400f25
    cur_pos += 1;
    if (cur_pos != end_pos)         // end_pos in %rbp
        goto L_400f17;
    goto L_400f3c;
L_400f30:                           // 0x400f30
    cur_pos = nums + 1;
    end_pos = nums + 6;
    goto L_400f17;
L_400f3c:                           // 0x400f3c
    return target;
```

整理后得到：

```c
if (nums[0] != 1)
    explode_bomb();
end_pos = nums + 6;
for (cur_pos = nums + 1; cur_pos != end_pos; ++cur_pos) {
    target = *(cur_pos - 1) * 2;
    if (*cur_pos != target)
        explode_bomb();
}
return target;
```

通过这段代码，需要输入的 6 个整数就很显然了——第 1 个整数应当为 `1`，之后的每个整数都是前一个数的 2 倍。于是需要输入的 6 个整数依次为 `1`, `2`, `4`, `8`, `16`, `32`。

由之前的分析，本关密码即为 `1 2 4 8 16 32`。

##### 2.2.4 测试

在 gdb 中输入 Phase 2 的密码：

```text
1 2 4 8 16 32
```

输出信息：

```text
That's number 2.  Keep going!
```

### Phase 3: conditionals / switches

#### 3.1 本关密码

`0 207`, `1 311`, `2 707`, `3 256`, `4 389`, `5 206`, `6 682`, `7 327`

#### 3.2 解题过程

{{< admonition note 寄存器状态 >}}
`%rdi` = `input`
{{< /admonition >}}

##### 3.2.1 观察函数 `phase_3`

在 `bomb.asm` 中找到函数 `phase_3` 对应的汇编语句：

```text
0000000000400f43 <phase_3>:
  400f43:   48 83 ec 18             sub    $0x18,%rsp
  400f47:   48 8d 4c 24 0c          lea    0xc(%rsp),%rcx
  400f4c:   48 8d 54 24 08          lea    0x8(%rsp),%rdx
  400f51:   be cf 25 40 00          mov    $0x4025cf,%esi
  400f56:   b8 00 00 00 00          mov    $0x0,%eax
  400f5b:   e8 90 fc ff ff          callq  400bf0 <__isoc99_sscanf@plt>
  400f60:   83 f8 01                cmp    $0x1,%eax
  400f63:   7f 05                   jg     400f6a <phase_3+0x27>
  400f65:   e8 d0 04 00 00          callq  40143a <explode_bomb>
  400f6a:   83 7c 24 08 07          cmpl   $0x7,0x8(%rsp)
  400f6f:   77 3c                   ja     400fad <phase_3+0x6a>
  400f71:   8b 44 24 08             mov    0x8(%rsp),%eax
  400f75:   ff 24 c5 70 24 40 00    jmpq   *0x402470(,%rax,8)
  400f7c:   b8 cf 00 00 00          mov    $0xcf,%eax
  400f81:   eb 3b                   jmp    400fbe <phase_3+0x7b>
  400f83:   b8 c3 02 00 00          mov    $0x2c3,%eax
  400f88:   eb 34                   jmp    400fbe <phase_3+0x7b>
  400f8a:   b8 00 01 00 00          mov    $0x100,%eax
  400f8f:   eb 2d                   jmp    400fbe <phase_3+0x7b>
  400f91:   b8 85 01 00 00          mov    $0x185,%eax
  400f96:   eb 26                   jmp    400fbe <phase_3+0x7b>
  400f98:   b8 ce 00 00 00          mov    $0xce,%eax
  400f9d:   eb 1f                   jmp    400fbe <phase_3+0x7b>
  400f9f:   b8 aa 02 00 00          mov    $0x2aa,%eax
  400fa4:   eb 18                   jmp    400fbe <phase_3+0x7b>
  400fa6:   b8 47 01 00 00          mov    $0x147,%eax
  400fab:   eb 11                   jmp    400fbe <phase_3+0x7b>
  400fad:   e8 88 04 00 00          callq  40143a <explode_bomb>
  400fb2:   b8 00 00 00 00          mov    $0x0,%eax
  400fb7:   eb 05                   jmp    400fbe <phase_3+0x7b>
  400fb9:   b8 37 01 00 00          mov    $0x137,%eax
  400fbe:   3b 44 24 0c             cmp    0xc(%rsp),%eax
  400fc2:   74 05                   je     400fc9 <phase_3+0x86>
  400fc4:   e8 71 04 00 00          callq  40143a <explode_bomb>
  400fc9:   48 83 c4 18             add    $0x18,%rsp
  400fcd:   c3                      retq
```

`400f43`: `sub $0x18,%rsp`, `400f47`: `lea 0xc(%rsp),%rcx` 和 `400f4c`: `lea 0x8(%rsp),%rdx` 分配了一块 24 bytes 大小的空间，并将 `%rsp + 0xc` 和 `%rsp + 0x8` 的地址分别传给了 `%rcx` 和 `%rdx` 寄存器。

{{< admonition note 寄存器状态 >}}
`%rdx` = `%rsp + 8`  
`%rcx` = `%rsp + 12`
{{< /admonition >}}

`400f51`: `mov $0x4025cf,%esi` 又出现了一个诡异的地址 `0x4025cf`，不过紧跟着后面也同时出现了系统函数 `sscanf`。根据上一关的经验我们推测，`0x4025cf` 指向的应该也是一个格式化字符串。使用 gdb 查看该地址存放的内容：

```text
(gdb) x/s 0x4025cf
```

输出信息：

```text
0x4025cf:       "%d %d"
```

因此，本关密码可能是要按这个格式输入 2 个整数。同时由上一关的分析，这 2 个整数将被保存在之前 2 个参数所提供的 2 个地址中。

因此读取完毕后，栈内保存的信息为：

{{< admonition note 栈状态 >}}
`0x8(%rsp)` = `nums[0]`  
`0xc(%rsp)` = `nums[1]`
{{< /admonition >}}

其中，`nums[0]` 和 `nums[1]` 表示输入的字符串中解析得到的（前）2 个整数。

`400f60`: `cmp $0x1,%eax` 和 `400f63`: `jg 400f6a <phase_3+0x27>` 判断函数 `sscanf` 的返回值是否大于 `1`，是则直接跳到 `400f6a`: `cmpl $0x7,0x8(%rsp)` 继续执行之后的语句，否则执行 `400f65`: `callq 40143a <explode_bomb>` 引爆炸弹。同上一关的说明，即检查是否成功读入了超过 1 个整数，如果不成功则直接引爆炸弹。

`400f6a`: `cmpl $0x7,0x8(%rsp)` 和 `400f6f`: `ja 400fad <phase_3+0x6a>` 判断 `0x8(%rsp)` 的值（即 `nums[0]`，也就是输入的第 1 个整数）是否超过 `7`，是则直接跳到 `400fad`: `callq 40143a <explode_bomb>` 引爆炸弹，否则继续执行之后的语句。

因此，输入的第 1 个整数应当不超过 `7`（无符号数），即其取值范围为 $[0,7]$。

`400f71`: `mov 0x8(%rsp),%eax` 将 `0x8(%rsp)` 的值传给了 `%eax` 寄存器。

{{< admonition note 寄存器状态 >}}
`%eax` = `0x8(%rsp)` = `nums[0]`
{{< /admonition >}}

观察之后的片段：

```text
  400f75:   ff 24 c5 70 24 40 00    jmpq   *0x402470(,%rax,8)
  400f7c:   b8 cf 00 00 00          mov    $0xcf,%eax
  400f81:   eb 3b                   jmp    400fbe <phase_3+0x7b>
  400f83:   b8 c3 02 00 00          mov    $0x2c3,%eax
  400f88:   eb 34                   jmp    400fbe <phase_3+0x7b>
  400f8a:   b8 00 01 00 00          mov    $0x100,%eax
  400f8f:   eb 2d                   jmp    400fbe <phase_3+0x7b>
  400f91:   b8 85 01 00 00          mov    $0x185,%eax
  400f96:   eb 26                   jmp    400fbe <phase_3+0x7b>
  400f98:   b8 ce 00 00 00          mov    $0xce,%eax
  400f9d:   eb 1f                   jmp    400fbe <phase_3+0x7b>
  400f9f:   b8 aa 02 00 00          mov    $0x2aa,%eax
  400fa4:   eb 18                   jmp    400fbe <phase_3+0x7b>
  400fa6:   b8 47 01 00 00          mov    $0x147,%eax
  400fab:   eb 11                   jmp    400fbe <phase_3+0x7b>
  ...
  400fb2:   b8 00 00 00 00          mov    $0x0,%eax
  400fb7:   eb 05                   jmp    400fbe <phase_3+0x7b>
  400fb9:   b8 37 01 00 00          mov    $0x137,%eax
  400fbe:   3b 44 24 0c             cmp    0xc(%rsp),%eax
  400fc2:   74 05                   je     400fc9 <phase_3+0x86>
  400fc4:   e8 71 04 00 00          callq  40143a <explode_bomb>
  400fc9:   48 83 c4 18             add    $0x18,%rsp
  400fcd:   c3                      retq
```

容易发现这是一个 switch 结构，`400f75`: `jmpq *0x402470(,%rax,8)` 即根据 `%rax` 寄存器的值（即 `nums[0]`）跳转到对应地址存放的地址（相当于一个跳转表）。

`nums[0]` 的取值范围为 $[0,7]$，我们逐一测试。

这里以 `nums[0]` 取 `1` 时为例，此时 `0x402470(,%rax,8)` 的值为 `0x402470 + 1 * 8 = 0x402478`。使用 gdb 查看该地址存放的地址：

```text
(gdb) x/g 0x402478
```

输出信息：

```text
0x402478:       0x0000000000400fb9
```

因此 `400fb9`: `mov $0x137,%eax` 即为 `nums[0]` 取 `1` 时跳转到的语句。

类似地，我们可以得到 `nums[0]` 取 $[0,7]$ 时对应的整个跳转表，从而得到以下 C 语言代码：

```c
switch (nums[0]) {                          // result in %eax
    case 0: result = 0xcf; break;           // 0x400f7c
    case 1: result = 0x137; break;          // 0x400fb9
    case 2: result = 0x2c3; break;          // 0x400f83
    case 3: result = 0x100; break;          // 0x400f8a
    case 4: result = 0x185; break;          // 0x400f91
    case 5: result = 0xce; break;           // 0x400f98
    case 6: result = 0x2aa; break;          // 0x400f9f
    case 7: result = 0x147; break;          // 0x400fa6
}                                           // 0x400fbe
if (result != nums[1])                      // nums[1] = 0xc(%rsp)
    explode_bomb();
return result;
```

通过这段代码，可以发现 `nums[0]` 经跳转后得到的新数 `result` 就应当为 `nums[1]`。

于是得到本关的 8 组解：`0 207`, `1 311`, `2 707`, `3 256`, `4 389`, `5 206`, `6 682`, `7 327`。

##### 3.2.2 测试

这里以 `0 207` 为例，在 gdb 中输入 Phase 3 的密码：

```text
0 207
```

输出信息：

```text
Halfway there!
```

### Phase 4: recursive calls and the stack discipline

#### 4.1 本关密码

`0 0`, `1 0`, `3 0`, `7 0`

#### 4.2 解题过程

{{< admonition note 寄存器状态 >}}
`%rdi` = `input`
{{< /admonition >}}

##### 4.2.1 观察函数 `phase_4`

在 `bomb.asm` 中找到函数 `phase_4` 对应的汇编语句：

```text
000000000040100c <phase_4>:
  40100c:   48 83 ec 18             sub    $0x18,%rsp
  401010:   48 8d 4c 24 0c          lea    0xc(%rsp),%rcx
  401015:   48 8d 54 24 08          lea    0x8(%rsp),%rdx
  40101a:   be cf 25 40 00          mov    $0x4025cf,%esi
  40101f:   b8 00 00 00 00          mov    $0x0,%eax
  401024:   e8 c7 fb ff ff          callq  400bf0 <__isoc99_sscanf@plt>
  401029:   83 f8 02                cmp    $0x2,%eax
  40102c:   75 07                   jne    401035 <phase_4+0x29>
  40102e:   83 7c 24 08 0e          cmpl   $0xe,0x8(%rsp)
  401033:   76 05                   jbe    40103a <phase_4+0x2e>
  401035:   e8 00 04 00 00          callq  40143a <explode_bomb>
  40103a:   ba 0e 00 00 00          mov    $0xe,%edx
  40103f:   be 00 00 00 00          mov    $0x0,%esi
  401044:   8b 7c 24 08             mov    0x8(%rsp),%edi
  401048:   e8 81 ff ff ff          callq  400fce <func4>
  40104d:   85 c0                   test   %eax,%eax
  40104f:   75 07                   jne    401058 <phase_4+0x4c>
  401051:   83 7c 24 0c 00          cmpl   $0x0,0xc(%rsp)
  401056:   74 05                   je     40105d <phase_4+0x51>
  401058:   e8 dd 03 00 00          callq  40143a <explode_bomb>
  40105d:   48 83 c4 18             add    $0x18,%rsp
  401061:   c3                      retq
```

`40100c` ~ `401024` 与函数 `phase_3` 中的 `400f43` ~ `400f5b` 完全一致，这里不再赘述。

{{< admonition note 寄存器状态 >}}
`%rdx` = `%rsp + 8`  
`%rcx` = `%rsp + 12`
{{< /admonition >}}

由上一关的分析，本关密码同样应当是输入 2 个整数（之间有且仅有一个空格），这 2 个整数将被保存在之前 2 个参数所提供的 2 个地址中。

因此读取完毕后，栈内保存的信息为：

{{< admonition note 栈状态 >}}
`0x8(%rsp)` = `nums[0]`  
`0xc(%rsp)` = `nums[1]`
{{< /admonition >}}

其中，`nums[0]` 和 `nums[1]` 表示输入的字符串中解析得到的（前）2 个整数。

`401029`: `cmp $0x2,%eax` 和 `40102c`: `jne 401035 <phase_4+0x29>` 判断函数 `sscanf` 的返回值是否等于 `2`，是则继续执行之后的语句，否则直接跳到 `401035`: `callq 40143a <explode_bomb>` 引爆炸弹。同上一关的说明，即检查是否成功读入且仅读入了 2 个整数，如果不是则直接引爆炸弹。

`40102e`: `cmpl $0xe,0x8(%rsp)` 和 `401033`: `jbe 40103a <phase_4+0x2e>` 判断 `0x8(%rsp)` 的值（即 `nums[0]`，也就是输入的第 1 个整数）是否不超过 `14`，是则直接跳到 `40103a`: `mov $0xe,%edx`，否则执行 `401035`: `callq 40143a <explode_bomb>` 引爆炸弹。

因此，输入的第 1 个整数应当不超过 `14`（无符号数），即其取值范围为 $[0,14]$。

`40103a`: `mov $0xe,%edx`, `40103f`: `mov $0x0,%esi` 和 `401044`: `mov 0x8(%rsp),%edi` 将 `%edx`, `%esi`, `%edi` 寄存器分别赋值为 `0xe`, `0x0`, `0x8(%rsp)`。

{{< admonition note 寄存器状态 >}}
`%edi` = `0x8(%rsp)` = `nums[0]`  
`%esi` = `0`  
`%edx` = `14`
{{< /admonition >}}

`401048`: `callq 400fce <func4>` 调用函数 `func4`，也就是本关的主体部分。

##### 4.2.2 观察函数 `func4`

在 `bomb.asm` 中找到函数 `func4` 对应的汇编语句：

```text
0000000000400fce <func4>:
  400fce:   48 83 ec 08             sub    $0x8,%rsp
  400fd2:   89 d0                   mov    %edx,%eax
  400fd4:   29 f0                   sub    %esi,%eax
  400fd6:   89 c1                   mov    %eax,%ecx
  400fd8:   c1 e9 1f                shr    $0x1f,%ecx
  400fdb:   01 c8                   add    %ecx,%eax
  400fdd:   d1 f8                   sar    %eax
  400fdf:   8d 0c 30                lea    (%rax,%rsi,1),%ecx
  400fe2:   39 f9                   cmp    %edi,%ecx
  400fe4:   7e 0c                   jle    400ff2 <func4+0x24>
  400fe6:   8d 51 ff                lea    -0x1(%rcx),%edx
  400fe9:   e8 e0 ff ff ff          callq  400fce <func4>
  400fee:   01 c0                   add    %eax,%eax
  400ff0:   eb 15                   jmp    401007 <func4+0x39>
  400ff2:   b8 00 00 00 00          mov    $0x0,%eax
  400ff7:   39 f9                   cmp    %edi,%ecx
  400ff9:   7d 0c                   jge    401007 <func4+0x39>
  400ffb:   8d 71 01                lea    0x1(%rcx),%esi
  400ffe:   e8 cb ff ff ff          callq  400fce <func4>
  401003:   8d 44 00 01             lea    0x1(%rax,%rax,1),%eax
  401007:   48 83 c4 08             add    $0x8,%rsp
  40100b:   c3                      retq
```

`400fe9` 和 `400ffe`: `callq 400fce <func4>` 都调用了函数 `func4` 自身，可见这是一个递归函数。

试译成 C 语言代码：

```c
// key in %edi, low in %esi, high in %edx
int func4(int key, int low, int high) {
    int      length   = high - low;             // length in %eax
    unsigned sign     = length >> 31;           // sign in %ecx
    int      half_len = (length + sign) >> 1;   // half_len in %eax
                                                // half_len = length /= 2
    int mid = half_len + low;                   // mid in %ecx
    int result;                                 // result in %eax
    if (mid > key) {
        high   = mid - 1;
        result = func4(key, low, high) * 2;
    } else if (mid >= key) {                    // mid == key
        result = 0;
    } else {                                    // mid < key
        low    = mid + 1;
        result = func4(key, low, high) * 2 + 1;
    }
    return result;
}
```

如此这个递归函数的作用就很清晰了。

##### 4.2.3 回到函数 `phase_4`

{{< admonition note 寄存器状态 >}}
`%eax` = `func4(nums[0], 0, 14)`
{{< /admonition >}}

```text
  40104d:   85 c0                   test   %eax,%eax
  40104f:   75 07                   jne    401058 <phase_4+0x4c>
  401051:   83 7c 24 0c 00          cmpl   $0x0,0xc(%rsp)
  401056:   74 05                   je     40105d <phase_4+0x51>
  401058:   e8 dd 03 00 00          callq  40143a <explode_bomb>
  40105d:   48 83 c4 18             add    $0x18,%rsp
  401061:   c3                      retq
```

`40104d`: `test %eax,%eax` 和 `40104f`: `jne 401058 <phase_4+0x4c>` 判断函数 `func4` 的返回值是否为 `0`，是则继续执行之后的语句，否则直接跳到 `401058`: `callq 40143a <explode_bomb>` 引爆炸弹。

因此，输入的第 1 个整数 `nums[0]` 需要使函数 `func4(nums[0], 0, 14)` 的返回值为 `0`，其中 `nums[0]` 的取值范围为 $[0,14]$。

`401051`: `cmpl $0x0,0xc(%rsp)` 和 `401056`: `je 40105d <phase_4+0x51>` 判断 `0xc(%rsp)` 的值（即 `nums[1]`，也就是输入的第 2 个整数）是否为 `0`，是则直接跳到 `40105d`: `add $0x18,%rsp` 弹栈返回，否则执行 `401058`: `callq 40143a <explode_bomb>` 引爆炸弹。

因此，输入的第 2 个整数应当为 `0`。

##### 4.2.4 确定输入的第 1 个整数

事实上，由于 `nums[0]` 的取值范围有限，直接遍历然后测试返回值是否为 `0` 即可。测试代码如下：

```c
void Solution() {
    const int kBegin = 0;
    const int kEnd   = 14;
    printf("The solutions are:");
    for (int i = kBegin; i <= kEnd; ++i) {
        if (func4(i, kBegin, kEnd) == 0)
            printf(" %d", i);
    }
    printf("\n");
}
```

输出结果：

```text
The solutions are: 0 1 3 7
```

即为第 1 个整数可能的值。

综上，本关密码即为 `0 0`, `1 0`, `3 0`, `7 0`。

##### 4.2.5 测试

这里以 `7 0` 为例，在 gdb 中输入 Phase 4 的密码：

```text
7 0
```

输出信息：

```text
So you got that one.  Try this one.
```

### Phase 5: pointers

#### 5.1 本关密码

`9ON567`（不唯一）

#### 5.2 解题过程

{{< admonition note 寄存器状态 >}}
`%rdi` = `input`
{{< /admonition >}}

##### 5.2.1 观察函数 `phase_5`

在 `bomb.asm` 中找到函数 `phase_5` 对应的汇编语句：

```text
0000000000401062 <phase_5>:
  401062:   53                      push   %rbx
  401063:   48 83 ec 20             sub    $0x20,%rsp
  401067:   48 89 fb                mov    %rdi,%rbx
  40106a:   64 48 8b 04 25 28 00    mov    %fs:0x28,%rax
  401071:   00 00
  401073:   48 89 44 24 18          mov    %rax,0x18(%rsp)
  401078:   31 c0                   xor    %eax,%eax
  40107a:   e8 9c 02 00 00          callq  40131b <string_length>
  40107f:   83 f8 06                cmp    $0x6,%eax
  401082:   74 4e                   je     4010d2 <phase_5+0x70>
  401084:   e8 b1 03 00 00          callq  40143a <explode_bomb>
  401089:   eb 47                   jmp    4010d2 <phase_5+0x70>
  40108b:   0f b6 0c 03             movzbl (%rbx,%rax,1),%ecx
  40108f:   88 0c 24                mov    %cl,(%rsp)
  401092:   48 8b 14 24             mov    (%rsp),%rdx
  401096:   83 e2 0f                and    $0xf,%edx
  401099:   0f b6 92 b0 24 40 00    movzbl 0x4024b0(%rdx),%edx
  4010a0:   88 54 04 10             mov    %dl,0x10(%rsp,%rax,1)
  4010a4:   48 83 c0 01             add    $0x1,%rax
  4010a8:   48 83 f8 06             cmp    $0x6,%rax
  4010ac:   75 dd                   jne    40108b <phase_5+0x29>
  4010ae:   c6 44 24 16 00          movb   $0x0,0x16(%rsp)
  4010b3:   be 5e 24 40 00          mov    $0x40245e,%esi
  4010b8:   48 8d 7c 24 10          lea    0x10(%rsp),%rdi
  4010bd:   e8 76 02 00 00          callq  401338 <strings_not_equal>
  4010c2:   85 c0                   test   %eax,%eax
  4010c4:   74 13                   je     4010d9 <phase_5+0x77>
  4010c6:   e8 6f 03 00 00          callq  40143a <explode_bomb>
  4010cb:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
  4010d0:   eb 07                   jmp    4010d9 <phase_5+0x77>
  4010d2:   b8 00 00 00 00          mov    $0x0,%eax
  4010d7:   eb b2                   jmp    40108b <phase_5+0x29>
  4010d9:   48 8b 44 24 18          mov    0x18(%rsp),%rax
  4010de:   64 48 33 04 25 28 00    xor    %fs:0x28,%rax
  4010e5:   00 00
  4010e7:   74 05                   je     4010ee <phase_5+0x8c>
  4010e9:   e8 42 fa ff ff          callq  400b30 <__stack_chk_fail@plt>
  4010ee:   48 83 c4 20             add    $0x20,%rsp
  4010f2:   5b                      pop    %rbx
  4010f3:   c3                      retq
```

`401067`: `mov %rdi,%rbx` 将 `%rdi` 寄存器上保存的地址传给了 `%rbx` 寄存器。

{{< admonition note 寄存器状态 >}}
`%rbx` = `%rdi` = `input`
{{< /admonition >}}

```text
  401063:   48 83 ec 20             sub    $0x20,%rsp
  ...
  40106a:   64 48 8b 04 25 28 00    mov    %fs:0x28,%rax
  401071:   00 00
  401073:   48 89 44 24 18          mov    %rax,0x18(%rsp)
  ...
  4010d9:   48 8b 44 24 18          mov    0x18(%rsp),%rax
  4010de:   64 48 33 04 25 28 00    xor    %fs:0x28,%rax
  4010e5:   00 00
  4010e7:   74 05                   je     4010ee <phase_5+0x8c>
  4010e9:   e8 42 fa ff ff          callq  400b30 <__stack_chk_fail@plt>
  4010ee:   48 83 c4 20             add    $0x20,%rsp
  4010f2:   5b                      pop    %rbx
  4010f3:   c3                      retq
```

这里的 `%fs:0x28` 是 FS 段寄存器（segment register）上偏移地址 `0x28` 上的数据。这是一个随机量，在这里起到 stack canary 的作用[^fs-so] [^fs-se]。这部分代码即利用这个 stack canary 来确保 `0x18(%rsp)` 的数值（即栈底的 8 bytes）在函数前后没有发生改动，如果发生改动则执行 `4010e9`: `callq 400b30 <__stack_chk_fail@plt>` 调用系统函数 `__stack_chk_fail` 跳出，从而防止栈溢出（stack overflow）的问题。事实上，这段代码与本关的关系不大，这里就不做更多阐述了。

```text
  401078:   31 c0                   xor    %eax,%eax
  40107a:   e8 9c 02 00 00          callq  40131b <string_length>
  40107f:   83 f8 06                cmp    $0x6,%eax
  401082:   74 4e                   je     4010d2 <phase_5+0x70>
  401084:   e8 b1 03 00 00          callq  40143a <explode_bomb>
```

`401078`: `xor %eax,%eax` 将 `%eax` 寄存器设置为 `0`。

{{< admonition note 寄存器状态 >}}
`%eax` = `0`
{{< /admonition >}}

`40107a`: `callq 40131b <string_length>` 调用函数 `string_length`。由 [1.2.4](#124-观察函数-string_length) 节的分析，函数 `string_length` 的返回值就是字符串 `input` 的长度。

`40107f`: `cmp $0x6,%eax` 和 `401082`: `je 4010d2 <phase_5+0x70>` 判断返回值是否为 `6`，是则直接跳到 `4010d2`: `mov $0x0,%eax`，否则执行 `401084`: `callq 40143a <explode_bomb>` 引爆炸弹。

可见，输入的字符串的长度应当为 `6`。

```text
  401089:   eb 47                   jmp    4010d2 <phase_5+0x70>
  40108b:   0f b6 0c 03             movzbl (%rbx,%rax,1),%ecx
  40108f:   88 0c 24                mov    %cl,(%rsp)
  401092:   48 8b 14 24             mov    (%rsp),%rdx
  401096:   83 e2 0f                and    $0xf,%edx
  401099:   0f b6 92 b0 24 40 00    movzbl 0x4024b0(%rdx),%edx
  4010a0:   88 54 04 10             mov    %dl,0x10(%rsp,%rax,1)
  4010a4:   48 83 c0 01             add    $0x1,%rax
  4010a8:   48 83 f8 06             cmp    $0x6,%rax
  4010ac:   75 dd                   jne    40108b <phase_5+0x29>
  4010ae:   c6 44 24 16 00          movb   $0x0,0x16(%rsp)
  4010b3:   be 5e 24 40 00          mov    $0x40245e,%esi
  4010b8:   48 8d 7c 24 10          lea    0x10(%rsp),%rdi
  4010bd:   e8 76 02 00 00          callq  401338 <strings_not_equal>
  4010c2:   85 c0                   test   %eax,%eax
  4010c4:   74 13                   je     4010d9 <phase_5+0x77>
  4010c6:   e8 6f 03 00 00          callq  40143a <explode_bomb>
  4010cb:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
  4010d0:   eb 07                   jmp    4010d9 <phase_5+0x77>
  4010d2:   b8 00 00 00 00          mov    $0x0,%eax
  4010d7:   eb b2                   jmp    40108b <phase_5+0x29>
  4010d9:   48 8b 44 24 18          mov    0x18(%rsp),%rax
  ...
```

剩下的内容也就是本关的主体部分。直观起见，试译成 C 语言代码：

```c
cur_char = 0;                                   // cur_char in %rcx
for (i = 0; i != 6; ++i) {                      // i in %rax
    cur_char = input[i];                        // input in %rbx
    index    = cur_char;                        // index in %rsp, later copied to %edx
    index &= 0xf;
    target_char = target[index];                // target_char in %edx, target in 0x4024b0
    word[i]     = target_char;                  // word in %rsp + 0x10
}
word[6] = '\0';
result  = strings_not_equal(word, 0x40245e);    // result in %eax
if (result != 0)
    explode_bomb();
return result;
```

其中，由 [1.2.5](#125-回到函数-strings_not_equal) 节的分析，函数 `strings_not_equal` 的作用为检查两个字符串是否相等，是则返回 `0`，否则返回 `1`。同时也可以知道 `0x40245e` 这个地址指向的是一个字符串。

可见，这段代码的作用为：

1. 构造一个 6 位的新字符串 `word`，遍历输入的字符串 `input` 的 6 个字符，以字符 `input[i]` 的最低 4 位二进制数为索引 `index`，依次将 `word[i]` 设置为字符 `target[index]`（可以推测出 `0x4024b0` 这个地址指向的也是一个字符串，这里设为 `target`），最后将 `word[6]` 设置为 `'\0'` 作为字符串结束符；
2. 检查字符串 `word` 和 `0x40245e` 指向的字符串是否相等，是则直接返回，否则引爆炸弹。

因此，由 `0x40245e` 指向的字符串倒推得对应的 6 个索引 `index`，再根据这些 `index` 得到输入的字符串 `input` 的 6 个字符，就可以得到本关的密码。

[^fs-so]: [c - Why does this memory address %fs:0x28 ( fs[0x28] ) have a random value? - Stack Overflow](https://stackoverflow.com/questions/10325713/why-does-this-memory-address-fs0x28-fs0x28-have-a-random-value)
[^fs-se]: [linux - What sets fs:[0x28] (stack canary)? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/453749/what-sets-fs0x28-stack-canary)

##### 5.2.2 确定目标字符串 `word`

使用 gdb 查看地址 `0x40245e` 存放的内容：

```text
(gdb) x/s 0x40245e
```

输出信息：

```text
0x40245e:       "flyers"
```

这就是我们需要构造的目标字符串 `word` 的值。

##### 5.2.3 确定 6 个索引 `index`

使用 gdb 查看地址 `0x4024b0` 存放的内容：

```text
(gdb) x/s 0x4024b0
```

输出信息：

```text
0x4024b0 <array.3449>:  "maduiersnfotvbylSo you think you can stop the bomb with ctrl-c, do you?"
```

这就是字符串 `target` 的值，我们需要将 `word[i]` 分别设置为字符 `target[index]`。于是得到对应的 6 个 `index` 的值为：`0x9`, `0xf`, `0xe`, `0x5`, `0x6`, `0x7`（`index` 是 4 位二进制数，因此其取值范围为 $[\mathtt{0x0},\mathtt{0xf}]$）。

##### 5.2.4 确定输入的 6 个字符

由于索引 `index` 是字符 `input[i]` 的最后 4 位（二进制），通过 ASCII 码表找到最后 4 位为 `index` 的字符即可[^ascii-wiki]。于是得到对应的 6 个字符为：`9`, `O`, `N`, `5`, `6`, `7`（答案不唯一，这里就不一一列举了）。

因此，本关密码即为 `9ON567`。

[^ascii-wiki]: [ASCII - Wikipedia](https://en.wikipedia.org/wiki/ASCII)

##### 5.2.5 测试

在 gdb 中输入 Phase 5 的密码：

```text
9ON567
```

输出信息：

```text
Good work!  On to the next...
```

### Phase 6: linked lists / pointers / structs

#### 6.1 本关密码

`4 3 2 1 6 5`

#### 6.2 解题过程

{{< admonition note 寄存器状态 >}}
`%rdi` = `input`
{{< /admonition >}}

##### 6.2.0 观察函数 `phase_6`

在 `bomb.asm` 中找到函数 `phase_6` 对应的汇编语句：

```text
00000000004010f4 <phase_6>:
  4010f4:   41 56                   push   %r14
  4010f6:   41 55                   push   %r13
  4010f8:   41 54                   push   %r12
  4010fa:   55                      push   %rbp
  4010fb:   53                      push   %rbx
  4010fc:   48 83 ec 50             sub    $0x50,%rsp
  401100:   49 89 e5                mov    %rsp,%r13
  401103:   48 89 e6                mov    %rsp,%rsi
  401106:   e8 51 03 00 00          callq  40145c <read_six_numbers>
  40110b:   49 89 e6                mov    %rsp,%r14
  40110e:   41 bc 00 00 00 00       mov    $0x0,%r12d
  401114:   4c 89 ed                mov    %r13,%rbp
  401117:   41 8b 45 00             mov    0x0(%r13),%eax
  40111b:   83 e8 01                sub    $0x1,%eax
  40111e:   83 f8 05                cmp    $0x5,%eax
  401121:   76 05                   jbe    401128 <phase_6+0x34>
  401123:   e8 12 03 00 00          callq  40143a <explode_bomb>
  401128:   41 83 c4 01             add    $0x1,%r12d
  40112c:   41 83 fc 06             cmp    $0x6,%r12d
  401130:   74 21                   je     401153 <phase_6+0x5f>
  401132:   44 89 e3                mov    %r12d,%ebx
  401135:   48 63 c3                movslq %ebx,%rax
  401138:   8b 04 84                mov    (%rsp,%rax,4),%eax
  40113b:   39 45 00                cmp    %eax,0x0(%rbp)
  40113e:   75 05                   jne    401145 <phase_6+0x51>
  401140:   e8 f5 02 00 00          callq  40143a <explode_bomb>
  401145:   83 c3 01                add    $0x1,%ebx
  401148:   83 fb 05                cmp    $0x5,%ebx
  40114b:   7e e8                   jle    401135 <phase_6+0x41>
  40114d:   49 83 c5 04             add    $0x4,%r13
  401151:   eb c1                   jmp    401114 <phase_6+0x20>
  401153:   48 8d 74 24 18          lea    0x18(%rsp),%rsi
  401158:   4c 89 f0                mov    %r14,%rax
  40115b:   b9 07 00 00 00          mov    $0x7,%ecx
  401160:   89 ca                   mov    %ecx,%edx
  401162:   2b 10                   sub    (%rax),%edx
  401164:   89 10                   mov    %edx,(%rax)
  401166:   48 83 c0 04             add    $0x4,%rax
  40116a:   48 39 f0                cmp    %rsi,%rax
  40116d:   75 f1                   jne    401160 <phase_6+0x6c>
  40116f:   be 00 00 00 00          mov    $0x0,%esi
  401174:   eb 21                   jmp    401197 <phase_6+0xa3>
  401176:   48 8b 52 08             mov    0x8(%rdx),%rdx
  40117a:   83 c0 01                add    $0x1,%eax
  40117d:   39 c8                   cmp    %ecx,%eax
  40117f:   75 f5                   jne    401176 <phase_6+0x82>
  401181:   eb 05                   jmp    401188 <phase_6+0x94>
  401183:   ba d0 32 60 00          mov    $0x6032d0,%edx
  401188:   48 89 54 74 20          mov    %rdx,0x20(%rsp,%rsi,2)
  40118d:   48 83 c6 04             add    $0x4,%rsi
  401191:   48 83 fe 18             cmp    $0x18,%rsi
  401195:   74 14                   je     4011ab <phase_6+0xb7>
  401197:   8b 0c 34                mov    (%rsp,%rsi,1),%ecx
  40119a:   83 f9 01                cmp    $0x1,%ecx
  40119d:   7e e4                   jle    401183 <phase_6+0x8f>
  40119f:   b8 01 00 00 00          mov    $0x1,%eax
  4011a4:   ba d0 32 60 00          mov    $0x6032d0,%edx
  4011a9:   eb cb                   jmp    401176 <phase_6+0x82>
  4011ab:   48 8b 5c 24 20          mov    0x20(%rsp),%rbx
  4011b0:   48 8d 44 24 28          lea    0x28(%rsp),%rax
  4011b5:   48 8d 74 24 50          lea    0x50(%rsp),%rsi
  4011ba:   48 89 d9                mov    %rbx,%rcx
  4011bd:   48 8b 10                mov    (%rax),%rdx
  4011c0:   48 89 51 08             mov    %rdx,0x8(%rcx)
  4011c4:   48 83 c0 08             add    $0x8,%rax
  4011c8:   48 39 f0                cmp    %rsi,%rax
  4011cb:   74 05                   je     4011d2 <phase_6+0xde>
  4011cd:   48 89 d1                mov    %rdx,%rcx
  4011d0:   eb eb                   jmp    4011bd <phase_6+0xc9>
  4011d2:   48 c7 42 08 00 00 00    movq   $0x0,0x8(%rdx)
  4011d9:   00
  4011da:   bd 05 00 00 00          mov    $0x5,%ebp
  4011df:   48 8b 43 08             mov    0x8(%rbx),%rax
  4011e3:   8b 00                   mov    (%rax),%eax
  4011e5:   39 03                   cmp    %eax,(%rbx)
  4011e7:   7d 05                   jge    4011ee <phase_6+0xfa>
  4011e9:   e8 4c 02 00 00          callq  40143a <explode_bomb>
  4011ee:   48 8b 5b 08             mov    0x8(%rbx),%rbx
  4011f2:   83 ed 01                sub    $0x1,%ebp
  4011f5:   75 e8                   jne    4011df <phase_6+0xeb>
  4011f7:   48 83 c4 50             add    $0x50,%rsp
  4011fb:   5b                      pop    %rbx
  4011fc:   5d                      pop    %rbp
  4011fd:   41 5c                   pop    %r12
  4011ff:   41 5d                   pop    %r13
  401201:   41 5e                   pop    %r14
  401203:   c3                      retq
```

发现这段代码相当长，所以这里就不逐句分析了，直接逆向工程。

##### 6.2.1 第一部分（`4010f4` ~ `40110b`）

```text
  4010f4:   41 56                   push   %r14
  4010f6:   41 55                   push   %r13
  4010f8:   41 54                   push   %r12
  4010fa:   55                      push   %rbp
  4010fb:   53                      push   %rbx
  4010fc:   48 83 ec 50             sub    $0x50,%rsp
  401100:   49 89 e5                mov    %rsp,%r13
  401103:   48 89 e6                mov    %rsp,%rsi
  401106:   e8 51 03 00 00          callq  40145c <read_six_numbers>
  40110b:   49 89 e6                mov    %rsp,%r14
```

首先读入 6 个整数（详见 [2.2.2](#222-观察函数-read_six_numbers) 节），保存到栈中。

{{< admonition note 寄存器状态 >}}
`%rsi` = `%r13` = `%r14` = `%rsp`
{{< /admonition >}}

{{< admonition note 栈状态 >}}
`0x00(%rsp)` = `nums[0]`  
`0x04(%rsp)` = `nums[1]`  
`0x08(%rsp)` = `nums[2]`  
`0x0c(%rsp)` = `nums[3]`  
`0x10(%rsp)` = `nums[4]`  
`0x14(%rsp)` = `nums[5]`
{{< /admonition >}}

其中，`nums[0]` ... `nums[5]` 表示输入的字符串中解析得到的（前）6 个整数。

##### 6.2.2 第二部分（`40110e` ~ `401151`）

```text
  40110e:   41 bc 00 00 00 00       mov    $0x0,%r12d
  401114:   4c 89 ed                mov    %r13,%rbp
  401117:   41 8b 45 00             mov    0x0(%r13),%eax
  40111b:   83 e8 01                sub    $0x1,%eax
  40111e:   83 f8 05                cmp    $0x5,%eax
  401121:   76 05                   jbe    401128 <phase_6+0x34>
  401123:   e8 12 03 00 00          callq  40143a <explode_bomb>
  401128:   41 83 c4 01             add    $0x1,%r12d
  40112c:   41 83 fc 06             cmp    $0x6,%r12d
  401130:   74 21                   je     401153 <phase_6+0x5f>
  401132:   44 89 e3                mov    %r12d,%ebx
  401135:   48 63 c3                movslq %ebx,%rax
  401138:   8b 04 84                mov    (%rsp,%rax,4),%eax
  40113b:   39 45 00                cmp    %eax,0x0(%rbp)
  40113e:   75 05                   jne    401145 <phase_6+0x51>
  401140:   e8 f5 02 00 00          callq  40143a <explode_bomb>
  401145:   83 c3 01                add    $0x1,%ebx
  401148:   83 fb 05                cmp    $0x5,%ebx
  40114b:   7e e8                   jle    401135 <phase_6+0x41>
  40114d:   49 83 c5 04             add    $0x4,%r13
  401151:   eb c1                   jmp    401114 <phase_6+0x20>
  401153:   48 8d 74 24 18          lea    0x18(%rsp),%rsi
  ...
```

试译成 C 语言代码：

```c
// cur_pos = nums;                              // cur_pos in %r13, nums in %rsp
next_index = 0;                                 // next_index in %r12d
while (true) {
    cur_num = *cur_pos;                         // cur_pos in %r13, later copied to %rbp
    if (--cur_num > 5)                          // cur_num in %eax
        explode_bomb();
    ++next_index;
    if (next_index == 6)
        break;
    for (i = next_index; i <= 5; ++i) {         // i in %ebx, later copied to %rax
        next_num = nums[i];                     // next_num in %eax
        if (next_num == *cur_pos)
            explode_bomb();
    }
    ++cur_pos;
}
```

通过这段代码，可以得知输入的 6 个整数需要满足以下条件：

1. 减 1 后不能超过 `5`（无符号数），即其取值范围为 $[1,6]$；
2. 必须互不相同。

因此，这 6 个整数是 `1` ~ `6` 的一个全排列。

##### 6.2.3 第三部分（`401153` ~ `40116d`）

```text
  401153:   48 8d 74 24 18          lea    0x18(%rsp),%rsi
  401158:   4c 89 f0                mov    %r14,%rax
  40115b:   b9 07 00 00 00          mov    $0x7,%ecx
  401160:   89 ca                   mov    %ecx,%edx
  401162:   2b 10                   sub    (%rax),%edx
  401164:   89 10                   mov    %edx,(%rax)
  401166:   48 83 c0 04             add    $0x4,%rax
  40116a:   48 39 f0                cmp    %rsi,%rax
  40116d:   75 f1                   jne    401160 <phase_6+0x6c>
```

试译成 C 语言代码：

```c
// begin_pos = rsp;                             // begin_pos in %r14
end_pos = rsp + 6;                              // end_pos in %rsi
minuend = 7;                                    // minuend in %ecx
for (i = begin_pos; i != end_pos; ++i) {        // i in %rax
    new_num = minuend - *i;                     // new_num in %edx
    *i      = new_num;
}
```

可见，保存在栈中的这 6 个整数 `nums[i]` 被依次修改成了 `7 - nums[i]`。

##### 6.2.4 第四部分（`40116f` ~ `4011a9`）

```text
  40116f:   be 00 00 00 00          mov    $0x0,%esi
  401174:   eb 21                   jmp    401197 <phase_6+0xa3>
  401176:   48 8b 52 08             mov    0x8(%rdx),%rdx
  40117a:   83 c0 01                add    $0x1,%eax
  40117d:   39 c8                   cmp    %ecx,%eax
  40117f:   75 f5                   jne    401176 <phase_6+0x82>
  401181:   eb 05                   jmp    401188 <phase_6+0x94>
  401183:   ba d0 32 60 00          mov    $0x6032d0,%edx
  401188:   48 89 54 74 20          mov    %rdx,0x20(%rsp,%rsi,2)
  40118d:   48 83 c6 04             add    $0x4,%rsi
  401191:   48 83 fe 18             cmp    $0x18,%rsi
  401195:   74 14                   je     4011ab <phase_6+0xb7>
  401197:   8b 0c 34                mov    (%rsp,%rsi,1),%ecx
  40119a:   83 f9 01                cmp    $0x1,%ecx
  40119d:   7e e4                   jle    401183 <phase_6+0x8f>
  40119f:   b8 01 00 00 00          mov    $0x1,%eax
  4011a4:   ba d0 32 60 00          mov    $0x6032d0,%edx
  4011a9:   eb cb                   jmp    401176 <phase_6+0x82>
  4011ab:   48 8b 5c 24 20          mov    0x20(%rsp),%rbx
  ...
```

这是本关的主体部分。试译成 C 语言代码：

```c
for (i = 0; i != 6; ++i) {          // i in %rsi
    cur_num = nums[i];              // cur_num in %ecx, nums in %rsp
    p_node  = 0x6032d0;             // p_node in %edx
    for (j = 1; j < cur_num; ++j)   // j in %eax
        p_node = *(++p_node);       // assure that p_node is always a pointer
    ptrs[i] = p_node;               // ptrs in %rsp + 0x20
}
```

可见，根据被修改后的这 6 个整数 `nums[i]`，这段代码在 `ptrs[i]`（即 `*(%rsp + 0x20 + i * 0x8)`）中存放经过 `nums[i] - 1` 次 `p_node = *(++p_node)` 操作的地址 `p_node`，其中 `p_node` 的初始值为 `0x6032d0`。

可以看出这实际就是将链表的 6 个结点以 `nums[i]` 为索引顺序存到栈中。每次操作就是将 `p_node` 指向下一个结点，因此经过 `nums[i] - 1` 次操作得到的 `p_node` 就是 `nums[i]` 号结点的地址 `p_node(nums[i])`。

{{< admonition note 栈状态 >}}
`ptrs[i]` = `p_node(nums[i])`
{{< /admonition >}}

由之前的分析，`nums[i]` 是 `1` ~ `6` 的一个全排列，由此可以得到这 6 个结点的地址。

以进行 1 次操作为例，使用 gdb 查看此时 `p_node` 的值（原 `p_node` + `0x8` 所指向的内容）：

```text
(gdb) x/xw 0x6032d8
```

输出信息：

```text
0x6032d8 <node1+8>:     0x006032e0
```

这就是 2 号结点的地址 `p_node2`。

用同样的方式得到 6 个结点的地址：

{{< admonition note 结点地址 >}}
`p_node1` = `0x6032d0`  
`p_node2` = `0x6032e0`  
`p_node3` = `0x6032f0`  
`p_node4` = `0x603300`  
`p_node5` = `0x603310`  
`p_node6` = `0x603220`
{{< /admonition >}}

##### 6.2.5 第五部分（`4011ab` ~ `4011d0`）

```text
  4011ab:   48 8b 5c 24 20          mov    0x20(%rsp),%rbx
  4011b0:   48 8d 44 24 28          lea    0x28(%rsp),%rax
  4011b5:   48 8d 74 24 50          lea    0x50(%rsp),%rsi
  4011ba:   48 89 d9                mov    %rbx,%rcx
  4011bd:   48 8b 10                mov    (%rax),%rdx
  4011c0:   48 89 51 08             mov    %rdx,0x8(%rcx)
  4011c4:   48 83 c0 08             add    $0x8,%rax
  4011c8:   48 39 f0                cmp    %rsi,%rax
  4011cb:   74 05                   je     4011d2 <phase_6+0xde>
  4011cd:   48 89 d1                mov    %rdx,%rcx
  4011d0:   eb eb                   jmp    4011bd <phase_6+0xc9>
  4011d2:   48 c7 42 08 00 00 00    movq   $0x0,0x8(%rdx)
  4011d9:   00
  ...
```

试译成 C 语言代码：

```c
begin_node = *ptrs;                 // begin_node in %rbx, ptrs in %rsp + 0x20
next_pos   = ptrs + 1;              // next_pos in %rax
end_pos    = ptrs + 6;              // end_pos in %rsi
for (cur_node = begin_node; next_pos != end_pos;
     cur_node = next_node) {        // cur_node in %rcx
    next_node       = *next_pos;    // next_node in %rdx
    *(cur_node + 1) = next_node;
    ++next_pos;
}
```

可见，这段代码的作用为按**在栈中地址由低到高顺序**遍历链表的 6 个结点，将它们串联起来。

这里的 `*(cur_node + 1)` 实质上就是 `cur_node->next`（即 `(*cur_node).next`），因为链表中的结点其实是一个结构体（struct），结点所在的地址指向的是数据 `val`，加上 `0x8` 后指向的也就是指针 `next`。此处将该指针 `next` 指向了下一个结点。

##### 6.2.6 第六部分（`4011da` ~ `401203`）

```text
  4011da:   bd 05 00 00 00          mov    $0x5,%ebp
  4011df:   48 8b 43 08             mov    0x8(%rbx),%rax
  4011e3:   8b 00                   mov    (%rax),%eax
  4011e5:   39 03                   cmp    %eax,(%rbx)
  4011e7:   7d 05                   jge    4011ee <phase_6+0xfa>
  4011e9:   e8 4c 02 00 00          callq  40143a <explode_bomb>
  4011ee:   48 8b 5b 08             mov    0x8(%rbx),%rbx
  4011f2:   83 ed 01                sub    $0x1,%ebp
  4011f5:   75 e8                   jne    4011df <phase_6+0xeb>
  4011f7:   48 83 c4 50             add    $0x50,%rsp
  4011fb:   5b                      pop    %rbx
  4011fc:   5d                      pop    %rbp
  4011fd:   41 5c                   pop    %r12
  4011ff:   41 5d                   pop    %r13
  401201:   41 5e                   pop    %r14
  401203:   c3                      retq
```

试译成 C 语言代码：

```c
for (i = 5; i != 0; --i) {          // i in %ebp
    next_node = *(cur_node + 1);    // next_node in %rax, cur_node in %rbx
    next_num  = *next_node;         // next_num in %eax
    if (*cur_node < next_num)
        explode_bomb();
    cur_node = *(cur_node + 1);
}
return next_node;
```

由上一节的分析，`*cur_node` 即 `cur_node->val`，`*(cur_node + 1)` 即 `cur_node->next`。通过这段代码，可以发现链表各个结点的数据 `val` 需要是顺序递减的。

以 1 号结点 `node1` 为例，使用 gdb 查看其数据 `val`：

```text
(gdb) x/d 0x6032d0
```

输出信息：

```text
0x6032d0 <node1>:       332
```

用同样的方式得到链表 6 个结点的数据：

{{< admonition note 结点数据 >}}
`p_node1->val` = `332`  
`p_node2->val` = `168`  
`p_node3->val` = `924`  
`p_node4->val` = `691`  
`p_node5->val` = `477`  
`p_node6->val` = `443`
{{< /admonition >}}

按递减顺序排列后，可见在栈中地址由低到高应当分别为 `3`, `4`, `5`, `6`, `1`, `2` 号结点。

##### 6.2.7 确定输入的 6 个整数

由之前的分析，`nums[i]` 在第三部分的代码中被依次修改成了 `7 - nums[i]`，而修改后的值分别对应栈中结点的标号 `3`, `4`, `5`, `6`, `1`, `2`。

因此，最开始输入的 6 个整数也就是 `4`, `3`, `2`, `1`, `6`, `5`，本关密码即为 `4 3 2 1 6 5`。

##### 6.2.8 测试

在 gdb 中输入 Phase 6 的密码：

```text
4 3 2 1 6 5
```

输出信息：

```text
Congratulations! You've defused the bomb!
```

### 结束了吗？

在 `bomb.c` 文件的最后，留下了这样一句耐人寻味的话：

```c
/* Wow, they got it!  But isn't something... missing?  Perhaps
 * something they overlooked?  Mua ha ha ha ha! */
```

这是因为，本 Lab 还有一个隐藏关！

### Secret Phase

#### 7.1 本关密码

##### 7.1.1 开启隐藏关的方法

在 Phase 4 输入的 2 个整数后再额外输入 1 个字符串 `DrEvil`，例如将输入的字符串修改为 `7 0 DrEvil`，其余环节不变。

##### 7.1.2 隐藏关的密码

`22`, `20`

#### 7.2 解题过程

##### 7.2.0 找到隐藏函数

好吧，其实在 `bomb.asm` 中稍微往下翻翻就能找到一个名为 `secret_phase` 的函数。顾名思义，这应该就是隐藏关所对应的函数。

##### 7.2.1 找到开启隐藏关的方法

事实上，前 6 关通过后，程序就自动终止了。那么应该如何进入这个隐藏关呢？

在 `bomb.asm` 搜索关键词 `secret_phase`，可以发现在函数 `phase_defused` 中出现了调用函数 `secret_phase` 的语句 `401630`: `callq 401242 <secret_phase>`。其中函数 `phase_defused` 就是每关通过后都会调用的函数。

```text
00000000004015c4 <phase_defused>:
  4015c4:   48 83 ec 78             sub    $0x78,%rsp
  4015c8:   64 48 8b 04 25 28 00    mov    %fs:0x28,%rax
  4015cf:   00 00
  4015d1:   48 89 44 24 68          mov    %rax,0x68(%rsp)
  4015d6:   31 c0                   xor    %eax,%eax
  4015d8:   83 3d 81 21 20 00 06    cmpl   $0x6,0x202181(%rip)        # 603760 <num_input_strings>
  4015df:   75 5e                   jne    40163f <phase_defused+0x7b>
  4015e1:   4c 8d 44 24 10          lea    0x10(%rsp),%r8
  4015e6:   48 8d 4c 24 0c          lea    0xc(%rsp),%rcx
  4015eb:   48 8d 54 24 08          lea    0x8(%rsp),%rdx
  4015f0:   be 19 26 40 00          mov    $0x402619,%esi
  4015f5:   bf 70 38 60 00          mov    $0x603870,%edi
  4015fa:   e8 f1 f5 ff ff          callq  400bf0 <__isoc99_sscanf@plt>
  4015ff:   83 f8 03                cmp    $0x3,%eax
  401602:   75 31                   jne    401635 <phase_defused+0x71>
  401604:   be 22 26 40 00          mov    $0x402622,%esi
  401609:   48 8d 7c 24 10          lea    0x10(%rsp),%rdi
  40160e:   e8 25 fd ff ff          callq  401338 <strings_not_equal>
  401613:   85 c0                   test   %eax,%eax
  401615:   75 1e                   jne    401635 <phase_defused+0x71>
  401617:   bf f8 24 40 00          mov    $0x4024f8,%edi
  40161c:   e8 ef f4 ff ff          callq  400b10 <puts@plt>
  401621:   bf 20 25 40 00          mov    $0x402520,%edi
  401626:   e8 e5 f4 ff ff          callq  400b10 <puts@plt>
  40162b:   b8 00 00 00 00          mov    $0x0,%eax
  401630:   e8 0d fc ff ff          callq  401242 <secret_phase>
  401635:   bf 58 25 40 00          mov    $0x402558,%edi
  40163a:   e8 d1 f4 ff ff          callq  400b10 <puts@plt>
  40163f:   48 8b 44 24 68          mov    0x68(%rsp),%rax
  401644:   64 48 33 04 25 28 00    xor    %fs:0x28,%rax
  40164b:   00 00
  40164d:   74 05                   je     401654 <phase_defused+0x90>
  40164f:   e8 dc f4 ff ff          callq  400b30 <__stack_chk_fail@plt>
  401654:   48 83 c4 78             add    $0x78,%rsp
  401658:   c3                      retq
  401659:   90                      nop
  40165a:   90                      nop
  40165b:   90                      nop
  40165c:   90                      nop
  40165d:   90                      nop
  40165e:   90                      nop
  40165f:   90                      nop
```

注意到以下片段：

```text
  4015d6:   31 c0                   xor    %eax,%eax
  4015d8:   83 3d 81 21 20 00 06    cmpl   $0x6,0x202181(%rip)        # 603760 <num_input_strings>
  4015df:   75 5e                   jne    40163f <phase_defused+0x7b>
  ...
  40163f:   48 8b 44 24 68          mov    0x68(%rsp),%rax
  401644:   64 48 33 04 25 28 00    xor    %fs:0x28,%rax
  40164b:   00 00
  40164d:   74 05                   je     401654 <phase_defused+0x90>
  40164f:   e8 dc f4 ff ff          callq  400b30 <__stack_chk_fail@plt>
  401654:   48 83 c4 78             add    $0x78,%rsp
  401658:   c3                      retq
  401659:   90                      nop
  ...
```

`4015d6`: `xor %eax,%eax` 将 `%eax` 寄存器设置为 `0`。

`4015d8`: `cmpl $0x6,0x202181(%rip)` 和 `4015df`: `jne 40163f <phase_defused+0x7b>` 判断 `0x202181(%rip)` 的值是否为 `6`，是则继续执行之后的语句，否则直接跳到 `40163f`: `mov 0x68(%rsp),%rax` 返回（这一段详见 [5.2.1](#521-观察函数-phase_5) 节关于 stack canary 的阐述）。

`0x202181(%rip)` 也就是 `(0x603760)` 存放的是什么？通过 gdb 发现，这个值的初始值为 `0`，而每通过一关后，这个值便加 `1`。结合注释（即变量名）`# 603760 <num_input_strings>`，推测它表示输入过的字符串数量，实际上也就是通过的关卡数量。

```text
(gdb) x/d 0x603760
0x603760 <num_input_strings>:   0
(gdb) b phase_1
Breakpoint 2 at 0x400ee0
(gdb) b phase_2
Breakpoint 3 at 0x400efc
(gdb) r
Starting program: /root/Hakula/csapp/lab2/bomb
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Border relations with Canada have never been better.

Breakpoint 2, 0x0000000000400ee0 in phase_1 ()
(gdb) x/d 0x603760
0x603760 <num_input_strings>:   1
(gdb) c
Continuing.
Phase 1 defused. How about the next one?
1 2 4 8 16 32

Breakpoint 3, 0x0000000000400efc in phase_2 ()
(gdb) x/d 0x603760
0x603760 <num_input_strings>:   2
(gdb)
```

判断这个值是否为 `6`，也就是判断是否通过了全部 6 个关卡。因此这个隐藏关只有在 6 个关卡都顺利通过后才会开启。

剩下的片段也就是本函数与隐藏关相关的主体部分。

```text
  4015e1:   4c 8d 44 24 10          lea    0x10(%rsp),%r8
  4015e6:   48 8d 4c 24 0c          lea    0xc(%rsp),%rcx
  4015eb:   48 8d 54 24 08          lea    0x8(%rsp),%rdx
  4015f0:   be 19 26 40 00          mov    $0x402619,%esi
  4015f5:   bf 70 38 60 00          mov    $0x603870,%edi
  4015fa:   e8 f1 f5 ff ff          callq  400bf0 <__isoc99_sscanf@plt>
```

这段代码我们已经十分熟悉。`0x402619` 指向的应该是一个格式化字符串。使用 gdb 查看地址 `0x402619` 存放的内容：

```text
(gdb) x/s 0x402619
```

输出信息：

```text
0x402619:       "%d %d %s"
```

因此，在某处我们需要按这个格式输入 2 个整数和 1 个字符串。这 2 个整数将被保存在 `0x8(%rsp)` 和 `0xc(%rsp)` 中，字符串将被保存在 `0x10(%rsp)` 中。需要注意的是这里还额外传入了一个地址 `0x603870`，根据我对系统函数 `sscanf` 的理解，这应当指的是那个被用来解析的字符串的地址。

读取完毕后，栈内保存的信息为：

{{< admonition note 栈状态 >}}
`0x8(%rsp)` = `nums[0]`  
`0xc(%rsp)` = `nums[1]`  
`0x10(%rsp)` = `password`
{{< /admonition >}}

其中，`nums[0]` 和 `nums[1]` 表示 `0x603870` 指向的字符串中解析得到的（前）2 个整数，`password` 表示之后解析得到的（前）1 个字符串。

在函数 `phase_defused` 的入口处设置一个断点。

```text
(gdb) b phase_defused
```

每通过一个关卡后，使用 gdb 查看地址 `0x603870` 存放的内容：

```text
(gdb) x/s 0x603870
```

发现在通过 Phase 4 后，输出信息发生了变化：

```text
0x603870 <input_strings+240>:   "7 0"
```

可见，`0x603870` 指向的是 Phase 4 中输入的字符串 `7 0`。

```text
  4015ff:   83 f8 03                cmp    $0x3,%eax
  401602:   75 31                   jne    401635 <phase_defused+0x71>
  ...
  401630:   e8 0d fc ff ff          callq  401242 <secret_phase>
  401635:   bf 58 25 40 00          mov    $0x402558,%edi
  ...
```

`4015ff`: `cmp $0x3,%eax` 和 `401602`: `jne 401635 <phase_defused+0x71>` 判断函数 `sscanf` 的返回值是否为 `3`，是则继续执行之后的语句，否则直接跳到 `401635`: `mov $0x402558,%edi`，也就是跳过了隐藏关。

于是我们知道，在 Phase 4 中除了需要输入作为密码的 2 个整数外，还需要再额外输入 1 个字符串。这是开启隐藏关的前提条件。

```text
  401604:   be 22 26 40 00          mov    $0x402622,%esi
  401609:   48 8d 7c 24 10          lea    0x10(%rsp),%rdi
  40160e:   e8 25 fd ff ff          callq  401338 <strings_not_equal>
  401613:   85 c0                   test   %eax,%eax
  401615:   75 1e                   jne    401635 <phase_defused+0x71>
  ...
  401630:   e8 0d fc ff ff          callq  401242 <secret_phase>
  401635:   bf 58 25 40 00          mov    $0x402558,%edi
  ...
```

{{< admonition note 寄存器状态 >}}
`%rdi` = `0x10(%rsp)` = `password`  
`%esi` = `0x402622`
{{< /admonition >}}

这段代码我们已经十分熟悉。`0x402622` 指向的应该是一个字符串。使用 gdb 查看地址 `0x402622` 存放的内容：

```text
(gdb) x/s 0x402622
```

输出信息：

```text
0x402622:       "DrEvil"
```

此后，函数 `strings_not_equal` 检查 `%rdi` 和 `%rsi` 寄存器指向的字符串是否相等，即 `password` 是否等于 `DrEvil`，是则返回 `0`，否则返回 `1`。

`401613`: `test %eax,%eax` 和 `401615`: `jne 401635 <phase_defused+0x71>` 判断函数 `strings_not_equal` 的返回值是否为 `0`，是则继续执行之后的语句，否则直接跳到 `401635`: `mov $0x402558,%edi`，也就是跳过了隐藏关。

因此，在 Phase 4 中需要额外输入的 1 个字符串就是 `DrEvil`。

```text
  401617:   bf f8 24 40 00          mov    $0x4024f8,%edi
  40161c:   e8 ef f4 ff ff          callq  400b10 <puts@plt>
  401621:   bf 20 25 40 00          mov    $0x402520,%edi
  401626:   e8 e5 f4 ff ff          callq  400b10 <puts@plt>
  40162b:   b8 00 00 00 00          mov    $0x0,%eax
  401630:   e8 0d fc ff ff          callq  401242 <secret_phase>
  401635:   bf 58 25 40 00          mov    $0x402558,%edi
  40163a:   e8 d1 f4 ff ff          callq  400b10 <puts@plt>
```

这段就是输出几行提示文本，待会儿我们可以直接看到。以及，调用函数 `secret_phase` 开启隐藏关。

##### 7.2.2 开启隐藏关

运行到 Phase 4 时，在 gdb 中输入修改后的字符串：

```text
7 0 DrEvil
```

继续跑完全部 6 个关卡，输出信息：

```text
Curses, you've found the secret phase!
But finding it and solving it are quite different...
```

##### 7.2.3 观察函数 `secret_phase`

在 `bomb.asm` 中找到函数 `secret_phase` 对应的汇编语句：

```text
0000000000401242 <secret_phase>:
  401242:   53                      push   %rbx
  401243:   e8 56 02 00 00          callq  40149e <read_line>
  401248:   ba 0a 00 00 00          mov    $0xa,%edx
  40124d:   be 00 00 00 00          mov    $0x0,%esi
  401252:   48 89 c7                mov    %rax,%rdi
  401255:   e8 76 f9 ff ff          callq  400bd0 <strtol@plt>
  40125a:   48 89 c3                mov    %rax,%rbx
  40125d:   8d 40 ff                lea    -0x1(%rax),%eax
  401260:   3d e8 03 00 00          cmp    $0x3e8,%eax
  401265:   76 05                   jbe    40126c <secret_phase+0x2a>
  401267:   e8 ce 01 00 00          callq  40143a <explode_bomb>
  40126c:   89 de                   mov    %ebx,%esi
  40126e:   bf f0 30 60 00          mov    $0x6030f0,%edi
  401273:   e8 8c ff ff ff          callq  401204 <fun7>
  401278:   83 f8 02                cmp    $0x2,%eax
  40127b:   74 05                   je     401282 <secret_phase+0x40>
  40127d:   e8 b8 01 00 00          callq  40143a <explode_bomb>
  401282:   bf 38 24 40 00          mov    $0x402438,%edi
  401287:   e8 84 f8 ff ff          callq  400b10 <puts@plt>
  40128c:   e8 33 03 00 00          callq  4015c4 <phase_defused>
  401291:   5b                      pop    %rbx
  401292:   c3                      retq
  401293:   90                      nop
  401294:   90                      nop
  401295:   90                      nop
  401296:   90                      nop
  401297:   90                      nop
  401298:   90                      nop
  401299:   90                      nop
  40129a:   90                      nop
  40129b:   90                      nop
  40129c:   90                      nop
  40129d:   90                      nop
  40129e:   90                      nop
  40129f:   90                      nop
```

`401243`: `callq 40149e <read_line>` 调用函数 `read_line`，其返回值（即输入的一行字符串 `str`）保存在 `%rax` 寄存器。

{{< admonition note 寄存器状态 >}}
`%rax` = `str`
{{< /admonition >}}

`401248`: `mov $0xa,%edx` 和 `40124d`: `mov $0x0,%esi` 将 `%edx` 和 `%esi` 寄存器分别设置为 `10` 和 `0`。

{{< admonition note 寄存器状态 >}}
`%esi` = `0`  
`%edx` = `10`
{{< /admonition >}}

`400e37`: `mov %rax,%rdi` 将 `%rax` 寄存器保存的地址传给了 `%rdi` 寄存器。

{{< admonition note 寄存器状态 >}}
`%rdi` = `%rax` = `str`
{{< /admonition >}}

`401255`: `callq 400bd0 <strtol@plt>` 调用系统函数 `strtol`。可以推测出这个函数的作用是将字符串转化为整数，但我对它的参数用法不是很了解。查阅资料得，传入的第 1 个参数 `%rdi` 是被用来解析的字符串的地址 `str`，第 2 个参数 `%esi` 是字符串中需要解析部分的结束地址（这里我们传入的是 `NULL`，表示不使用这个参数），第 3 个参数 `%edx` 是这个整数的底数（这里我们传入的是 `10`，表示采用十进制）[^strtol]。最后函数返回值保存在 `%rax` 寄存器中。

总之，这部分的作用就是读入一个多位的整数。

{{< admonition note 寄存器状态 >}}
`%rax` = `num`
{{< /admonition >}}

其中，`num` 表示输入的字符串解析得到的多位整数。

`400e37`: `mov %rax,%rbx` 和 `40125d`: `lea -0x1(%rax),%eax` 将 `%rax` 的值传给了 `%rbx` 寄存器，然后 `%rax` 的值减 1。

{{< admonition note 寄存器状态 >}}
`%rbx` = `%rax` = `num`  
`%eax` = `%rax - 1` = `num - 1`
{{< /admonition >}}

`401260`: `cmp $0x3e8,%eax` 和 `401265`: `jbe 40126c <secret_phase+0x2a>` 判断 `%eax` 的值是否不超过 `0x3e8`，是则直接跳到 `40126c`: `mov %ebx,%esi`，否则执行 `40143a`: `callq 40143a <explode_bomb>` 引爆炸弹。

因此，输入的整数应当不超过 `1001`（无符号数）。

`40126c`: `mov %ebx,%esi` 和 `40126e`: `mov $0x6030f0,%edi` 将 `%ebx` 的值传给了 `%esi` 寄存器，将地址 `0x6030f0` 传给了 `%edi` 寄存器。

{{< admonition note 寄存器状态 >}}
`%edi` = `0x6030f0`  
`%esi` = `%ebx` = `num`
{{< /admonition >}}

`401273`: `callq 401204 <fun7>` 调用函数 `fun7`，也就是本关的主体部分。

`401278`: `cmp $0x2,%eax` 和 `40127b`: `je 401282 <secret_phase+0x40>` 判断函数 `fun7` 的返回值是否为 `2`，是则直接跳到 `401282`: `mov $0x402438,%edi`，否则执行 `40143a`: `callq 40143a <explode_bomb>` 引爆炸弹。

因此，函数 `fun7` 的返回值应当为 `2`。

之后就是输出一行提示文本，以及一些收尾工作。

[^strtol]: [strtol - C++ Reference](http://www.cplusplus.com/reference/cstdlib/strtol)

##### 7.2.4 观察函数 `fun7`

在 `bomb.asm` 中找到函数 `fun7` 对应的汇编语句：

```text
0000000000401204 <fun7>:
  401204:   48 83 ec 08             sub    $0x8,%rsp
  401208:   48 85 ff                test   %rdi,%rdi
  40120b:   74 2b                   je     401238 <fun7+0x34>
  40120d:   8b 17                   mov    (%rdi),%edx
  40120f:   39 f2                   cmp    %esi,%edx
  401211:   7e 0d                   jle    401220 <fun7+0x1c>
  401213:   48 8b 7f 08             mov    0x8(%rdi),%rdi
  401217:   e8 e8 ff ff ff          callq  401204 <fun7>
  40121c:   01 c0                   add    %eax,%eax
  40121e:   eb 1d                   jmp    40123d <fun7+0x39>
  401220:   b8 00 00 00 00          mov    $0x0,%eax
  401225:   39 f2                   cmp    %esi,%edx
  401227:   74 14                   je     40123d <fun7+0x39>
  401229:   48 8b 7f 10             mov    0x10(%rdi),%rdi
  40122d:   e8 d2 ff ff ff          callq  401204 <fun7>
  401232:   8d 44 00 01             lea    0x1(%rax,%rax,1),%eax
  401236:   eb 05                   jmp    40123d <fun7+0x39>
  401238:   b8 ff ff ff ff          mov    $0xffffffff,%eax
  40123d:   48 83 c4 08             add    $0x8,%rsp
  401241:   c3                      retq
```

`401217` 和 `40122d`: `callq 401204 <fun7>` 都调用了函数 `fun7` 自身，可见这是一个递归函数。

试译成 C 语言代码：

```c
// p_node in %rdi, target in %esi
int fun7(int* p_node, int target) {
    if (p_node == 0)
        return 0xffffffff;
    cur_num = *p_node;                          // cur_num in %edx
    if (cur_num > target) {
        p_node = *(p_node + 1);
        result = fun7(p_node, target);          // result in %eax
        return result * 2;
    } else if (cur_num == target) {
        return 0;
    } else {                                    // cur_num < target
        result = 0;
        p_node = *(p_node + 2);
        result = fun7(p_node, target);
        return result * 2 + 1;
    }
}
```

如此这个递归函数的作用就很清晰了。

##### 7.2.5 确定输入的整数

接下来，使用 gdb 查看作为参数传入的地址 `0x6030f0` 开始的连续内存中的值（经试验可知第 60 个 8 bytes 之后的地址中存放的都是无关数据，因此这里只需显示前 60 个地址）：

```text
x/60xg 0x6030f0
```

输出信息：

```text
0x6030f0 <n1>:   0x0000000000000024      0x0000000000603110
0x603100 <n1+16>:        0x0000000000603130       0x0000000000000000
0x603110 <n21>:  0x0000000000000008      0x0000000000603190
0x603120 <n21+16>:       0x0000000000603150       0x0000000000000000
0x603130 <n22>:  0x0000000000000032      0x0000000000603170
0x603140 <n22+16>:       0x00000000006031b0       0x0000000000000000
0x603150 <n32>:  0x0000000000000016      0x0000000000603270
0x603160 <n32+16>:       0x0000000000603230       0x0000000000000000
0x603170 <n33>:  0x000000000000002d      0x00000000006031d0
0x603180 <n33+16>:       0x0000000000603290       0x0000000000000000
0x603190 <n31>:  0x0000000000000006      0x00000000006031f0
0x6031a0 <n31+16>:       0x0000000000603250       0x0000000000000000
0x6031b0 <n34>:  0x000000000000006b      0x0000000000603210
0x6031c0 <n34+16>:       0x00000000006032b0       0x0000000000000000
0x6031d0 <n45>:  0x0000000000000028      0x0000000000000000
0x6031e0 <n45+16>:       0x0000000000000000       0x0000000000000000
0x6031f0 <n41>:  0x0000000000000001      0x0000000000000000
0x603200 <n41+16>:       0x0000000000000000       0x0000000000000000
0x603210 <n47>:  0x0000000000000063      0x0000000000000000
0x603220 <n47+16>:       0x0000000000000000       0x0000000000000000
0x603230 <n44>:  0x0000000000000023      0x0000000000000000
0x603240 <n44+16>:       0x0000000000000000       0x0000000000000000
0x603250 <n42>:  0x0000000000000007      0x0000000000000000
0x603260 <n42+16>:       0x0000000000000000       0x0000000000000000
0x603270 <n43>:  0x0000000000000014      0x0000000000000000
0x603280 <n43+16>:       0x0000000000000000       0x0000000000000000
0x603290 <n46>:  0x000000000000002f      0x0000000000000000
0x6032a0 <n46+16>:       0x0000000000000000       0x0000000000000000
0x6032b0 <n48>:  0x00000000000003e9      0x0000000000000000
0x6032c0 <n48+16>:       0x0000000000000000       0x0000000000000000
```

结合 [7.2.4](#724-观察函数-fun7) 节译出的函数 `fun7` 代码，可以发现这是一个二叉树。二叉树中每个结点是一个结构体，结点所在的地址指向的是数据 `val`，加上 `0x8` 后指向的是指针 `left`，加上 `0x10` 后指向的是指针 `right`。

因此，`fun7` 函数中的 `*p_node` 即 `p_node->val`，`*(p_node + 1)` 即 `p_node->left`，`*(p_node + 2)` 即 `p_node->right`。

根据之前 gdb 的输出信息绘制二叉树（数据已转化为十进制）：

{{< mermaid >}}
graph TB
    A((36))
    A --> B((8))
    A --> C((50))
    B --> D((6))
    B --> E((22))
    C --> F((45))
    C --> G((107))
    D --> H((1))
    D --> I((7))
    E --> J((20))
    E --> K((35))
    F --> L((40))
    F --> M((47))
    G --> N((99))
    G --> O((1001))
{{< /mermaid >}}

可以发现这其实是一个 BST（Binary Search Tree，二叉查找树），而函数 `fun7` 的作用为：

1. 如果当前结点为 `NULL`，则返回 `0xffffffff`（直接爆了）；
2. 如果找到了 `target`，则返回 `0`；
3. 如果当前结点的值大于 `target`，则继续搜索左子树，返回时将左子树的返回值 `* 2`；
4. 如果当前结点的值小于 `target`，则继续搜索右子树，返回时将右子树的返回值 `* 2 + 1`。

起始时从根结点 `36` 开始查找，现在问题转化为：求 `target` 为何值时，最终的返回值为 `2`。

由之前的分析，返回值为 `2` 的条件为：

1. 最终找到 `target` 的值（`return 0`），此后可以沿右路返回任意次（`return 0`）；
2. 然后沿左路返回（`return 1`）；
3. 最后沿右路返回（`return 2`）。

满足条件的结点的值有 2 个：`22`, `20`，即为所求。

于是得到本关的 2 个解：`22`, `20`。

##### 7.2.6 测试

这里以 `22` 为例，在 gdb 中输入 Secret Phase 的密码：

```text
22
```

输出信息：

```text
Wow! You've defused the secret stage!
Congratulations! You've defused the bomb!
```

## 运行结果

```bash
./bomb
```

{{< image src="assets/bomb.webp" caption="bomb 运行结果" >}}

## 测试环境

- Ubuntu 18.04.3 LTS (GNU/Linux 5.0.0-31-generic x86_64)
- GDB 8.1.0

## 心得体会

我并没有使用 IDA Pro 反汇编工具，报告里出现的所有 C 语言代码都是我逐行阅读汇编代码、慢慢人工整理得到的，也没有参考任何网上的文章。不得不说这着实让我对汇编的理解与熟悉程度上了一个台阶。实验过程虽然漫长，但也挺有趣的，CMU 能设计出这样一套寓教于乐的 Lab 真的很有水平。

事实上，通关本身很容易，但我希望能写出一份即使是完全没学过汇编的人也能够看懂并理解的实验报告，至少我一年后再看还能明白我当时在做些什么，因此篇幅很长，还望能理解。
