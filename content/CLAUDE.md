# 文章写作规范

本文档规定了 `content/posts/` 目录下文章的格式与排版规范。

## 1. 文章结构规范

### 1.1 Frontmatter

每篇文章必须包含 YAML frontmatter，格式如下：

```yaml
---
title: 文章标题
date: YYYY-MM-DDTHH:MM:SS+08:00

tags: [标签 1, 标签 2]
categories: [分类名称]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/3/article-covers/{image}.webp
license: CC BY-NC-SA 4.0
---
```

#### 1.1.1 字段说明

- `date`: 格式严格遵循 ISO 8601，时区为 `+08:00`；可初始化为当前日期和时间。
- `tags`: 标签数组，可包含多个标签（以半角逗号分隔）。
- `categories`: 分类数组，通常为单个分类，值通常为 `content/posts/` 目录下的第一层目录名（如 `content/posts/avg/impressions/index.md` 的分类为 `avg`，`content/posts/anime/ave-mujica/preface.md` 的分类为 `anime`）。
- `featuredImage`: 封面图片 URL，其中 `{image}` 为图片文件名的预留占位符，等待用户上传图片后替换为实际图片文件名。
- `license`: 许可证，通常保持 `CC BY-NC-SA 4.0` 即可。

#### 1.1.2 例外情况

如果文档路径中包含 `_` 开头的目录（如 `content/posts/anime/_materials/draft.md`），则表示不公开的内部文档，此时无需添加 frontmatter。

### 1.2 文章主体结构

```markdown
---
[frontmatter]
---

文章简介或摘要（通常不超过 200 字）。

<!--more-->

{{< admonition info 封面出处 >}}
[Title - @Author](https://www.pixiv.net/artworks/{image-id})
{{< /admonition >}}

## 二级标题

### 三级标题

正文内容
```

#### 1.2.1 要点

1. 使用 `<!--more-->` 标记摘要分隔点。
2. 封面出处使用 `admonition info` shortcode。
3. 正文使用二级标题（`##`）和三级标题（`###`），避免使用一级标题，最多不超过六级标题（`######`）。

#### 1.2.2 例外情况

如果文档路径中包含 `_` 开头的目录，则无需遵从此文章主体结构规范，而是遵循默认的 Markdown 格式。即：

1. 使用一级标题（`#`）作为文章标题。
2. 不使用 frontmatter、文章摘要、`<!--more-->` 标记、封面出处、所有 shortcode。
3. 子标题最多不超过六级标题（`######`）。

```markdown
# 一级标题

## 二级标题

### 三级标题

正文内容
```

### 1.3 Shortcodes

```markdown
{{< admonition type 标题 >}}

内容

{{< /admonition >}}
```

常用类型（`type` 的可选值）：

- `quote`: 引用
- `note`: 批注
- `info`: 信息
- `warning`: 警告
- `tip`: 提示

#### 1.3.1 要点

1. `{{< admonition type 标题 >}}` 和 `{{< /admonition >}}` 必须成对使用，上下两侧均需有空行。
2. 当标题包含空格时，需使用半角引号包裹（如 `{{< admonition note "标题 包含 空格" >}}`。
3. 通常不使用 Markdown 语法的 `>` 作为引用，而是使用 shortcode `{{< admonition quote 标题 >}}` 代替。

#### 1.3.2 例外情况

如果文档路径中包含 `_` 开头的目录，则不使用 shortcode，而是使用常规的 Markdown 语法。

### 1.4 注释

```markdown
### 三级标题 1

正文内容，脚注[^footnote-id]。

[^footnote-id]: 注释内容

### 三级标题 2
```

#### 1.4.1 要点

1. 脚注内容 `[^footnote-id]: 注释内容` 通常放在这一小节的最后、下一小节的标题之前，而不是文章末尾。

## 2. 文章排版规范

基于 [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines/blob/master/README.zh-Hans.md)。

### 2.1 空格规则

#### 2.1.1 中文与英文、数字等半角字符之间必须添加空格

示例：

```markdown
在 LeanCloud 上，数据存储是围绕 `AVObject` 进行的。
勾股定理的公式是 $a^2 + b^2 = c^2$。
今天出门花了 5000 元。
```

#### 2.1.2 数字与单位之间（百分号、度数除外）必须添加空格

示例：

```markdown
我家的光纤入屋宽带有 10 Gbps，SSD 一共有 20 TB。
角度为 90° 的角，就是直角。
新 MacBook Pro 有 15% 的 CPU 性能提升。
```

#### 2.1.3 链接两侧需要添加空格（标点符号侧除外）

示例：

```markdown
详情请查阅 [官方文档](https://doc.rust-lang.org)。
```

#### 2.1.4 脚注左侧不添加空格、右侧添加空格（标点符号侧除外）

示例：

```markdown
Rust[^rust] 是一种编程语言。
```

### 2.2 标点符号

#### 2.2.1 中文段落中使用全角标点

- 逗号：`，`
- 句号：`。`
- 顿号：`、`
- 问号：`？`
- 感叹号：`！`
- 分号：`；`
- 冒号：`：`
- 引号：`「」『』`
- 书名号：`《》〈〉`
- 破折号：`——`
- 省略号：`……`

示例：

```markdown
我最近观看了「少女终末旅行」这部动画，是一部不错的作品！
「规训」这个术语出自福柯的《规训与惩罚》。
```

##### 2.2.1.1 要点

1. 不使用半角引号：`“” ‘’ "" ''`。
2. 使用直角引号时，外侧为 `「」`，内侧为 `『』`。
3. 使用书名号时，外侧为 `《》`，内侧为 `〈〉`。
4. 对于 ACGN（动画、漫画、游戏、轻小说）类别的作品，无论语言是中文、日文、英文，统一使用直角引号 `「」`，不使用书名号 `《》`。
   - 示例：「少女终末旅行」、「EVA」、「东方 Project」、「ゼルダの伝説」
5. 对于传统书籍、电影、电视剧等非 ACGN 类别的作品（简单判断即可，难以判断时使用直角引号 `「」`）：
   1. 如果语言是中文（包括简体中文、繁体中文），使用全角书名号 `《》`。
      - 示例：《紅樓夢》、《纯粹理性批判》、《让子弹飞》
   2. 如果语言是日文（根据作品出处判断，注意与繁体中文的区分，注意语境），使用直角引号 `『』`。
      - 示例：『金門寺』、『羅生門』、『白い巨塔』
   3. 如果语言是英文等使用半角字符的语言，使用斜体，不使用引号或书名号。
      - 示例：_Ulysses_, _The Godfather_, _The Wire_

#### 2.2.2 中文段落中使用半角标点的例外情况

1. 当括号内的内容全部由英文、数字等半角字符组成时，使用半角括号。
   - 示例：拉康 (Jacques Lacan, 1901-1981) 理论中的「三大界」(The Three Orders) 分别是「想象界」(The Imaginary)、「符号界」(The Symbolic) 和「实在界」(The Real)。
2. 当并列的词语全部由英文、数字等半角字符组成时，使用半角逗号，不使用全角逗号或顿号。
   - 示例：123, text, `code`, $x^2$
3. 当冒号前后均为英文、数字等半角字符时，使用半角冒号。
   - 示例：GPU: NVIDIA GeForce RTX 5090
4. 遇到完整的英文整句、特殊名词，其内容使用半角标点。
   - 示例：乔布斯曾说过：「Stay hungry, stay foolish.」
5. 总是使用半角斜杠 `/`，不使用全角斜杠 `／`。
   - 示例：哈拉维主张打破自然 / 文化、人类 / 机器、男性 / 女性等传统西方思想中常见的二元划分。

### 2.3 专有名词

保持正确的大小写和拼写。在首次出现时，不要使用缩写、简称。

示例：

- 产品 / 品牌：iPhone, GitHub, LeetCode, NVIDIA
- 技术术语：JSON, API, LaTeX, Vue.js
- 作品：「BanG Dream! It's MyGO!!!!!」、「Remember11 -the age of infinity-」
  - 缩写时，仍需保持正确的大小写：「MyGO」、「R11」

## 3. Markdown 规范

遵循 [markdownlint](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md) 规则。

### 3.1 标题

1. 标题符号后必须有空格（如：`## 二级标题`）。
2. 标题前后必须有空行。
3. 不跳级（二级标题后是三级标题，不能是四级标题）。

### 3.2 列表

1. 使用 `-` 作为无序列表标记。

2. 标记后必须有空格（如：`- 子项`）。

3. 无序列表的子项缩进 2 个空格。

   ```markdown
   - 无序列表 1
     - 无序列表 1.1
   - 无序列表 2
   ```

4. 有序列表的子项缩进 3 个空格。

   ```markdown
   1. 有序列表 1
      1. 有序列表 1.1
   2. 有序列表 2
   ```

5. 列表整体前后必须有空行。

### 3.3 代码块

1. 使用三个反引号。
2. 必须指定语言标识符（如果没有语言概念，使用 `text` 作为标识符）。
3. 代码块前后必须有空行。

### 3.4 其他

1. 段落间使用一个空行分隔（不使用多个空行）。
2. 使用 3 个连续的 `-` 作为水平分隔线（`---`）。
   1. 章节间无需另外添加水平分割线。
3. 加粗使用 `**文本**`，标记与文字间无空格。
4. 斜体使用 `_文本_`，标记与文字间无空格。

## 4. 内容规范

### 4.1 语言风格

1. 表达清晰、逻辑严密，但不要过于书面、学术，也不要过于口语化。
2. 使用准确的专业术语，避免虚空造词。必要时可使用括号进行补充说明。
3. 避免使用过多的加粗标记，可使用直角引号 `「」` 代替来表示强调。
4. 避免过多的连接词（如「然而」、「所以」等），避免频繁的断句（无论是逗号还是句号），避免短句间总是有很强的逻辑关联，以减少「AI 味」。
   1. 文本生成完毕后，分析风格是否有太重的 AI 味，并进行润色。每次编辑都需重复此流程。
   2. 分析思路：尝试判断文本由 AI 生成的概率，如果判断概率较高（> 70%），则说明「AI 味」过重，需要进行改写。
5. 可参考 `content/posts/anime/ave-mujica/preface.md`（`admonition` shortcode 块以外的部分）学习我的语言风格。
   1. 可以总结于 `content/posts/CLAUDE.md` 文档中，供未来使用。`CLAUDE.md` 文档格式和当前文档（`content/CLAUDE.md`）保持基本一致。
   2. 重点观察用户对生成文本的修改情况，由此分析用户的写作风格偏好，记录于 `content/posts/CLAUDE.md` 文档中。每次编辑时如果发现用户修改了文本，就需要重复此流程。
6. 允许主观、情绪化、有明显倾向性的表达，不必追求客观、中立、大众易于接受的风格。
   1. 审美倾向、价值观可参考 `content/posts/essay/about-aesthetics/index.md`。
   2. 具体美学观点、理论体系可参考 `content/posts/anime/ave-mujica/preface.md`。
   3. 性格特征可参考 `content/posts/essay/who-am-i/index.md` 和 `content/posts/essay/from-stupidity-aversion-to-lines-of-flight/index.md`。
   4. 可以总结于 `content/posts/CLAUDE.md` 文档中，供未来使用。

### 4.2 分段

1. 每个小节围绕单一主题。
2. 每个小节字数适中，注意在全文中占据的篇幅比例，避免过于冗长或过于简短。
3. 小节间衔接连贯，避免生硬转折。
