---
title: "数据结构 - Project 1: 有序数组还原 解题报告"
date: 2019-11-25T00:22:00+08:00

tags: [数据结构, 排序]
categories: [note]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/77359441.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

Data Structure (H) @ Fudan University, fall 2019.

<!--more-->

{{< admonition info 封面出处 >}}
[内緒 - @MISSILE228](https://www.pixiv.net/artworks/77359441)
{{< /admonition >}}

## 题目简介

{{< admonition info 参见 >}}
[zyr17 / DataStructure2019-PJ1: 2019 秋季数据结构 PJ1 - GitHub](https://github.com/zyr17/DataStructure2019-PJ1)
{{< /admonition >}}

{{< admonition quote >}}

数组 $a$ 有 $n$ 个元素 $a[1]$, $a[2]$, …, $a[n]$.

数组有序，即 $a[1] < a[2] < a[3] < … < a[n−1] < a[n]$.

现在由于故障，进行了至多 $k$ 次「交换」，即 $a[x]$ 和 $a[y]$ 内的元素互换了（$1\le x\le y\le n$），然而并没有日志记录这些交换。

我们可以通过两个操作尝试把数组还原（重新有序）：

- $\textrm{ask}(p,q)$，表示询问 $a[p]$ 和 $a[q]$ 哪个元素比较大（$p\ne q$）
- $\textrm{swap}(p,q)$，表示交换 $a[p]$ 和 $a[q]$ 中的元素

显然，先进行足够的 $\textrm{ask}$ 操作，再进行足够的 $\textrm{swap}$ 操作是最佳策略之一。

{{< /admonition >}}

### 评分标准

{{< admonition quote >}}

每个数据的得分由 Solver 执行 $\textrm{ask}$ 的次数决定，执行 $\textrm{ask}$ 的次数越少得分越高。

**出现以下情况会导致程序得分为零分：**

1. 经过所有 Solver 给出的 $\textrm{swap}$ 操作后，数组并没有恢复有序；
2. $\textrm{swap}$ 操作数超过 $k$（$k$ 是误交换的次数）；
3. 输出数据出现格式错误，如数字范围不对、输出无关内容等导致 Judger 报错或无法正常运行；
4. 交互过程总运行时间超过 **10** 秒；
5. 程序进行 $\textrm{ask}$ 操作次数超过 **500,000** 次。

{{< /admonition >}}

### 限制

{{< admonition quote >}}

规模：$n\le 10000$, $k\le 100$

数据分布：

- 50% - $k$ 次误交换纯随机
- 50% - $k$ 次误交换以某些方法构造

时间限制：10 秒（C++ 50,000 次 $\textrm{ask}$ 交互耗时约 1 秒）

不允许使用任何第三方库和任何公开代码。对于 STL 库，只允许使用以下给定的库：

- `assert.h`, `ctype.h`, `limits.h`, `math.h`, `stdbool.h`, `stdint.h`, `stdio.h`, `stdlib.h`, `string.h`, `time.h`
- `iostream`, `string`, `limits`, `utility`, `random`, `ratio`, `tuple`

{{< /admonition >}}

## 解题报告

由于无从得知「构造数据」的构造方式（比如完全可以直接用某些随机数据当构造数据，所以本质是一回事），因此我提交的 `solver_random.cpp`（对应随机）和 `solver_special.cpp`（对应构造）的代码完全相同。

每段代码的具体作用在注释里其实已经有解释，报告里主要讲一下思路。

完整代码在第 [5](#5-完整代码) 节，其中附有「字多不看」版的总体思路概述。

### 1 尽量只对错误数据排序

当误交换的次数 $k$ 远小于数组规模 $n$ 时，数组基本有序，错误数据一般是离散的。例如 $k=2$, $n=20$ 时原数组可能是这样：

```text
1 2 3 18 5 6 7 8 9 14 11 12 13 10 15 16 17 4 19 20
```

因此我们只需找到错误数据 `18`, `14`, `10`, `4`，仅对它们所在的 4 个位置进行一次排序即可还原数组，而无需对整个数组进行排序。

但这只是理想情况，事实上我们仅能知道任意两个数之间的大小关系。在这种情况下如何仅仅确定错误数据的位置，同时又保证比较次数尽量少，很遗憾，我并没能找到好的方法。

于是退而求其次，我们使用以下方式确定「可能错误」的数据的位置：

首先遍历一遍数组，得到所有相邻两个数之间的大小关系。当存在相邻两个数使得前者大于后者时，则这两个数中至少有一个是错误的。例如：

```text
1 < 2 < 6 > 4 < 5 > 3 < 7
```

可见，其中 `6` 和 `3` 就是错误数据。但由于我们并不能判断 $>$ 号左右两个数具体哪一个是错误的，因此这里就直接将这两个数都标记为「可能错误」的数据，也就是 `6`, `4` 和 `5`, `3`。

在代码实现中，先仅保存较小的数的位置，我们称其为一个 `breakpoint`。

```cpp
// A breakpoint is set if the current number is smaller than its predecessor.
int InitBreakpoint(int* breakpoint, int* array) {
    int size = 0;
    for (int i = 2; i <= array_size; ++i) {
        if (!Compare(array[i - 1], array[i])) breakpoint[size++] = i;
    }
    return size;
}
```

这里函数 `Compare` 的返回值即前者是否小于后者。然后我们将这些 `breakpoint` 及它们前面的位置设置为 `fault`，表示「可能错误」的数据的位置。

```cpp
// Breakpoints and their predecessors are considered faulty.
int InitFault(int* fault, int* breakpoint, int breakpoint_size) {
    int size = 0;
    for (int i = 0; i < breakpoint_size; ++i) {
        if (!size || fault[size - 1] != breakpoint[i] - 1) {
            fault[size++] = breakpoint[i] - 1;
        }
        fault[size++] = breakpoint[i];
    }
    return size;
}
```

之后我们对 `array` 中 `fault` 所标记的位置进行归并排序。理论上，如果所有错误数据都是离散的（互不相邻），则一次操作即可将原数组还原。事实上，当 $k$ 很小时，这往往是对的。

```cpp
void Merge(int* array, int* pos_array, int low, int mid, int high) {
    int  size  = high - low + 1;
    int* temp  = new int[size];
    int  left  = low;
    int  right = mid;
    int  i     = 0;
    while (left < mid && right < high) {
        temp[i++] = Compare(array[pos_array[left]], array[pos_array[right]]) ?
                        array[pos_array[left++]] :
                        array[pos_array[right++]];
    }
    while (left < mid) temp[i++] = array[pos_array[left++]];
    while (right < high) temp[i++] = array[pos_array[right++]];
    for (i = low; i < high; ++i) array[pos_array[i]] = temp[i - low];
    delete[] temp;
}

// Merge sort an array at the selected positions given in 'pos_array'.
void MergeSort(int* array, int* pos_array, int low, int high) {
    if (low >= high - 1) return;
    int mid = low + ((high - low) >> 1);
    MergeSort(array, pos_array, low, mid);
    MergeSort(array, pos_array, mid, high);
    Merge(array, pos_array, low, mid, high);
}
```

### 2 错误数据不完全离散的解决办法

然而，我们并不能确保错误数据是完全离散的。一旦存在两个错误数据是相邻的，上述方案就失效了。例如：

```text
1 < 2 < 3 < 6 > 4 < 5 < 7
```

上述算法认为，「可能错误」的数据仅有 `6`, `4`，于是排序后的数组为：

```text
1 2 3 4 6 5 7
```

可见并没有正确排序，因此我们需要对这个算法做一些修正。

本来我想了一些修正方案，但最后发现——其实只要反复进行上述操作就可以了。

好吧。

```cpp
int* breakpoint      = new int[array_size + 1];
int  breakpoint_size = InitBreakpoint(breakpoint, array);

int* fault      = new int[array_size + 1];
int  fault_size = 0;

while (breakpoint_size) {
    fault_size = InitFault(fault, breakpoint, breakpoint_size);
    MergeSort(array, fault, 0, fault_size);
    breakpoint_size = InitBreakpoint(breakpoint, array);
}
```

### 3 一些优化

核心算法到此结束，剩下就是一些优化了。

#### 3.1 缓存机制

为了避免重复进行 $\textrm{ask}$ 操作，有必要建立一套缓存机制，也就是将询问过的结果保存在一个缓存矩阵里，此后如果重复询问就直接返回缓存中的结果。

```cpp
// 'compare_matrix' is a cache for ask(), i.e. compare_matrix[i][j] stores the
// result of ask(i, j). When i < j, ask(i, j) returns 1, otherwise return 0.
static int** compare_matrix = nullptr;

void Insert(int index1, int index2, int result) {
    compare_matrix[index1][index2] = result;
    compare_matrix[index2][index1] = !result;
}

bool Compare(int index1, int index2) {
    int result = compare_matrix[index1][index2];
    if (result != -1) return result;  // a cache hit occurs

    cout << index1 << ' ' << index2 << '\n';
    cin >> result;  // result = ask(index1, index2)
    Insert(index1, index2, result);

    return result;
}
```

其中 `compare_matrix` 就是缓存矩阵，初始值为全 $-1$。

##### 3.1.1 对缓存的优化

因为我们只关心询问次数，而不关心时间复杂度，所以这里采用了用时间换询问次数的暴力优化。为了防止 TLE，设定只有当数组规模 $n$ 不超过 $5000$ 时才进行下述的第 1 个优化。[^tle-note]

1. 对于未命中缓存的询问 $\textrm{ask}(x,y)$，固定 $x$，遍历缓存中所有 $\textrm{ask}(x,z)$，如果 $\textrm{ask}(x,z) = \textrm{ask}(z,y) = 1$，则 $ask(x,y) = 1$，加入缓存，不询问（均为 $0$ 的情况同理，下同）。
2. 对于询问 $\textrm{ask}(x,y)$ 所得结果，固定 $y$，遍历缓存中所有 $\textrm{ask}(y,z)$，如果 $\textrm{ask}(y,z) = \textrm{ask}(x,y) = 1$，则 $\textrm{ask}(x,z) = 1$，加入缓存；固定 $x$，遍历缓存中所有 $\textrm{ask}(z,x)$，如果 $\textrm{ask}(z,x) = \textrm{ask}(x,y) = 1$，则 $\textrm{ask}(z,y) = 1$，加入缓存。
3. 初次遍历时不进行上述优化，先检测数组是否已经有序，是则直接下一步，否则进行优化，以防止 TLE。这是因为对于已经有序的数组，整个缓存矩阵都将被填满。

这些优化本质上就是利用了 $<$ 和 $>$ 的传递性。可惜 CPU 不能做复杂的并行计算，否则直接做矩阵运算效果会更好。

```cpp
// 'compare_matrix' is a cache for ask(), i.e. compare_matrix[i][j] stores the
// result of ask(i, j). When i < j, ask(i, j) returns 1, otherwise return 0.
static int** compare_matrix = nullptr;

// available columns for each row in compare_matrix
static int** row_col      = nullptr;
static int*  row_col_size = nullptr;
// available rows for each column in compare_matrix
static int** col_row      = nullptr;
static int*  col_row_size = nullptr;

inline void InsertRowCol(int index1, int index2) {
    row_col[index1][row_col_size[index1]++] = index2;
}

inline void InsertColRow(int index1, int index2) {
    col_row[index1][col_row_size[index1]++] = index2;
}

void Insert(int index1, int index2, int result) {
    if (compare_matrix[index1][index2] != -1) return;
    InsertRowCol(index1, index2);
    InsertRowCol(index2, index1);
    InsertColRow(index1, index2);
    InsertColRow(index2, index1);
    compare_matrix[index1][index2] = result;
    compare_matrix[index2][index1] = !result;
}

bool Compare(int  index1,
             int  index2,
             bool optimize_only = false,
             bool easy_compare  = false) {
    int result = compare_matrix[index1][index2];
    if (result != -1 && !optimize_only) return result;  // a cache hit occurs

    if (!big_data && !easy_compare) {
        for (int i = 0; i < row_col_size[index1]; ++i) {
            int index3        = row_col[index1][i];
            int result_first  = compare_matrix[index1][index3];
            int result_second = compare_matrix[index3][index2];
            if (result_first != -1 && result_first == result_second) {
                // If x < y and y < z, then x < z.
                Insert(index1, index2, result_first);
                return result_first;
            }
        }
    }

    if (!optimize_only) {
        cout << index1 << ' ' << index2 << '\n';
        cin >> result;  // result = ask(index1, index2)
        Insert(index1, index2, result);
    }

    if (!easy_compare) {
        for (int i = 0; i < row_col_size[index2]; ++i) {
            int index3 = row_col[index2][i];
            if (compare_matrix[index2][index3] == result)
                Insert(index1, index3, result);
        }
        for (int i = 0; i < col_row_size[index1]; ++i) {
            int index3 = col_row[index1][i];
            if (compare_matrix[index3][index1] == result)
                Insert(index3, index2, result);
        }
    }

    return result;
}
```

其中参数 `optimize_only` 表示是否只优化不询问，参数 `easy_compare` 表示是否只询问不优化。

[^tle-note]: 其实按理来说规模 $10000$ 的数组也不应该 TLE，但在线评测机反馈说 TLE 了，我也没什么办法。

#### 3.2 特殊情况处理

##### 3.2.1 逆序数组

当数组初次遍历所得 `breakpoint` 个数超过 $n/2 + 1$ 时，将数组逆序。如此 `breakpoint` 个数总归可以变少，从而减少询问次数。最好情况下如果原数组就是逆序数组，询问次数就是 $n-1$。

```cpp
int* breakpoint      = new int[array_size + 1];
int  breakpoint_size = InitBreakpoint(breakpoint, array, false, true);
if (breakpoint_size > (array_size >> 1) + 1) {
    Reverse(array, 1, array_size + 1);  // to reduce 'breakpoint_size'
    breakpoint_size = InitBreakpoint(breakpoint, array, false, true);
}
```

其中函数 `Reverse` 就是将数组逆序。

##### 3.2.2 小规模乱序数组

当 $n$ 很小但 $k$ 很大（接近 $n$）时，数组几乎完全乱序，此时上述算法的询问次数甚至比直接归并排序还多。

这里设定当初次遍历（之前先进行 [3.2.1](#321-逆序数组) 节的操作）所得 `breakpoint` 的个数超过 $n/3$ 时，直接进行归并排序。

```cpp
if (breakpoint_size > array_size / 3) chaos = true;
if (breakpoint_size) InitBreakpoint(breakpoint, array, true);

int* fault      = new int[array_size + 1];
int  fault_size = 0;

if (!chaos) {
    while (breakpoint_size) {
        fault_size = InitFault(fault, breakpoint, breakpoint_size);
        MergeSort(array, fault, 0, fault_size);
        breakpoint_size = InitBreakpoint(breakpoint, array);
    }
} else {
    int* all_pos = new int[array_size + 1];
    for (int i = 1; i <= array_size; ++i) all_pos[i] = i;
    MergeSort(array, all_pos, 1, array_size + 1);
    delete[] all_pos;
}
cout << "0 0" << '\n';  // end of ask()
```

### 4 其他琐碎的解释

算法主体和优化讲完了，剩下就是一些 trivial 的代码解释。

#### 4.1 如何统计交换次数

先生成一个表示数组索引的数组 `array`，之后对这个索引数组进行排序（排序时根据 $\textrm{ask}(\textrm{array}[i],\textrm{array}[j])$ 的结果决定 $i$ 和 $j$ 哪个在前面），最后会得到一个「乱序」的索引数组，当然实际上这些索引所对应的原数组已经有序了。例如：

```text
1 2 3 4 5       // the index array
1 3 5 2 4       // the original array
```

```text
// After sorting the index array
1 4 2 5 3       // the index array
1 2 3 4 5       // the original array
```

```cpp
int* array = new int[array_size + 1];
for (int i = 1; i <= array_size; ++i) array[i] = i;
// ...
```

然后我们将这个「乱序」的索引数组还原成有序，排序期间保存所做的所有交换。可见，这些交换就是我们需要的 $\textrm{swap}$ 操作，且总次数一定不会超过 $k$。

```cpp
auto swaps      = new pair<int, int>[kMaxSize];
int  swap_count = 0;
for (int i = 1; i <= array_size; ++i) {
    while (array[i] != i) {
        swaps[swap_count++] = make_pair(array[i], array[array[i]]);
        Swap(array[i], array[array[i]]);
    }
}
cout << swap_count << '\n';
for (int i = 0; i < swap_count; ++i)
    cout << swaps[i].first << ' ' << swaps[i].second << '\n';

int result;
cin >> result;  // as the Judger requires
```

其中 `kMaxSize` 就只是个大常数，函数 `Swap` 就是交换两个数，`result` 是 Judger 要求读入的总询问次数。

#### 4.2 其他之前未提及的代码

```cpp
compare_matrix = new int*[array_size + 1];
row_col        = new int*[array_size + 1];
col_row        = new int*[array_size + 1];
row_col_size   = new int[array_size + 1];
col_row_size   = new int[array_size + 1];
for (int i = 0; i <= array_size; ++i) {
    compare_matrix[i] = new int[array_size + 1];
    for (int j = 0; j <= array_size; ++j)
        compare_matrix[i][j] = -1;  // -1 as unset
    row_col[i]      = new int[array_size + 1];
    col_row[i]      = new int[array_size + 1];
    row_col_size[i] = 0;
    col_row_size[i] = 0;
}

// ...

for (int i = 0; i <= array_size; ++i) delete[] compare_matrix[i];
delete[] swaps;
delete[] fault;
delete[] breakpoint;
delete[] col_row_size;
delete[] row_col_size;
delete[] col_row;
delete[] row_col;
delete[] compare_matrix;
delete[] array;
```

前半段就单纯初始化，后半段就单纯释放内存。

### 5 完整代码

```cpp
#include <iostream>
#include <utility>

using std::cin;
using std::cout;
using std::make_pair;
using std::pair;

// 'kMaxSize' is the capacity of the array 'swaps' (should be larger than 100 as
// k <= 100, where k is the maximum count of swaps)
static const int kMaxSize = 233;

// If the size of an array is larger than 'kThreshold', it'll be treated as a
// large array, and therefore different methods will be applied.
static const int kThreshold = 5000;

// 'compare_matrix' is a cache for ask(), i.e. compare_matrix[i][j] stores the
// result of ask(i, j). When i < j, ask(i, j) returns 1, otherwise return 0.
static int** compare_matrix = nullptr;

// available columns for each row in compare_matrix
static int** row_col      = nullptr;
static int*  row_col_size = nullptr;
// available rows for each column in compare_matrix
static int** col_row      = nullptr;
static int*  col_row_size = nullptr;

static int  array_size = 0;      // the size of the array
static bool big_data   = false;  // true if the array is a large array
static bool chaos      = false;  // true if the array is too disordered

inline void Swap(int& x1, int& x2) {
    int temp = x1;
    x1       = x2;
    x2       = temp;
}

void Reverse(int* array, int begin, int end) {
    int half_len = (end - begin) >> 1;
    for (int i = 0; i < half_len; ++i)
        Swap(array[begin + i], array[end - i - 1]);
}

void Print(int* array, int start, int end) {
    for (int i = start; i < end; ++i) cout << array[i] << ' ';
    cout << '\n';
}

inline void InsertRowCol(int index1, int index2) {
    row_col[index1][row_col_size[index1]++] = index2;
}

inline void InsertColRow(int index1, int index2) {
    col_row[index1][col_row_size[index1]++] = index2;
}

void Insert(int index1, int index2, int result) {
    if (compare_matrix[index1][index2] != -1) return;
    InsertRowCol(index1, index2);
    InsertRowCol(index2, index1);
    InsertColRow(index1, index2);
    InsertColRow(index2, index1);
    compare_matrix[index1][index2] = result;
    compare_matrix[index2][index1] = !result;
}

bool Compare(int  index1,
             int  index2,
             bool optimize_only = false,
             bool easy_compare  = false) {
    int result = compare_matrix[index1][index2];
    if (result != -1 && !optimize_only) return result;  // a cache hit occurs

    if (!big_data && !easy_compare) {
        for (int i = 0; i < row_col_size[index1]; ++i) {
            int index3        = row_col[index1][i];
            int result_first  = compare_matrix[index1][index3];
            int result_second = compare_matrix[index3][index2];
            if (result_first != -1 && result_first == result_second) {
                // If x < y and y < z, then x < z.
                Insert(index1, index2, result_first);
                return result_first;
            }
        }
    }

    if (!optimize_only) {
        cout << index1 << ' ' << index2 << '\n';
        cin >> result;  // result = ask(index1, index2)
        Insert(index1, index2, result);
    }

    if (!easy_compare) {
        for (int i = 0; i < row_col_size[index2]; ++i) {
            int index3 = row_col[index2][i];
            if (compare_matrix[index2][index3] == result)
                Insert(index1, index3, result);
        }
        for (int i = 0; i < col_row_size[index1]; ++i) {
            int index3 = col_row[index1][i];
            if (compare_matrix[index3][index1] == result)
                Insert(index3, index2, result);
        }
    }

    return result;
}

void Merge(int* array, int* pos_array, int low, int mid, int high) {
    int  size  = high - low + 1;
    int* temp  = new int[size];
    int  left  = low;
    int  right = mid;
    int  i     = 0;
    while (left < mid && right < high) {
        temp[i++] = Compare(array[pos_array[left]], array[pos_array[right]]) ?
                        array[pos_array[left++]] :
                        array[pos_array[right++]];
    }
    while (left < mid) temp[i++] = array[pos_array[left++]];
    while (right < high) temp[i++] = array[pos_array[right++]];
    for (i = low; i < high; ++i) array[pos_array[i]] = temp[i - low];
    delete[] temp;
}

// Merge sort an array at the selected positions given in 'pos_array'.
void MergeSort(int* array, int* pos_array, int low, int high) {
    if (low >= high - 1) return;
    int mid = low + ((high - low) >> 1);
    MergeSort(array, pos_array, low, mid);
    MergeSort(array, pos_array, mid, high);
    Merge(array, pos_array, low, mid, high);
}

// A breakpoint is set if the current number is smaller than its predecessor.
int InitBreakpoint(int* breakpoint,
                   int* array,
                   bool optimize_only = false,
                   bool easy_compare  = false) {
    int size = 0;
    for (int i = 2; i <= array_size; ++i) {
        if (!Compare(array[i - 1], array[i], optimize_only, easy_compare))
            breakpoint[size++] = i;
    }
    return size;
}

// Breakpoints and their predecessors are considered faulty.
int InitFault(int* fault, int* breakpoint, int breakpoint_size) {
    int size = 0;
    for (int i = 0; i < breakpoint_size; ++i) {
        if (!size || fault[size - 1] != breakpoint[i] - 1) {
            fault[size++] = breakpoint[i] - 1;
        }
        fault[size++] = breakpoint[i];
    }
    return size;
}

int main() {
    std::ios::sync_with_stdio(false);
    cin >> array_size;
    if (array_size > kThreshold) big_data = true;
    int* array = new int[array_size + 1];
    for (int i = 1; i <= array_size; ++i) array[i] = i;

    compare_matrix = new int*[array_size + 1];
    row_col        = new int*[array_size + 1];
    col_row        = new int*[array_size + 1];
    row_col_size   = new int[array_size + 1];
    col_row_size   = new int[array_size + 1];
    for (int i = 0; i <= array_size; ++i) {
        compare_matrix[i] = new int[array_size + 1];
        for (int j = 0; j <= array_size; ++j)
            compare_matrix[i][j] = -1;  // -1 as unset
        row_col[i]      = new int[array_size + 1];
        col_row[i]      = new int[array_size + 1];
        row_col_size[i] = 0;
        col_row_size[i] = 0;
    }

    int* breakpoint      = new int[array_size + 1];
    int  breakpoint_size = InitBreakpoint(breakpoint, array, false, true);
    if (breakpoint_size > (array_size >> 1) + 1) {
        Reverse(array, 1, array_size + 1);  // to reduce 'breakpoint_size'
        breakpoint_size = InitBreakpoint(breakpoint, array, false, true);
    }
    if (breakpoint_size > array_size / 3) chaos = true;
    if (breakpoint_size) InitBreakpoint(breakpoint, array, true);

    int* fault      = new int[array_size + 1];
    int  fault_size = 0;

    if (!chaos) {
        while (breakpoint_size) {
            fault_size = InitFault(fault, breakpoint, breakpoint_size);
            MergeSort(array, fault, 0, fault_size);
            breakpoint_size = InitBreakpoint(breakpoint, array);
        }
    } else {
        int* all_pos = new int[array_size + 1];
        for (int i = 1; i <= array_size; ++i) all_pos[i] = i;
        MergeSort(array, all_pos, 1, array_size + 1);
        delete[] all_pos;
    }
    cout << "0 0" << '\n';  // end of ask()

    auto swaps      = new pair<int, int>[kMaxSize];
    int  swap_count = 0;
    for (int i = 1; i <= array_size; ++i) {
        while (array[i] != i) {
            swaps[swap_count++] = make_pair(array[i], array[array[i]]);
            Swap(array[i], array[array[i]]);
        }
    }
    cout << swap_count << '\n';
    for (int i = 0; i < swap_count; ++i)
        cout << swaps[i].first << ' ' << swaps[i].second << '\n';

    int result;
    cin >> result;  // as the Judger requires

    for (int i = 0; i <= array_size; ++i) delete[] compare_matrix[i];
    delete[] swaps;
    delete[] fault;
    delete[] breakpoint;
    delete[] col_row_size;
    delete[] row_col_size;
    delete[] col_row;
    delete[] row_col;
    delete[] compare_matrix;
    delete[] array;
}
```

#### 5.1 总体思路概述

字多不看，也行。

1. 生成一个表示数组索引的数组 `array`，之后对这个索引数组进行排序（详见 [4.1](#41-如何统计交换次数) 节）。
2. 初始化一个缓存矩阵 `compare_matrix`，保存所有询问过的 $\textrm{ask}$ 结果（详见 [3.1](#31-缓存机制) 节）。每次询问前先扫描一遍缓存，看看能不能根据现有的缓存推导出当前 $\textrm{ask}$ 的结果。询问后再扫描一遍缓存，把能通过这次 $\textrm{ask}$ 的结果推导出的结果缓存起来（详见 [3.1.1](#311-对缓存的优化) 节）。
3. 遍历询问一遍数组，当发现存在相邻两个数使得前者大于后者时，将较小的数保存在数组 `breakpoint` 中。
4. 一些优化，当 `breakpoint` 的个数超过 $n/2 + 1$ 时（其中 $n$ 为数组规模），将数组逆序。此后当 `breakpoint` 的个数超过 $n/3$ 时，直接进行归并排序（详见 [3.2](#32-特殊情况处理) 节）。
5. 如果 `breakpoint` 的个数为 $0$，则直接跳到操作 9（数组已经有序），否则循环执行操作 5 ~ 8。
6. 通过数组 `breakpoint` 生成数组 `fault`，其中保存了所有 `breakpoint` 以及它们的前一个位置，表示「可能错误」的数据位置。
7. 对 `array` 中 `fault` 所标记的位置进行归并排序（以上详见 [1](#1-尽量只对错误数据排序) 节）。
8. 重复操作 3，检查数组是否有序。
9. 询问结束，开始交换流程。将「乱序」的索引数组还原成有序，排序期间保存所做的所有交换。最后输出这些交换，作为所需的 $\textrm{swap}$ 操作（详见 [4.1](#41-如何统计交换次数) 节）。

### 6 性能分析

#### 6.1 算法优势

- 不依赖随机数，询问次数稳定，耗时稳定。
- 对有序数组和完全逆序数组只需 $n-1$ 次询问。
- 对于绝大多数 $k\ll n$ 的**随机**数据，有很低的询问次数。通常情况下，询问复杂度大约在 $\mathcal{O}(n + 4k\log(4k) - 6k)$。
- 对于 $k\approx n$ 的数据，最坏情况下（当 $k=n$ 时）询问复杂度也还在 $\mathcal{O}(n\log n - n)$。

#### 6.2 算法劣势

- 对于基本有序数组，连续的有序段越长，时间复杂度越高（主要在建立缓存时）。
