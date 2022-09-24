---
title: "算法 - Project: DNA 测序错误检测 - Task 1: 无噪音整段比对"
date: 2021-05-16T18:00:00+08:00

tags: [算法, 编辑距离, Myers, 差分算法, C++]
categories: [note]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/90380296.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

Algorithms (H) @ Fudan University, spring 2021.

<!--more-->

{{< admonition info 封面出处 >}}
[大渓谷 - @藤原](https://www.pixiv.net/artworks/90380296)
{{< /admonition >}}

{{< admonition success 源码地址 >}}
[:(fab fa-github):  hakula139 / dna-error-detection at task-1-sv-chain](https://github.com/hakula139/dna-error-detection/tree/task-1-sv-chain)
{{< /admonition >}}

## 题目简介

{{< admonition info 参见 >}}
[hakula139 / dna-error-detection / docs / README.pdf - GitHub](https://github.com/hakula139/dna-error-detection/blob/master/docs/README.pdf)
{{< /admonition >}}

## 解题报告

### 1 解题思路

本题的本质其实就是找出两个字符串的最小编辑距离，因此很容易联想到用于找出最长公共子序列（Longest Common Subsequence, LCS）的动态规划解法，这部分详见 [`src/utils/utils.cpp`][utils.cpp:27] 中函数 `FuzzyCompare` 的部分实现。

然而，朴素动态规划解法的时间复杂度和空间复杂度均为 $O(mn)$，其中 $m,n$ 表示两个字符串的长度。对于题目中 $m,n\approx 10^6$ 的规模来说，未免还是太大了。因此我的第一个思路是，将原字符串分成一个个片段，然后对每个片段逐一进行比较。这里片段的大小可以通过修改配置文件 [`src/utils/config.cpp`][config.cpp:6] 中的 `chunk_size` 字段进行调整。如此，时间复杂度和空间复杂度均降到了 $O(k\max\\{m,n\\})$，其中 $k$ 表示片段的长度。当 $k$ 较小时，可以有效减少时间的开销。

当然，朴素动态规划解法还是有点慢了。本解法最后实现的核心算法是基于贪心算法的 Myers 差分算法（Myers' Diff Algorithm），时间复杂度和空间复杂度均为 $O(d(m+n))$，其中 $d$ 表示两个字符串之间的编辑距离。本题中两个字符串大体是相同的，差别数量最多只有 $50\times 1000\times 2 = 10^5$ 量级，当然实际要比这个更少。在进行了分段优化后，期望时间复杂度和空间复杂度降到了 $O(dk)$。具体代码可参见 [`src/common/dna.cpp`][dna.cpp:89] 中函数 `Dna::FindDeltasChunk` 的实现，对 Myers 差分算法的详解可以参考 [这篇文章][myers]。

Myers 差分算法最终可以找到原字符串 $\textrm{ref}$ 基础上所有的缺失片段和插入片段，接下来我们要考虑的是如何将它们转化为题目中要求的 SV 类型。

#### 1.1 INS - 片段插入

在 Myers 差分算法中，我们会维护当前处理的字符所在的位置 $(x,y)$。其中 $x$ 表示字符在原字符串 $\textrm{ref}$ 中的位置，$y$ 表示字符在修改字符串 $\textrm{sv}$ 中的位置。我们记录节点在图中经过的路径[^lcs]，其中沿 $x$ 轴向右移动表示删除字符，沿 $y$ 轴向下移动表示插入字符，沿对角线向右下移动表示不作修改，跳到下一个字符。

因此，将所有向下移动路径的起点和终点保存下来，即可作为 INS 类型的 SV 片段。

然而，在实现中会遇到一个问题。由于很多时候插入 / 删除的片段中会包含和后续字符相同的字符，因此 Myers 差分算法得到的路径往往是不连续的，即新增几个字符，跳过几个字符，又新增几个字符。这并不符合题目中 SV 片段长度 $l\in [50,1000]$ 的要求。

这里我们的解决方案分为两部分：

首先，我们修改了 Myers 差分算法中的部分逻辑。当节点沿着对角线向右下方移动结束（即跳过所有相同的字符）后，立即对 snake 的长度进行一次判定。其中，snake 表示节点沿对角线移动的距离。如果 snake 的长度小于 `snake_min_len`（可在配置文件中调整），即连续的相同字符数量没有超过设定的阈值，则将节点移回对角线的起点，本轮不跳过字符。如此即可防止出现频繁的抖动，确保 SV 片段基本上是完整的片段。参见 [`src/common/dna.cpp:148`][dna.cpp:148]。

其次，我们在保存 SV 片段时进行一次判定。如果此前保存的同类型 SV 片段中包含与当前片段大致重叠或邻近的片段，那么我们就将这两个片段合并（当然，对于过长的邻近片段不会进行合并）。如此即可确保不会出现 SV 片段的碎片。参见 [`src/common/dna_delta.cpp`][dna_delta.cpp:61] 中函数 `DnaDelta::Combine` 和 `DnaMultiDelta::Combine` 的实现。

这样一来，我们能够基本保证 INS 类型 SV 片段的正确性。

#### 1.2 DEL - 片段缺失

基本同 INS 类型，区别在于 INS 类型保存向下移动的路径，DEL 类型则保存向右移动的路径。

#### 1.3 DUP - 片段串联重复

在得到了所有 INS 和 DEL 类型 SV 片段的基础上，我们从中识别出剩下 3 种 SV 类型。

对于 DUP 类型，我们遍历所有的 INS 类型片段 $[s,t)$，比较此插入片段 $\textrm{sv}[s'...t')$（已预先保存）与其插入位置前面的原字符串片段 $\textrm{ref}[2s-t...s)$ 是否大致相同。如果是，则将此片段的类型修改为 DUP 类型。参见 [`src/common/dna.cpp`][dna.cpp:240] 中函数 `Dna::FindDupDeltas` 的实现。

关于两个字符串的比较，我们进行两种判定：

1. 找出**最长公共子串**（Longest Common Substring）的长度，计算其覆盖率。
2. 找出**最长公共子序列**（Longest Common Subsequence）的长度，计算其覆盖率。

其中任意一个判定达到标准，即认为两个字符串大致相同，具体可参见 [`src/utils/utils.cpp`][utils.cpp:27] 中函数 `FuzzyCompare` 的实现。这样可以尽可能应对 SV 片段重叠、SV 片段少量出错或未知等问题，提高算法的健壮性。

#### 1.4 INV - 染色体倒位

对于 INV 类型，我们遍历同染色体下的所有 INS 和 DEL 类型片段，找出其中大致相邻且大小大致相同的 INS 和 DEL 类型片段，将其中 INS 类型片段的位置修改为与 DEL 类型片段对齐（只是为了和要求的输出格式相符），然后对其代表的字符串进行比较。字符串的比较方式同 DUP 类型，区别在于其中一个字符串要进行反向互补操作，即先反转，再逐位将 `A`, `T` 互换、`C`, `G` 互换。如果字符串基本匹配，则移除对应的 INS 和 DEL 类型片段，新增一个 INV 类型片段。参见 [`src/common/dna.cpp`][dna.cpp:257] 中函数 `Dna::FindInvDeltas` 的实现。

#### 1.5 TRA - 染色体间异位

TRA 类型与 INV 类型类似，我们遍历所有染色体的 INS 和 DEL 类型片段，找出每条染色体中大致相邻且大小大致相同的片段，分别放入一个 INS / DEL 缓存，然后移除。接下来我们遍历 INS 和 DEL 缓存，找出其中大致相邻且大小大致相同的 INS 和 DEL 类型片段，然后对其代表的字符串进行比较。字符串的比较方式同 DUP 类型。如果字符串基本匹配，则新增一个 TRA 类型片段。最后将未匹配的缓存中的片段放回原处。参见 [`src/common/dna.cpp`][dna.cpp:299] 中函数 `Dna::FindTraDeltas` 的实现。

### 2 运行代码

本项目使用 C++17 编写，环境要求：

- GCC 7.0 或以上 / Clang 5.0 或以上
- GNU Make 4.0 或以上

构建项目并启动算法程序[^cc]：

```bash
make && make run
```

使用 Task 1 测试数据生成的结果位于 `tests/test_1/sv.bed`。

### 3 测试环境

- macOS Catalina 10.15.7
- Clang 12.0.0
- GNU Make 4.1

## 参考资料

1. [Investigating Myers' diff algorithm: Part 1 of 2 - CodeProject][myers]

[utils.cpp:27]: https://github.com/hakula139/dna-error-detection/blob/task-1-sv-chain/src/utils/utils.cpp#L27
[config.cpp:6]: https://github.com/hakula139/dna-error-detection/blob/task-1-sv-chain/src/utils/config.cpp#L6
[dna.cpp:89]: https://github.com/hakula139/dna-error-detection/blob/task-1-sv-chain/src/common/dna.cpp#L89
[dna.cpp:148]: https://github.com/hakula139/dna-error-detection/blob/task-1-sv-chain/src/common/dna.cpp#L148
[dna.cpp:240]: https://github.com/hakula139/dna-error-detection/blob/task-1-sv-chain/src/common/dna.cpp#L240
[dna.cpp:257]: https://github.com/hakula139/dna-error-detection/blob/task-1-sv-chain/src/common/dna.cpp#L257
[dna.cpp:299]:https://github.com/hakula139/dna-error-detection/blob/task-1-sv-chain/src/common/dna.cpp#L299
[dna_delta.cpp:61]: https://github.com/hakula139/dna-error-detection/blob/task-1-sv-chain/src/common/dna_delta.cpp#L61
[makefile:14]: https://github.com/hakula139/dna-error-detection/blob/task-1-sv-chain/Makefile#L14
[myers]: https://www.codeproject.com/Articles/42279/Investigating-Myers-diff-algorithm-Part-1-of-2

[^lcs]: 最长公共子序列（LCS）并不唯一，我们只保存找到的第一条。实现中，需要在每次发生编辑操作（节点移动到了其他 k-line 上）时保存当前 LCS 的快照，用于在最后进行回溯，这也是空间复杂度 $O(d(m+n))$ 的来源。
[^cc]: 默认使用 clang++ 作为编译器，如需改动，可以在 [Makefile][makefile:14] 文件中进行修改。
