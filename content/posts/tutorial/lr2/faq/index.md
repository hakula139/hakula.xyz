---
title: LR2 配置教程 - FAQ
date: 2019-07-19T02:43:00+08:00

tags: [LR2]
categories: [tutorial]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/73473821.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

一些常见问题及参考解决方案。

<!--more-->

{{< admonition info 封面出处 >}}
[膕 - @神岡ちろる](https://www.pixiv.net/artworks/73473821)
{{< /admonition >}}

欢迎在评论区继续提问。

## 1 部分曲包没有读取到

编码问题，参见 [为什么要转区](../download/#为什么要转区)。

{{< admonition tip 解决方案 >}}
修改读取失败的曲包目录名，确保其路径里不包含中文等全角字符。然后在选曲界面的对应目录里按 `F8` 更新，或者在启动器里设置曲包更新模式为 [Auto reload](../launcher/#song-reload)。
{{< /admonition >}}

## 2 导入曲包时报错

原因同上。具体如何精确定位到出错的曲包，热心网友 @MsrButterfly 提供了以下方案：

{{< admonition tip 解决方案 >}}
不要关闭弹出的「引数不正」错误提示，尝试在资源管理器里移动曲包目录（推荐使用二分法）。如果某些目录无法被移动，那么出错的曲包就在其中。按 [#1](#1-部分曲包没有读取到) 的方案修改后，重复上述步骤直到所有目录均可正常移动。
{{< /admonition >}}

当然，置之不理也不影响正常游玩。可以等发现想玩的曲包没有正常读取时，再按 [#1](#1-部分曲包没有读取到) 进行操作。

## 3 部分歌曲游玩时没有声音

最常见的情况是曲包目录名有问题，解决方案同上。

如果未能解决，可能是因为 key 音文件名里也包含日文等全角字符，这种情况下只能通过 [转区](../download/#准备工作---转区) 解决。

## 4 游戏内出现乱码

同样是编码问题，一般是启动过游戏后又转区导致。本站整合包可能也存在这个问题。

{{< admonition tip 解决方案 >}}
先 [转区](../download/#准备工作---转区) 或者始终不转区，此后不要再调整编码设置。然后按当前编码重新解压 LR2 压缩包，并重新配置。
{{< /admonition >}}

LR2 的编码问题确实比较折腾，都是历史遗留问题。

## 5 段位回放没有保存

这是一个 [bug](../notices/#一些已知的-bug)，新回放无法覆盖旧回放。

在没有源码的情况下，我们当然无法修复这个问题，只能提供一个 workaround 尝试恢复段位回放文件。

{{< admonition tip 解决方案 >}}

首先，**确保游玩段位后没有再游玩其他段位（或者重试本段位）**，否则到此结束，下面的内容也不用看了。

进入目录 `LR2files/Replay/用户名`，可以找到 `__0.lr2rep` ... `__3.lr2rep` 这 4 个文件（对于 Course 来说可能是 1 ~ 5 个文件）。这些就是本次段位回放的临时文件，**请先备份到别处**。

进入目录 `c`，这是段位回放的正式保存位置，也是我们希望将临时文件覆盖到的位置。如果目录较少，可以通过修改日期大致推断出各目录所对应的段位。如果无法确定，可以**将整个 `Replay` 目录先备份到别处，备份到别处，备份到别处**，然后清空 `c` 目录。接着启动 LR2，设置 [REPLAY SAVE](../select/#replay-save) 为 ALWAYS，进入需要保存回放的段位随便按几个 note 后退出。此时目录 `c` 下自动创建的文件夹就是本段位回放的保存位置。此后，我们将之前备份的 `Replay` 目录还原。

最后，我们将之前备份的 `__0.lr2rep` ... `__3.lr2rep` 重命名为 `0.lr2rep` ... `3.lr2rep`，覆盖到刚才找到的段位回放的保存位置。至此，段位回放文件恢复完毕。

{{< /admonition >}}

## 6 笔记本全屏锁帧

{{< admonition tip 解决方案 >}}

在 LR2 根目录下，右键 `LRHbody.exe`，勾选「设置 - 兼容性 - 禁用全屏优化」选项。

如果未能解决，可以在 [BMS 群](../about-bms/#-推荐) 的群文件里搜索下载 `ForceRefreshRate_1.zip`，解压并尝试使用。

{{< /admonition >}}

## 7 游戏内偶尔卡顿

{{< admonition tip 解决方案 >}}
关闭输入法，使用英语（美国）键盘。
{{< /admonition >}}

总不能是配置问题吧，毕竟快二十年前的游戏了，赛扬 + 核显都能带得动。除非你还要同时开高码率的直播，那还是有点吃配置的。

## 8 BGA 黑屏或报错

{{< admonition tip 解决方案 >}}

下载并安装 [Shark007][shark007] 或 [K-Lite][k-lite] 解码器。

[shark007]: https://shark007.net/index.html
[k-lite]: https://www.codecguide.com/download_kl.htm

{{< /admonition >}}

当然，很多 BMS 本来就是没有 BGA 的。

## 9 Walkure 不更新

{{< admonition tip 解决方案 >}}
按 `Ctrl` + `F5` 键强制刷新。或者按 `F12` 键，右键刷新按钮，选择「清空缓存并硬性重新加载」。
{{< /admonition >}}

## 10 全屏有声音但没有画面

一般是显卡设置的问题，每个人情况不同也不好排查。你可以先试试调整各种显卡设置，或者比如原来用核显运行的切换成独显，反之亦然。实在搞不定的话，就用窗口模式吧。可以尝试使用 [Borderless Gaming][borderless] 之类的工具来模拟全屏。

窗口模式会额外附加约 20 ms 的延迟，尽量还是使用全屏模式。

[borderless]: https://github.com/Codeusa/Borderless-Gaming

## 11 结算界面退出时卡住

这是因为 LR2 在结算界面会尝试拉取本谱的 IR 排行榜数据，阻塞了退出操作。

{{< admonition tip 解决方案 >}}
在 LR2IR 关闭 [成绩缓存](../internet-ranking/#player-status)。
{{< /admonition >}}

{{< admonition warning 注意 >}}
关闭成绩缓存后，将无法使用 [G-BATTLE](../select/#g-battle) 模式。
{{< /admonition >}}
