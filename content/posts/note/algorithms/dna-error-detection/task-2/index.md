---
title: "算法 - Project: DNA 测序错误检测 - Task 2: 有噪音分段比对"
date: 2021-06-28T23:59:00+08:00

tags: [算法, 模糊匹配, C++]
categories: [note]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/3/article-covers/bedbbd30-894e-407d-8a7f-02a665b60bdf_89979147.webp
license: CC BY-NC-SA 4.0
---

Algorithms (H) @ Fudan University, spring 2021.

<!--more-->

{{< admonition info 封面出处 >}}
[夕凪 - @mocha](https://www.pixiv.net/artworks/89979147)
{{< /admonition >}}

{{< admonition success 源码地址 >}}
[:(fab fa-github):  hakula139 / dna-error-detection at task-2-segments](https://github.com/hakula139/dna-error-detection/tree/task-2-segments)
{{< /admonition >}}

## 题目简介

{{< admonition info 参见 >}}
[hakula139 / dna-error-detection / docs / README.pdf - GitHub](https://github.com/hakula139/dna-error-detection/blob/master/docs/README.pdf)
{{< /admonition >}}

## 解题报告

### 1 解题思路

在 Task 1 的基础上，本题的主要难点分为两部分：

1. 如何将 `long.fasta` 中的 $\textrm{read}$ 片段快速匹配到参考字符串 $\textrm{ref}$ 上。
2. 如何在 $\textrm{read}$ 片段平均 $15\\%$ 的噪音干扰下，准确找到 SV 片段。

这里我们参考了 [Minimap2][minimap2] 的论文思路，根据实际情况进行了简化和调整。算法核心分为以下三个步骤：

1. 对参考字符串 $\textrm{ref}$ 利用最小哈希建立索引。
2. 利用 $\textrm{ref}$ 的索引，将 $\textrm{read}$ 片段匹配到 $\textrm{ref}$ 上的对应区域。
3. 比较 $\textrm{read}$ 片段和 $\textrm{ref}$ 上匹配到的区域，查找 SV 片段。

#### 1.1 建立索引

由于噪音和 SV 片段的存在，我们无法简单地在 $\textrm{ref}$ 字符串中直接查找一个 $\textrm{read}$ 子字符串片段，因此我们需要建立索引。

如何对参考字符串 $\textrm{ref}$ 建立索引？简单来说，就是将 $\textrm{ref}$ 中每个长度为 $k$（即 `HASH_SIZE`，默认为 $15$，所有参数均可在配置文件 [`src/utils/config.cpp`][config.cpp] 中调整）的子字符串，利用一个哈希函数转换成一个整数。具体来说，我们利用一个 2 位二进制整数来表示一个 DNA 碱基：$\mathtt{00}$ 表示 $\textrm{A}$、$\mathtt{01}$ 表示 $\textrm{T}$、$\mathtt{10}$ 表示 $\textrm{C}$、$\mathtt{11}$ 表示 $\textrm{G}$。对于一条 DNA 链，其哈希值就是将所有碱基的二进制数表示连接起来，例如 $\textrm{GCTA}$ 的哈希值就是 $\mathtt{11100100}$。通过这种方式，我们可以将每个连续的 $k$ 位子字符串转换成一个 $2k$ 位二进制数作为其哈希值 $\textrm{hash}$。我们称这样一个从 $\textrm{hash}$ 到这个子字符串在 $\textrm{ref}$ 中位置 $[i,i+k)$ 的映射为一个 $\textrm{k-mer}$。

对于一条长度为 $N$ 的 DNA 链，就包含了 $N-k+1$ 个这样的 $\textrm{k-mer}$。为了减少 $\textrm{k-mer}$ 的数量，以减少使用的内存空间，我们维护一个长度为 $w$（即 `WINDOW_SIZE`，默认为 $10$）的滑动窗口，只有滑动窗口中哈希值最小的 $\textrm{k-mer}$ 才会被保存作为索引。

具体代码可参见 [`src/common/dna.cpp`][dna.cpp:187] 中函数 `Dna::CreateIndex` 的实现。为了方便重复使用，我们提供了函数 `Dna::PrintIndex` 用于将索引导出成文件，以及函数 `Dna::ImportIndex` 用于从文件中读取索引。

#### 1.2 字符串片段的模糊匹配

##### 1.2.1 生成 minimizer

建立完索引后，我们就可以在每个 $\textrm{read}$ 片段中遍历所有长度为 $k$ 的子字符串，根据其哈希值查找是否有相同哈希值的 $\textrm{k-mer}$。同时，我们对于 $\textrm{read}$ 片段的反向互补序列 $\textrm{read'}$ 也进行同样的操作。对于每个找到的 $\textrm{k-mer}$，我们保存一个这样的结构：$\\{\textrm{range}\_\textrm{ref},\ \textrm{key}\_\textrm{read},\ \textrm{range}\_\textrm{read}\\}$，我们称其为一个 $\textrm{minimizer}$。其中，$\textrm{range}\_\textrm{ref}$ 表示 $\textrm{k-mer}$ 映射到 $\textrm{ref}$ 上的位置 $[i,i+k)$，$\textrm{key}\_\textrm{read}$ 表示 $\textrm{read}$ 的编号（例如 $\textrm{S1}\_1$），$\textrm{range}\_\textrm{read}$ 表示这个子字符串在 $\textrm{read}$（或 $\textrm{read'}$）上的位置 $[j,j+k)$。同时，在每个 $\textrm{range}$ 中还额外保存了一个原字符串（$\textrm{ref}$ 或 $\textrm{read}$）的指针，用于之后读取及合并这个子字符串的值。在 $\textrm{range}\_\textrm{read}$ 中还额外保存了 `mode` 字段和 `unknown` 字段，分别用于指示当前 $\textrm{read}$ 的模式（是否是反向互补序列），以及是否包含一定数量的未知字符 $\textrm{N}$（在合并时用于提高效率，不关键）。

随后，我们根据 $\textrm{read}$ 和 $\textrm{read'}$ 片段上 $\textrm{minimizer}$ 的数量决定是否对 $\textrm{read}$ 进行反向互补操作。即如果 $\textrm{read'}$ 上的 $\textrm{minimizer}$ 较多，则进行反向互补操作，反之则不进行。

具体代码可参见 [`src/common/dna.cpp`][dna.cpp:250] 中函数 `Dna::FindOverlaps` 的实现。同时，我们提供了函数 `Dna::PrintOverlaps` 用于将 $\textrm{minimizer}$ 导出成文件，以及函数 `Dna::ImportOverlaps` 用于从文件中读取 $\textrm{minimizer}$。

##### 1.2.2 合并 minimizer

生成 $\textrm{minimizer}$ 后，我们需要对它们进行过滤及合并。其中，过滤指的是将错误匹配的 $\textrm{minimizer}$ 移除，合并指的是将两个 $\textrm{minimizer}$ 根据其 $\textrm{range}\_\textrm{ref}$ 的范围 $[i\_1,i\_1+k)$ 和 $[i\_2,i\_2+k)$ 进行合并。

具体来说，在与一个聚类合并时，对于每一个 $\textrm{minimizer}$，我们比较此次合并后 $\textrm{range}\_\textrm{ref}$ 和 $\textrm{range}\_\textrm{read}$ 表示范围的增量 $\Delta\_\textrm{ref}$ 和 $\Delta\_\textrm{read}$。如果它们的差距不大，则将这个 $\textrm{minimizer}$ 归并到当前聚类，同时此聚类的计数器加 $1$。反之则尝试合并到下一个聚类，如果没有可合并的聚类，则将其单独分到一个新的聚类。

合并后，新的 $\textrm{minimizer}$ 的 $\textrm{range}\_\textrm{ref}$ 为 $[\min\\{i\_1,i\_2\\\},\ \max\\{i\_1,i\_2\\\}+k)$，$\textrm{key}\_\textrm{read}$ 为空字符串，$\textrm{range}\_\textrm{read}$ 为 $[0,l)$，其中 $l$ 为合并后新生成的 $\textrm{read}$ 字符串的长度，同时 $\textrm{range}\_\textrm{read}$ 中保存的指针指向这个新字符串。

于是，我们就得到了若干 $\textrm{minimizer}$ 聚类。我们将其中计数器值较小或者范围较小的 $\textrm{minimizer}$ 过滤。

具体代码可参见 [`src/common/dna_overlap.cpp`][dna_overlap.cpp:44] 中函数 `DnaOverlap::Merge` 的实现。

##### 1.2.3 匹配 ref 链和 sv 链

由于 `long.fasta` 中同时包含了多条 $\textrm{sv}$ 链的采样，我们需要从中找到与 $\textrm{ref}$ 链匹配的 $\textrm{sv}$ 链。这里我们根据 $\textrm{minimizer}$ 在 $\textrm{ref}$ 上的覆盖率，选择覆盖率最高的 $\textrm{sv}$ 链与 $\textrm{ref}$ 链相匹配。

在 [`src/utils/config.cpp`][config.cpp] 中调整 `LOG_LEVEL` 为 `DEBUG`，即可在日志 `logs/output.log` 中看到 $\textrm{minimizer}$ 的覆盖率（搜索 `cover rate`）。对于本题的正式数据，我们的覆盖率分别达到了：

- `NC_010513.1`: $99.01\\%$ ($\textrm{S1}$)
- `NC_014752.1`: $98.07\\%$ ($\textrm{S2}$)
- `NC_017999.1`: $99.05\\%$ ($\textrm{S3}$)

具体代码可参见 [`src/common/dna_overlap.cpp`][dna_overlap.cpp:116] 中函数 `DnaOverlap::SelectChain` 和 `DnaOverlap::CheckCoverage` 的实现。

#### 1.3 查找 SV 片段

最终，我们将问题化归到了类似于 Task 1 的情形。根据每个 $\textrm{minimizer}$ 中保存的 $\textrm{range}\_\textrm{ref}$ 和 $\textrm{range}\_\textrm{read}$，我们可以得到两个需要比较的字符串，接下来只需复用函数 `Dna::FindDeltasChunk` 的逻辑即可。

但是，由于 Task 2 的数据含有一定量的噪声，原先对 Task 1 的数据处理方式不再适用于 Task 2，我们需要重新研究如何处理通过 `Dna::FindDeltasChunk` 函数得到的 SV。

具体来说，由于噪声的存在，SV 变得更加零散，同时我们难以区分一个 SV 是真正的 SV 还是噪声。我尝试过利用 SV 的间隔来判断一个 SV 是否是噪声，也尝试过魔改 Myers 差分算法来消除部分噪声，但效果都不理想。最后经过助教的提示，我调整了方案，使用一定范围内 SV 的密度来估计 SV 可能存在的范围。这是因为如果是纯噪声，SV 的密度大约会在 $15\\%$ 左右，而对于真实的 SV，其密度往往在 $50\\%$ 以上。通过观察 SV 密度的变化，就有可能判断 SV 的位置。参见 [`src/common/dna_delta.cpp`][dna_delta.cpp:125] 中函数 `DnaDelta::GetDensity` 的实现。

具体代码可参见 [`src/common/dna.cpp`][dna.cpp:368] 中函数 `Dna::FindDeltasFromSegments` 的实现。

接下来就是调参的工作了，在配置文件 [`src/utils/config.cpp`][config.cpp] 中有大量可以调整的参数，其中比较重要的参数有 `SIGNAL_RATE`, `DENSITY_WINDOW_SIZE`, `DELTA_MIN_LEN`, `SNAKE_MIN_LEN`, `GAP_MIN_DIFF` 等。由于时间关系，没有很多时间用来调参了，因此最终的实验结果尚不理想。

### 2 运行代码

本项目使用 C++17 编写，环境要求：

- GCC 9.0 或以上
- GNU Make 4.0 或以上

可用的 Make 指令如下：

- `make`：构建项目[^cc]
- `make help`：显示参数及其用法
- `make run`：完整启动算法程序
- `make index`：只创建 $\textrm{ref}$ 的索引
- `make minimizer`：只生成 $\textrm{minimizer}$
- `make start`：只查找 SV 片段
- `make clean`：清理构建文件

使用 Task 2 测试数据生成的结果位于 `tests/test_2/sv.bed`。

### 3 测试环境

- Ubuntu 18.04.5 LTS (WSL2 5.4.72-microsoft-standard)
- GCC 10.3.0
- GNU Make 4.1

## 参考资料

1. [Heng Li. Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics, 34, 18, 2018: 3094-3100.][minimap2]

[minimap2]: https://doi.org/10.1093/bioinformatics/bty191
[config.cpp]: https://github.com/hakula139/dna-error-detection/blob/task-2-segments/src/utils/config.cpp
[dna.cpp:187]: https://github.com/hakula139/dna-error-detection/blob/task-2-segments/src/common/dna.cpp#L187
[dna.cpp:250]: https://github.com/hakula139/dna-error-detection/blob/task-2-segments/src/common/dna.cpp#L250
[dna.cpp:368]: https://github.com/hakula139/dna-error-detection/blob/task-2-segments/src/common/dna.cpp#L368
[dna_overlap.cpp:44]: https://github.com/hakula139/dna-error-detection/blob/task-2-segments/src/common/dna_overlap.cpp#L44
[dna_overlap.cpp:116]: https://github.com/hakula139/dna-error-detection/blob/task-2-segments/src/common/dna_overlap.cpp#L116
[dna_delta.cpp:125]: https://github.com/hakula139/dna-error-detection/blob/task-2-segments/src/common/dna_delta.cpp#L125
[makefile:20]: https://github.com/hakula139/dna-error-detection/blob/task-2-segments/Makefile#L20

[^cc]: 默认使用 g++ 作为编译器，如需改动，可以在 [Makefile][makefile:20] 文件中进行修改。
