---
title: "Woogle: 一个基于倒排索引的简易搜索引擎"
date: 2021-12-17T16:45:00+08:00

tags: [分布式系统, 倒排索引, Hadoop, MapReduce, Java]
categories: [project]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/3/article-covers/3d6d0550-1b2f-4bfd-88bc-5766baf4f688_94278235.webp
license: CC BY-NC-SA 4.0
---

本项目利用 Hadoop MapReduce，构建了对 Wikipedia 语料库的倒排索引，并实现了一个简易的搜索引擎，可根据检索的关键词返回相应的索引信息，使用 Java 编写。

Distributed Systems (H) @ Fudan University, fall 2021.

<!--more-->

{{< admonition info 封面出处 >}}
[雨で垂れるネオン街 - @輪廻（りんね）](https://www.pixiv.net/artworks/94278235)
{{< /admonition >}}

{{< admonition success 源码地址 >}}
[:(fab fa-github):  hakula139 / woogle](https://github.com/hakula139/woogle)
{{< /admonition >}}

## 1 任务说明与描述

{{< admonition info 参见 >}}
[Hadoop 平台使用及 PJ 要求 - 腾讯文档](https://docs.qq.com/doc/DUnJVS0R6dURQU0lB)
{{< /admonition >}}

在服务器上的 `/corpus/wiki` 目录下有 `0, 1, ..., 63.txt` 等 64 个文本文件，每个文件大小约为 300 MB，其内容格式为分行、无标点的英文文本，示例如下：

```text
lorem ipsum dolor sit amet consectetur adipisicing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam quis nostrud exercitation 
ullamco laboris nisi ut aliquip ex ea commodo consequat Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore 
eu fugiat nulla pariatur Excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum 
...
```

使用这些语料数据，计算文档中每个词的 TF-IDF（每个文件视为一个文档），要求实现以下功能：

1. 为每个出现的词构建索引，包括所属文档、出现次数、TF、IDF 信息。
2. 在上一步的基础上，包括此词在文档中出现的位置。
3. 支持关键词检索。实现程序，输入词后，程序输出这个词的索引。

## 2 参与人员任务分工说明

- [**Hakula Chen**](https://github.com/hakula139)：独立完成全部功能，实现了对语料库倒排索引的构建，实现了基于索引的关键词搜索功能。

## 3 程序启动与操作说明

### 3.1 开发

本项目使用 IntelliJ IDEA 开发，相关构建、运行、打包配置已经写在了 `.idea` 目录下的配置文件里，直接在 IDE 里执行相应的任务即可：

- `index`：构建 package `xyz.hakula.index`，并执行其主类 `xyz.hakula.index.Driver` 的 `main()` 函数，传入参数 `input`, `output`, `temp`。这个包的功能是构建目录 `input` 下所有文件的倒排索引，索引结果保存在目录 `output` 下，执行过程中产生的临时数据放置在目录 `temp` 下。
- `woogle`：构建 package `xyz.hakula.woogle`，并执行其主类 `xyz.hakula.woogle.Woogle` 的 `main()` 函数，传入参数 `output`。这个包的功能是根据用户输入的关键词，在目录 `output` 下的索引里进行检索，最后输出这个关键词的倒排索引。
- `index_jar`：将上述 package `xyz.hakula.index` 打包为 JAR 包 `index.jar`，保存在目录 `jar` 下，之后同任务 `index` 一样执行。
- `woogle_jar`：将上述 package `xyz.hakula.woogle` 打包为 JAR 包 `woogle.jar`，保存在目录 `jar` 下，之后同任务 `woogle` 一样执行。

当然也可以通过 IDE 的构建选项只构建不执行，这里不作赘述。

原项目基于 Java SE 17 开发，为了兼容服务器的 Java SE 8 环境，在主分支 `master` 外维护了一个 `dev-jdk-1.8` 分支，提供了基于 Java 8 版本的实现，同时提供了配套的 IDE 配置文件。

### 3.2 启动

项目已经预先打包好了 `index.jar` 和 `woogle.jar` 文件，可以直接使用。

对于 `index.jar` 文件，如果希望在本机上使用，则执行以下命令（需提前配置好 Java 环境）：

```bash
java -jar index.jar <input_path> <output_path> <temp_path>
```

其中，`<input_path>`, `<output_path>`, `<temp_path>` 分别表示指定的输入路径（语料库位置）、输出路径（索引位置）和缓存路径（临时文件位置）。需要注意的是，如果 `<output_path>`、`<temp_path>/output_job1` 和 `<temp_path>/output_job2` 中的某些在程序运行前已经存在，则程序会跳过部分任务的执行（具体跳过了什么、为什么跳过将在 [之后](#52-driver) 展开阐述）。因此如果你需要重新执行全部任务，则需要将这些目录手动移除。

如果希望在 Hadoop 集群上使用，则执行以下命令（需提前配置好 Hadoop 环境）：

```bash
hadoop jar index.jar <input_path> <output_path> <temp_path>
```

对于 `woogle.jar` 文件，类似地执行以下命令：

```bash
hadoop jar woogle.jar <index_path>
```

其中，`<index_path>` 表示指定的索引位置，通常也就是前面传入 `index.jar` 的 `<output_path>`。

### 3.3 执行结果

#### 3.3.1 索引格式

执行 `index.jar` 后，我们将在输出路径 `<output_path>` 下得到我们的索引文件，格式如下（文件名：`part-r-xxxxx`）：

```text
<token>	<filename>:<token_count>:<tf>:<position_1>;...;<position_n>
<token>	<filename>:<token_count>:<tf>:<position_1>;...;<position_n>
<token>	<filename>:<token_count>:<tf>:<position_1>;...;<position_n>
<token>	$<file_count>:<idf>
```

其中：

- `<token>`：表示一个短语 $t$。
- `<filename>`：表示出现这个短语 $t$ 的文档 $d$ 的文件名。
- `<token_count>`：表示这个短语 $t$ 在文档 $d$ 中出现的次数 $c_{t,d}$。
- `<tf>`：表示这个短语 $t$ 在文档 $d$ 中的**词频 TF** (Term Frequency)，使用科学计数法表示。这里我们采用的算法是 $$\operatorname{TF}(t,d) = \frac{c_{t,d}}{C_d}$$ 其中 $C_d$ 表示文档 $d$ 中的短语总数。
- `<position_i>`：表示这个短语 $t$ 在文档 $d$ 中出现的位置 $p_{t,d,i}$。这里我们取的是该短语首字符关于文档起始位置的**字节偏移量**。
- `<file_count>`：表示出现这个短语 $t$ 的文档总数 $n_t$。
- `<idf>`：表示这个短语 $t$ 在所有文档 $D$ 中的**逆向文件频率 IDF** (Inverse Document Frequency)。这里我们采用的算法是 $$\operatorname{IDF}(t) = \log_2{\frac{N}{n_t}}$$ 其中 $N$ 表示语料库中文档的总数 $|D|$。

以一个小样例的索引结果为例（文件名：`part-r-00121`）：

```text
limited	03.txt:1:1.436782e-03:3280
limited	$1:1.584962500721156
reluctant	02.txt:1:8.605852e-04:4369
reluctant	$1:1.584962500721156
rents	01.txt:1:1.390821e-03:3242
rents	$1:1.584962500721156
their	02.txt:1:8.605852e-04:153
their	03.txt:2:2.873563e-03:1045;1141
their	$2:0.5849625007211562
```

注意到同一个 `<token>` 在不同文档里的 TF 和 IDF 都被分成了不同的行，而不是合并在同一行里，[之后](#553-reducer) 会解释原因。

索引过程中产生的日志文件会保存在 `logs/app.log` 文件里（文件名随日期滚动）。

#### 3.3.2 搜索结果格式

执行 `woogle.jar` 后，程序会提示用户输入一个关键词：

```text
Please input a keyword:
>
```

输入关键词并回车后，程序将输出这个关键词的搜索结果，其格式如下：

```text
<token>: IDF = <idf> | found in <file_count> files:
  <filename>: TF = <tf> (<token_count> times) | TF-IDF = <tfidf> | positions: <position> <position> ...
  ...
```

其中：

- `<tfidf>`：表示这个短语 $t$ 在文档 $d$ 中的 TF-IDF，使用科学计数法表示。这里我们采用的算法是 $$\operatorname{TFIDF}(t,d) = \operatorname{TF}(t,d) \cdot \operatorname{IDF}(t)$$ 通常，这个值可以作为这个文档在搜索结果中的权重。

例如：

```text
> their
their: IDF = 0.584963 | found in 2 files:
  02.txt: TF = 8.605852e-04 (1 time) | TF-IDF = 5.034101e-04 | positions: 153
  03.txt: TF = 2.873563e-03 (2 times) | TF-IDF = 1.680927e-03 | positions: 1045 1141
```

如果没有找到，程序则会输出：

```text
> aaaa
aaaa: not found
```

## 4 程序文件 / 类功能说明

这里重点讲项目的核心代码部分，一些诸如 `log4j.properties` 之类的配置文件就略过了。

- `src/main/java/`：项目源代码。
  - `xyz/hakula/index/`：package `xyz.hakula.index`，倒排索引构建功能的实现。
    - `io/`：一些自定义 Writable 类型的定义，令 MapReduce 的 key 和 value 可以使用自定义类型。在使接口和实现更清晰可读、易于维护的同时，也节省了每次 `join` 成 `String` 再 `split` 回来的性能开销。
    - `Driver.java`：索引程序的主类，配置了所有的 Job，然后依次执行。
    - `TokenPosition.java`：第 1 个 Job，读取目录 `<input_path>` 里的文件，提取所有短语在各文件中出现的位置，保存在路径 `<temp_path>/output_job1` 下。
    - `TokenCount.java`：第 2 个 Job，读取目录 `<temp_path>/output_job1` 里的文件，统计所有短语在各文件中出现的次数，保存在路径 `<temp_path>/output_job2` 下，同时统计各文件的短语总数，保存在路径 `<temp_path>/file_token_count` 下对应的文件名（`<filename>`）里。
    - `InvertedIndex.java`：第 3 个 Job，从路径 `<temp_path>/file_token_count` 里按需读取各文件的短语总数到内存中，然后读取目录 `<temp_path>/output_job2` 里的文件，计算所有短语在各文件中的 TF 及 IDF，保存在路径 `<output_path>` 下。
  - `xyz/hakula/woogle/`：package `xyz.hakula.woogle`，倒排索引检索功能的实现。
    - `model/`：一些自定义类型的定义，类似于 package `xyz.hakula.index` 下 `io/` 里的类，提供了解析索引的方法。
    - `Woogle.java`：检索程序的主类，从终端读取用户输入，定位到对应的索引文件进行查询，然后格式化输出到终端。

## 5 架构以及模块实现方法说明

### 5.1 总览

项目的整体架构分为 3 个 MapReduce Job。一般来说，关注程序的输入和输出是一个理清脉络的好方法。

#### 5.1.1 Job 1 概览

开始时，输入数据的格式如下：

```text
<token> <token> <token> <token> <token> <token> <token> <token>
```

这里每个 `<token>` 就代表了一个短语。

首先这些数据经过 Job 1 - token position 的 Mapper，输出所有短语在各文件中出现的位置，格式如下：

```text
<token>@<filename>	<position>
```

其中，Tab 的左右侧分别是 key 和 value。这里每行的 `<position>` 只有 1 个。

然后这些数据经过 Job 1 的 Reducer，将同文件下相同短语（也就是 key 相同）的位置聚合了起来，输出所有短语在各文件中出现的位置数组，格式如下：

```text
<token>@<filename>	<position>;<position>;<position>
```

或者表示成：

```text
<token>@<filename>	[<position>]
```

至此 Job 1 结束，所有结果保存在目录 `<temp_path>/output_job1` 下的文件里。为了节省 Job 间原始数据和 `String` 之间互相转换的开销，这里我们直接顺序输出二进制格式的数据（`SequenceFileOutputFormat`），因此直接打开文件是无法阅读的。

#### 5.1.2 Job 2 概览

接下来这些数据经过 Job 2 - token count 的 Mapper，将 key 里的 `<token>` 字段移到 value 里，以便后续可以对 `<filename>` 聚合处理，格式如下：

```text
<filename>	<token>:[<position>]
```

然后这些数据经过 Job 2 的 Reducer，对于每个文件，统计各短语在其中出现的次数，并交换 `<token>` 和 `<filename>` 字段的位置，为 Job 3 做准备，格式如下：

```text
<token>	<filename>:<token_count>:0:[<position>]
```

这里这个 `0` 是 TF 的占位符，目前还无法计算（[之后](#543-reducer) 会讲为什么），因此先留空。

与此同时，我们对文件里所有短语的出现次数求和，从而得到文件的短语总数，格式如下：

```text
<total_count>
```

至此 Job 2 结束，所有结果保存在目录 `<temp_path>/output_job2` 下的文件里，每个文件的短语总数保存在文件 `<temp_path>/file_token_count/<filename>` 里。

#### 5.1.3 Job 3 概览

接下来这些数据经过 Job 3 - inverted index 的 Mapper，根据文件 `<temp_path>/file_token_count/<filename>` 里保存的文件短语总数，计算得到 TF，替换掉原来的占位符，格式如下：

```text
<token>	<filename>:<token_count>:<tf>:[<position>]
```

最后这些数据经过 Job 3 的 Reducer，对于每个短语，聚合在这里的 TF 条目总数就是出现了这个短语的文件总数。然后根据预先在外侧（`xyz.hakula.index.Driver`）统计的文件总数，计算得到每个短语的 IDF。输出时，先输出所有的 TF 条目，然后输出 IDF 条目，并在 IDF 条目 value 的开头添加 `$` 前缀作为标记。格式如下：

```text
<token>	<filename>:<token_count>:<tf>:[<position>]
<token>	$<file_count>:<idf>
```

至此 Job 3 结束，索引结果的 TF 部分保存在目录 `<output_path>` 下的文件里，IDF 部分保存在文件 `<output_path>/inverse_document_freq/<token>` 里。

下面我们来看看具体的实现。

### 5.2 Driver

首先是索引程序的主类 `Driver`，也就是整个程序的入口。以下是基于 Java SE 17 的实现：

```java
// src/main/java/xyz/hakula/index/Driver.java

public class Driver extends Configured implements Tool {
  public static final int NUM_REDUCE_TASKS = 128;

  public static void main(String[] args) throws Exception {
    var conf = new Configuration();
    System.exit(ToolRunner.run(conf, new Driver(), args));
  }

  public int run(String[] args) throws Exception {
    var inputPath = new Path(args[0]);
    var outputPath = new Path(args[1]);
    var tempPath = new Path(args[2]);
    var tempPath1 = new Path(tempPath, "output_job1");
    var tempPath2 = new Path(tempPath, "output_job2");
    var fileTokenCountPath = new Path(tempPath, "file_token_count");

    var conf = getConf();
    try (var fs = FileSystem.get(conf)) {
      var totalFileCount = fs.getContentSummary(inputPath).getFileCount();
      if (totalFileCount == 0) return 0;
      conf.setLong("totalFileCount", totalFileCount);
      conf.set("fileTokenCountPath", fileTokenCountPath.toString());

      if (!fs.exists(tempPath1) && !runJob1(inputPath, tempPath1)) System.exit(1);
      if (!fs.exists(tempPath2) && !runJob2(tempPath1, tempPath2)) System.exit(1);
      if (!fs.exists(outputPath) && !runJob3(tempPath2, outputPath)) System.exit(1);
    }
    return 0;
  }
}
```

先看主体部分，开始时先从命令行参数里读取 `<input_path>`, `<output_path>`, `<temp_path>`，然后确定几个 Job 的输出路径 `<temp_path_1>`, `<temp_path_2>`, `<file_token_count_path>`。

接下来先利用 `fs.getContentSummary(inputPath).getFileCount()` 直接得到输入路径里的文件总数，为之后计算 IDF 做准备。为什么这样实现呢？因为这样比较简单，通过 MapReduce 会比较麻烦。

然后将这个文件总数 `totalFileCount` 和未来保存各文件短语总数的路径 `fileTokenCountPath` 写入配置 `conf`，以供接下来的 MapReduce Job 使用。

最后就是依次执行 3 个 Job 了，中途如果失败就退出。这里对路径是否存在做了一个判断，目的有两个：首先，如果输出路径已经存在的话，Hadoop 会抛异常。这是因为 Hadoop 在设计上是希望使用者一次写入、多次读取的，因此如果需要重新写入的话，需要显式地手动移除这个目录。其次，如果每次重启都直接删除所有目录的话，比较浪费，因为很多时候我们可能只希望重新执行其中一两个 Job（比如错误恢复的情形）。对于大数据集来说，保留一部分中间结果，重新执行时可以节省大量的时间。

接下来讲讲这 3 个 MapReduce Job 的具体实现。

### 5.3 Job 1 - token position

#### 5.3.1 Driver

在 `Driver` 里，我们需要先对这个 Job 进行一些设定。

```java
// src/main/java/xyz/hakula/index/Driver.java

public class Driver extends Configured implements Tool {
  private boolean runJob1(Path inputPath, Path outputPath)
      throws IOException, InterruptedException, ClassNotFoundException {
    var job1 = Job.getInstance(getConf(), "token position");
    job1.setJarByClass(TokenPosition.class);

    job1.setMapperClass(TokenPosition.Map.class);
    job1.setMapOutputKeyClass(TokenFromFileWritable.class);
    job1.setMapOutputValueClass(LongWritable.class);

    job1.setReducerClass(TokenPosition.Reduce.class);
    job1.setNumReduceTasks(NUM_REDUCE_TASKS);
    job1.setOutputKeyClass(TokenFromFileWritable.class);
    job1.setOutputValueClass(LongArrayWritable.class);
    job1.setOutputFormatClass(SequenceFileOutputFormat.class);

    FileInputFormat.addInputPath(job1, inputPath);
    FileOutputFormat.setOutputPath(job1, outputPath);

    return job1.waitForCompletion(true);
  }
}
```

这里主要做的事情如下：

- 设定 Mapper 的类为 `TokenPosition.Map`，输出的 key 和 value 的类型分别为 `TokenFromFileWritable` 和 `LongWritable`。
- 设定 Reducer 的类为 `TokenPosition.Reduce`，任务数量为 $128$，输出的 key 和 value 的类型分别为 `TokenFromFileWritable` 和 `LongArrayWritable`，输出到文件的格式为顺序输出二进制文件。
- 设定输入路径为 `inputPath`，输出路径为 `outputPath`。

最后等待 Job 1 完成。

那 Job 1 的核心类可想而知，就是 `TokenPosition` 了。我们来看看相关的实现。

#### 5.3.2 Mapper

```java
// src/main/java/xyz/hakula/index/TokenPosition.java

public class TokenPosition {
  public static class Map extends Mapper<LongWritable, Text, TokenFromFileWritable, LongWritable> {
    private final TokenFromFileWritable key = new TokenFromFileWritable();
    private final LongWritable offset = new LongWritable();

    // Yield the byte offset of a token in each file.
    @Override
    public void map(LongWritable key, Text value, Context context)
        throws IOException, InterruptedException {
      var filename = ((FileSplit) context.getInputSplit()).getPath().getName();
      var offset = key.get();  // byte offset

      var it = new StringTokenizer(value.toString(), " \t\r\f");
      while (it.hasMoreTokens()) {
        var token = it.nextToken().toLowerCase(Locale.ROOT);
        this.key.set(token, filename);
        this.offset.set(offset);
        context.write(this.key, this.offset);

        // Suppose all words are separated with a single whitespace character.
        offset += token.getBytes(StandardCharsets.UTF_8).length + 1;
      }
    }
  }
}
```

首先我们需要知道，最开始第一个 Mapper 直接从原始文件读取时，是按行读取的。也就是说，每个输入的 value 是源文件的一个行，而不是整个文件的内容。然后悲剧来了，key 是什么？很多教程里这个 key 的类型写的是 `Object`，因为他们并没有用到这个 key，他们无所谓 key 的类型，实际上 key 的类型应该是 `LongWritable`。有些教程说 key 的含义是 value 在文件中的行号，这也是错的，实际上 key 代表的是 value 关于文档起始位置的**字节偏移量**，注意不是**列偏移量**。

为什么说这是个悲剧呢？因为这意味着想得到当前 value 在文件中的实际行号将变得异常困难，这是 Hadoop 的第一个坑。经过几天的研究，我目前了解到的有以下方案[^lineno-so]：

1. 写个脚本程序对输入文件进行预处理，给每行的开头加一个行号。
2. 重新实现一个 `InputFormat`，在最开始读入文件时，将 key 设定成行号。

这两个方案我都不太满意，在进行了诸多尝试之后，我最后决定不做这个事了。因此目前用来表示短语在文档中位置的 `<position>` 的值，就是这个短语首字符关于文档起始位置的**字节偏移量**。其实这样在检索时也方便快速定位。

那么如何得到每个短语的字节偏移量 `<position>` 呢？考虑到语料库里所有短语都是用单个空格分隔的，我们直接利用 `StringTokenizer` 将这行的内容分割成一个个短语，于是每个短语的 `<position>` 就是前一个短语的 `<position>` 加上其所占字节数加 1，第一个短语的 `<position>` 就是行首关于文档起始位置的字节偏移量，也就是 key 的值。

最后我们设置输出的 key 为 `<token>@<filename>`，以便 Reducer 进一步聚合每个短语在各文件里出现的所有位置。输出的 value 就是短语出现的位置，也就是前面讲的字节偏移量。

#### 5.3.3 Reducer

```java
// src/main/java/xyz/hakula/index/TokenPosition.java

public class TokenPosition {
  public static class Reduce extends
      Reducer<TokenFromFileWritable, LongWritable, TokenFromFileWritable, LongArrayWritable> {
    private final LongArrayWritable offsets = new LongArrayWritable();

    // Yield all occurrences of a token in each file.
    @Override
    public void reduce(TokenFromFileWritable key, Iterable<LongWritable> values, Context context)
        throws IOException, InterruptedException {
      var offsets = new ArrayList<LongWritable>();
      for (var value : values) {
        offsets.add(WritableUtils.clone(value, context.getConfiguration()));
      }
      offsets.sort(LongWritable::compareTo);
      this.offsets.set(offsets.toArray(LongWritable[]::new));
      context.write(key, this.offsets);
    }
  }
}
```

Reducer 的逻辑就比较简单了，就是将每个短语在各文件里出现的所有位置排个序，然后聚合成一个数组，最后输出。这里使用 `SequenceFileOutputFormat` 的好处就体现出来了，我们可以直接输出自定义 Writable 类型，而不需要先转化成 Text。

需要注意的是，MapReduce 在遍历一个 Iterable 时，为了节省内存开销，会**复用同一个 value 对象**，这是 Hadoop 的第二个坑。那我们知道 Java 底层全都是传的 reference，所以如果你直接将 value 传入数组的话，最后数组里所有元素的值就都会是同一个值（也就是最后一个元素）。因此这里传入数组的时候，一定要使用 `WritableUtils.clone()` 方法进行深拷贝。

### 5.4 Job 2 - token count

#### 5.4.1 Driver

```java
// src/main/java/xyz/hakula/index/Driver.java

public class Driver extends Configured implements Tool {
  private boolean runJob2(Path inputPath, Path outputPath)
      throws IOException, InterruptedException, ClassNotFoundException {
    var conf = getConf();
    var job2 = Job.getInstance(conf, "token count");
    job2.setJarByClass(TokenCount.class);

    job2.setInputFormatClass(SequenceFileInputFormat.class);
    job2.setMapperClass(TokenCount.Map.class);
    job2.setMapOutputKeyClass(Text.class);
    job2.setMapOutputValueClass(TokenPositionsWritable.class);

    var totalFileCount = conf.getLong("totalFileCount", 1);
    job2.setReducerClass(TokenCount.Reduce.class);
    job2.setNumReduceTasks((int) totalFileCount);
    job2.setOutputKeyClass(Text.class);
    job2.setOutputValueClass(TermFreqWritable.class);
    job2.setOutputFormatClass(SequenceFileOutputFormat.class);

    FileInputFormat.addInputPath(job2, inputPath);
    FileOutputFormat.setOutputPath(job2, outputPath);

    return job2.waitForCompletion(true);
  }
}
```

和 Job 1 基本没什么区别。这里将 Reducer 的任务数量设置为了文件总数，是因为这一步是在对 `<filename>` 进行聚合。这里最好是设置一个 Partitioner，让每个 `<filename>` 可以和 Reducer 一一对应，不过因为对效率影响不大，这里就不写了。

#### 5.4.2 Mapper

```java
// src/main/java/xyz/hakula/index/TokenCount.java

public class TokenCount {
  public static class Map
      extends Mapper<TokenFromFileWritable, LongArrayWritable, Text, TokenPositionsWritable> {
    private final Text key = new Text();
    private final TokenPositionsWritable value = new TokenPositionsWritable();

    // (<token>@<filename>, [<offset>]) -> (<filename>, (<token>, [<offset>]))
    @Override
    public void map(TokenFromFileWritable key, LongArrayWritable value, Context context)
        throws IOException, InterruptedException {
      this.key.set(key.getFilename());
      this.value.set(key.getToken(), (Writable[]) value.toArray());
      context.write(this.key, this.value);
    }
  }
}
```

Job 2 的 Mapper 就是把字段改个位置，[之前](#512-job-2-概览) 讲过了。接下来 Reducer 就可以对 `<filename>` 进行聚合。

#### 5.4.3 Reducer

```java
// src/main/java/xyz/hakula/index/TokenCount.java

public class TokenCount {
  public static class Reduce extends Reducer<Text, TokenPositionsWritable, Text, TermFreqWritable> {
    private final Text key = new Text();
    private final TermFreqWritable value = new TermFreqWritable();

    // Yield the token count of each token in each file,
    // and calculate the total token count of each file.
    // (<filename>, (<token>, [<offset>]))
    // -> (<token>, (<filename>, <token_count>, 0, [<positions>]))
    @Override
    public void reduce(Text key, Iterable<TokenPositionsWritable> values, Context context)
        throws IOException, InterruptedException {
      var filename = key.toString();
      long totalTokenCount = 0;
      for (var value : values) {
        var positions = value.getPositions();
        var tokenCount = positions.length;
        this.key.set(value.getToken());
        // The Term Frequency (TF) will be calculated in next job, and hence left blank here.
        this.value.set(filename, tokenCount, 0, positions);
        context.write(this.key, this.value);
        totalTokenCount += tokenCount;
      }
      writeToFile(context, key.toString(), totalTokenCount);
    }

    private void writeToFile(Context context, String key, long totalTokenCount) throws IOException {
      var conf = context.getConfiguration();
      var fs = FileSystem.get(conf);
      var fileTokenCountPath = conf.get("fileTokenCountPath");
      var outputPath = new Path(fileTokenCountPath, key);
      try (var writer = new BufferedWriter(new OutputStreamWriter(fs.create(outputPath, true)))) {
        writer.write(totalTokenCount + "\n");
      }
    }
  }
}
```

Reducer 比较复杂，是整个项目最大的难点。困难的不是实现本身，而是选择这个方案的思考过程。

我们的目标是得到 TF，现在我们有所有短语在各文件里出现的所有位置，因此我们就有所有短语在各文件里的出现次数。我们知道 $$\mathrm{TF}(t,d) = \frac{c_{t, d}}{\sum_{t'\in d} c_{t',d}}$$ 所以我们现在只需要各文件的短语总数，也就是将每个短语的出现次数求和。

听起来是不是很简单？我们已经有所有短语的出现次数了，直接遍历一下加起来不就行了？然而问题来了，现在我们不仅需要累加，而且还需要计算每个短语在各文件里的 TF。但问题是我们得先遍历一次，得到文件的短语总数，然后才能算出短语在这个文件里的 TF。

这有什么难的，那就先遍历一次求和，然后再遍历一次分别计算出 TF 的值不就好了？麻烦来了，MapReduce 为了节省内存开销，Iterable **只能遍历一次**，阅后即焚，这是 Hadoop 的第三个坑。

怎么解决呢？很简单，我直接开个数组把这些 value 都存下来不就好了？那当然是不行的，程序会直接报错 `java.lang.OutOfMemoryError`——数据集太大，爆内存了。

看来遍历的时候不能将数据保存在内存里，必须直接写入文件，通过磁盘来中转。这下没办法在 Job 2 直接得到 TF 了，只能先用 `0` 占个位，我们到 Job 3 再算。问题又来了，这些文件短语总数该存在哪里呢？

一个很直观的想法是，那我在内存里建一个 HashMap，执行 Job 2 的过程中保存在里面，执行 Job 3 时再读取不就好了？至于这个 HashMap 放哪里，无所谓，反正基本约等于全局变量（准确来说是 static 变量），放 `Driver` 类里和放 `InvertedIndex` 类里都一样。

我一开始也是这么实现的，而且在本地跑得很正常，一点问题都没有。结果一上 Hadoop 集群傻眼了，程序报错 `java.lang.NullPointerException`——写进 HashMap 的键值对，Job 3 读不到。

怎么一回事呢？原来，Hadoop 集群上**每个任务都单开了一个 JVM**[^jvm-so]，对于其他语言的实现就是单开了一个进程，这是 Hadoop 的第四个坑。所以你在这个 JVM 里写进内存的数据，其他 JVM 当然读不到了。其实仔细想想，显然是这么个道理，毕竟分布式系统，怎么可能所有任务都跑在同一个进程上。但第一次接触分布式系统的话，难免容易用单机的思路想问题，然后就上当了。

那怎么办呢？一种思路，也就是我目前的实现，是在执行 Job 2 的过程中，直接将文件短语总数写进文件里，之后执行 Job 3 前再读取到内存中。需要注意的是，不可以先写进内存，最后统一写进文件里，因为这同样会遇到刚才提到的 JVM 隔离问题，不同任务的内存都是分开的。此外，为了避免并发写的问题，这里我将不同文件的短语总数都写到了不同的文件里（以 `<filename>` 命名）。这里还需要注意的是，学校服务器的 HDFS 似乎不支持 append 写，因此你也做不到把他们都写进一个文件里。

这个问题的解决方案想了我至少两天，可以说是本项目最大的难点了，期间真的是踩了不少坑。

别的就没什么好讲的了，代码很直观。这里我们输出的 key 又变回了 `<token>`，接下来我们将对 `<token>` 进行聚合。

### 5.5 Job 3 - inverted index

#### 5.5.1 Driver

```java
// src/main/java/xyz/hakula/index/Driver.java

public class Driver extends Configured implements Tool {
  private boolean runJob3(Path inputPath, Path outputPath)
      throws IOException, InterruptedException, ClassNotFoundException {
    var job3 = Job.getInstance(getConf(), "inverted index");
    job3.setJarByClass(InvertedIndex.class);

    job3.setInputFormatClass(SequenceFileInputFormat.class);
    job3.setMapperClass(InvertedIndex.Map.class);
    job3.setMapOutputKeyClass(Text.class);
    job3.setMapOutputValueClass(TermFreqWritable.class);

    job3.setReducerClass(InvertedIndex.Reduce.class);
    job3.setNumReduceTasks(NUM_REDUCE_TASKS);
    job3.setOutputKeyClass(Text.class);
    job3.setOutputValueClass(Text.class);

    FileInputFormat.addInputPath(job3, inputPath);
    FileOutputFormat.setOutputPath(job3, outputPath);

    return job3.waitForCompletion(true);
  }
}
```

和 Job 1 基本没什么区别。因为是最后一个 Job，这里不再需要设置 `setOutputFormatClass` 了，我们直接以文本格式输出。

#### 5.5.2 Mapper

```java
// src/main/java/xyz/hakula/index/InvertedIndex.java

public class InvertedIndex {
  public static class Map extends Mapper<Text, TermFreqWritable, Text, TermFreqWritable> {
    // Yield the Term Frequency (TF) of each token in each file.
    @Override
    public void map(Text key, TermFreqWritable value, Context context)
        throws IOException, InterruptedException {
      var fileTokenCount = readFromFile(context, value.getFilename());
      value.setTermFreq((double) value.getTokenCount() / fileTokenCount);
      context.write(key, value);
    }

    private long readFromFile(Context context, String key) throws IOException {
      var conf = context.getConfiguration();
      var fs = FileSystem.get(conf);
      var fileTokenCountPath = conf.get("fileTokenCountPath");
      var inputPath = new Path(fileTokenCountPath, key);
      try (var reader = new BufferedReader(new InputStreamReader(fs.open(inputPath)))) {
        return Long.parseLong(reader.readLine());
      }
    }
  }
}
```

既然在 Job 2 的 Reducer 里不能得到 TF，那我们就在 Job 3 的 Mapper 里得到。当 Job 3 的 Mapper 需要一个文件的短语总数时，就从 Job 2 输出的中间文件里读取。顺便一提，MapReduce 的 Job 之间是顺序执行的，但同一个 Job 的 Mapper 和 Reducer 是并行的，因此我们也不能让 Mapper 或 Combiner 计算文件短语总数，然后在 Reducer 里读取。

将每个短语的出现次数除以文件的短语总数，我们就得到了短语的 TF，这下可以替换掉原来的占位符了。

#### 5.5.3 Reducer

```java
// src/main/java/xyz/hakula/index/InvertedIndex.java

public class InvertedIndex {
  public static class Reduce extends Reducer<Text, TermFreqWritable, Text, Text> {
    private final Text result = new Text();

    // Yield the Inverse Document Frequency (IDF) of each token.
    @Override
    public void reduce(Text key, Iterable<TermFreqWritable> values, Context context)
        throws IOException, InterruptedException {
      long fileCount = 0;
      for (var value : values) {
        result.set(value.toString());
        context.write(key, result);
        ++fileCount;
      }

      var conf = context.getConfiguration();
      var totalFileCount = conf.getLong("totalFileCount", 1);
      var inverseDocumentFreq = Math.log((double) totalFileCount / fileCount) / Math.log(2);
      result.set(new InverseDocumentFreqWritable(fileCount, inverseDocumentFreq).toString());
      context.write(key, result);
    }
  }
}
```

最后的 Reducer 主要就是计算一下每个短语的 IDF。通过这次聚合，我们可以得到出现短语 key 的所有文档的 TF 条目，遍历一次就可以得到出现这个短语的文档总数了。然后我们从配置 `conf` 里读取文档总数 `totalFileCount`，除一下取个对数就得到了 IDF。

在本来的实现中，我将所有的 TF 条目聚合成了一个数组，然后短语的 IDF 也是和这个数组放在一起。然而不幸的是，出现了和 Job 2 的 Reducer 一样的问题，爆内存了！数据集实在太大，即使只是一个短语的索引结果都放不进内存。我推测应该是像 `a`, `the` 这种常见短语，出现次数实在太多，所以就爆了。

于是我做了下调整，将同一短语在不同文件的索引结果分成了不同的条目，在遍历时就直接写进文件，不用再建一个巨大的数组了。聚合这些索引的逻辑就交给检索程序完成。

那 IDF 怎么办呢？我曾尝试过将 IDF 也像 Job 2 的 Reducer 里一样写进磁盘，结果发现写的文件实在多到离谱。和 Job 2 那时不同，Job 2 的 Reducer 写的是 `<filename>`，一共只有 64 个，但 Job 3 的 Reducer 写的是 `<token>`，我事后看了下可能有超过 1000 万个，导致程序跑到一半直接 I/O 拉满，后期速度非常非常慢（20 分钟进度动 1%）。而且 Job 2 需要写到其他目录是因为 `<temp_path>/output_job2` 下的输出数据后续还要被 Job 3 处理，因此 `<token_count>` 不能和正常的输出数据混在一起。但 Job 3 的输出数据已经是最终结果了，直接被检索程序处理，而检索程序的逻辑是我们可以控制的，所以就不存在这个问题。

因此，最终我选择将 IDF 也写在同一个文件里，紧跟在所有 TF 条目的后面。识别 TF 和 IDF 并分开解析的逻辑就也交给检索程序完成。为了方便检索程序做区分，我们在 IDF 条目 value 的开头加了一个 `$` 前缀作为标记。

至此，我们就成功实现了一个索引程序。

### 5.6 Woogle

下面简单讲讲检索程序的主类 `Woogle`，以下是基于 Java SE 17 的实现：

```java
// src/main/java/xyz/hakula/woogle/Woogle.java

public class Woogle extends Configured implements Tool {
  private static final Logger log = Logger.getLogger(Woogle.class.getName());

  public static void main(String[] args) throws Exception {
    var conf = new Configuration();
    System.exit(ToolRunner.run(conf, new Woogle(), args));
  }

  public int run(String[] args) throws Exception {
    var key = "";
    try (var scanner = new Scanner(System.in)) {
      System.out.print("Please input a keyword:\n> ");
      key = scanner.nextLine().trim().toLowerCase(Locale.ROOT);
    }
    if (!key.isBlank()) {
      var indexPath = new Path(args[0]);
      search(key, indexPath);
    }
    return 0;
  }
}
```

先讲大体框架。流程上很简单，就是：

1. 提示用户输入一个关键词。
2. 在索引文件夹里搜索并输出结果。

接下来讲一下具体实现。

#### 5.6.1 `search()`

```java
// src/main/java/xyz/hakula/woogle/Woogle.java

public class Woogle extends Configured implements Tool {
  protected void search(String key, Path indexPath) throws IOException {
    var conf = getConf();
    var fs = FileSystem.get(conf);
    var partition = getPartition(key);
    var filePath = new Path(indexPath, String.format("part-r-%05d", partition));

    try (var reader = new BufferedReader(new InputStreamReader(fs.open(filePath)))) {
      var tfs = new ArrayList<TermFreq>();
      var line = "";

      while ((line = reader.readLine()) != null) {
        var lineSplit = line.split("\t");
        var token = lineSplit[0];
        var entry = lineSplit[1];

        if (Objects.equals(key, token)) {
          try {
            if (entry.charAt(0) != '$') {
              tfs.add(TermFreq.parse(entry));
            } else {
              print(key, InverseDocumentFreq.parse(entry), tfs);
              return;
            }
          } catch (Exception e) {
            log.warn(token + ": invalid index entry, error: " + e);
          }
        }
      }
    } catch (FileNotFoundException e) {
      log.error(key + ": index not exists");
    }

    System.out.println(key + ": not found");
  }
}
```

这个是检索程序的核心代码。我们根据关键词 `<key>`，利用函数 `getPartition()` 定位到相应的 TF 文件（将在 [5.6.2](#562-getpartition) 节讲解），然后逐行遍历查询。查询到与 `<key>` 相同的 `<token>` 后，判断 value 的首字符是否为 `$`。如果是，则按 IDF 条目的格式解析 value，并输出搜索结果，退出程序。否则按 TF 条目的格式解析 value，并缓存结果，等待之后统一输出。如果索引文件里找不到，则输出信息 `<key>: not found`。

为什么要遍历查询呢？主要还是因为并行的 MapReduce 程序不保证顺序，不一定可以使用二分查找。事实上如果觉得慢的话，完全可以把最后一个 Reducer 的任务数量设置得大一点，因为最后索引的分片数量就等于这个 Reducer 的任务数量，我们总可以设置到一个足够大的值，使得线性复杂度的耗时可以接受。

#### 5.6.2 `getPartition()`

```java
// src/main/java/xyz/hakula/woogle/Woogle.java

public class Woogle extends Configured implements Tool {
  protected int getPartition(String key) {
    var textKey = new Text(key);
    return (textKey.hashCode() & Integer.MAX_VALUE) % Driver.NUM_REDUCE_TASKS;
  }
}
```

函数 `getPartition()` 的实现很简单，其实就是沿用了 Job 2 的默认 Partitioner 的分配方法，也就是直接对 `<key>` 哈希，然后对 Reducer 的任务数量取模。这样就可以定位到当时 `reduce()` 这个 `<key>` 的 Reducer，从而定位到相应的索引分片。

#### 5.6.3 `InverseDocumentFreq.parse()`

```java
// src/main/java/xyz/hakula/woogle/model/InverseDocumentFreq.java

public record InverseDocumentFreq(long fileCount, double inverseDocumentFreq) {
  private static final String PREFIX = "$";
  private static final String DELIM = ":";

  public static InverseDocumentFreq parse(String entry) {
    var entrySplit = entry.substring(PREFIX.length()).split(Pattern.quote(DELIM));
    var fileCount = Long.parseLong(entrySplit[0]);
    var inverseDocumentFreq = Double.parseDouble(entrySplit[1]);
    return new InverseDocumentFreq(fileCount, inverseDocumentFreq);
  }
}
```

函数 `InverseDocumentFreq.parse()` 就是解析一下 IDF 条目的内容，简单 `split()` 一下就行。

#### 5.6.4 `TermFreq.parse()`

```java
// src/main/java/xyz/hakula/woogle/model/TermFreq.java

public record TermFreq(String filename, long tokenCount, double termFreq, long[] positions) {
  private static final String DELIM = ":";
  private static final String POS_ARRAY_DELIM = ";";

  public static TermFreq parse(String entry) {
    var entrySplit = entry.split(Pattern.quote(DELIM));
    var filename = entrySplit[0];
    var tokenCount = Long.parseLong(entrySplit[1]);
    var termFreq = Double.parseDouble(entrySplit[2]);
    var positionsSplit = entrySplit[3].split(Pattern.quote(POS_ARRAY_DELIM));
    var positions = Arrays.stream(positionsSplit).mapToLong(Long::parseLong).toArray();
    return new TermFreq(filename, tokenCount, termFreq, positions);
  }
}
```

函数 `TermFreq.parse()` 就是解析一下 TF 条目的内容，同样简单 `split()` 一下就行。`positions` 的解析用了个比较函数式的写法。其实 MapReduce 本身就很函数式，只可惜 Java 不太函数式，写起来就不怎么优雅。

#### 5.6.5 `print()`

```java
// src/main/java/xyz/hakula/woogle/Woogle.java

public class Woogle extends Configured implements Tool {
  protected void print(String token, InverseDocumentFreq idf, ArrayList<TermFreq> tfs) {
    System.out.printf(
        "%s: IDF = %6f | found in %d file%s:\n",
        token,
        idf.inverseDocumentFreq(),
        idf.fileCount(),
        idf.fileCount() == 1 ? "" : "s"
    );

    for (var tf : tfs) {
      System.out.printf(
          "  %s: TF = %6e (%d time%s) | TF-IDF = %6e | positions:",
          tf.filename(),
          tf.termFreq(),
          tf.tokenCount(),
          tf.tokenCount() == 1 ? "" : "s",
          tf.termFreq() * idf.inverseDocumentFreq()
      );
      int limit = 10;
      for (var position : tf.positions()) {
        System.out.print(" ");
        System.out.print(position);
        if (--limit == 0) {
          System.out.print(" ...");
          break;
        }
      }
      System.out.println();
    }
  }
}
```

对 IDF 和 TF 进行普通的格式化输出，这就是我们的搜索结果。这里在输出 `<positions>` 的时候，为了防止刷屏，默认只展示前 10 个 `<position>`。

至此，我们就成功实现了一个检索程序。

当然有了索引文件，想写个前端界面啦，或者对结果按 TF-IDF 的大小排个序啦都很容易。主要还是期末季太忙了，实在没时间，不然都好做。

[^lineno-so]: [java - Get unique line number from a input file in MapReduce mapper - Stack Overflow](https://stackoverflow.com/questions/29786397/get-unique-line-number-from-a-input-file-in-mapreduce-mapper)
[^jvm-so]: [java - Static variable value is not changing in mapper function - Stack Overflow](https://stackoverflow.com/questions/41280397/static-variable-value-is-not-changing-in-mapper-function)
