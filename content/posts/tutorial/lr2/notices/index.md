---
title: LR2 配置教程 - 注意事项
date: 2019-07-19T02:29:00+08:00

tags: [LR2]
categories: [tutorial]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/75778049.webp
license: CC BY-NC-SA 4.0
---

一些你或许有必要了解的注意事项，包括 LR2 的各种 bug，以及 Beatmania IIDX 相关的版权问题。

<!--more-->

{{< admonition info 封面出处 >}}
[江風 - @凪白みと](https://www.pixiv.net/artworks/75778049)
{{< /admonition >}}

## 一些已知的 bug

很多 bug 可能在之前的章节里也已经提到过，这里简单做一下梳理。

| 出现场合 | 问题                                                                               |
| :------- | :--------------------------------------------------------------------------------- |
| 全局     | 当 LR2 运行了一段时间后，随时可能莫名其妙地崩溃 ~~（防沉迷）~~。                   |
| 全局     | 全屏模式下切换程序或者任何弹窗都将导致 LR2 崩溃。                                  |
| 回放     | G-BATTLE 模式下，如果开启了 LANE OPTION，回放可能保存失败，表现为 key 音错乱。     |
| 回放     | 段位 / Course 的回放可能保存失败，表现为新回放无法覆盖旧回放。                     |
| 回放     | 游玩界面里不显示 Fast / Slow 指示，结算界面里 Fast / Slow 统计数据将不准确。       |
| 选曲界面 | 搜索框里 `/deletescore` 命令对段位 / Course 无效，表现为重启游戏后数据将自动恢复。 |
| 结算界面 | 当个人最高纪录是 FULL COMBO 时，本次 CLEAR TYPE 总是显示为 FULL COMBO。            |
| 皮肤设置 | 游玩界面的 GAUGE COLOR 和 CLOSE 在重启游戏 / 重进设置后可能会被误改成其他选项。    |
| 皮肤设置 | 段位 / Course 结算界面在重启游戏后将自动切换回原版皮肤（本站整合包已规避此问题）。 |

毕竟开发者已经失踪，游戏也没有开源，这些 bug 基本上是不会被修复了。

## 版权问题

{{< admonition failure 注意 >}}

由于版权问题，**禁止**使用 LR2 游玩 Beatmania IIDX 等商业音游的解析 BMS。如果你一定要游玩，**请不要：**

- 在 Bilibili、YouTube 等视频网站上直播或上传相关视频
- 在 微博、Twitter 等公开社交媒体上发布结算界面的截图
- 在公开场合分享传播解析 BMS 资源
- 将游玩纪录上传到 LR2IR

{{< /admonition >}}

## 开发者原说明

{{< admonition quote >}}

This software is free.

This software is not BEMANI emulator.

Do not play any IIDX song.

Do not make / upload / use IIDX skins.

Do not redistribute this software without our permission.

Do not use this software for any commercial purpose.

Support will not be provided for non-Japanese OS users.

{{< /admonition >}}

{{< admonition quote 中文翻译 false >}}

本软件是免费软件。

本软件不是 BEMANI 游戏模拟器。

请勿游玩任何 IIDX 歌曲。

请勿制作 / 上传 / 使用 IIDX 皮肤。

请勿在未经我们授权的情况下再分发本软件。

请勿将本软件用于任何商业用途。

对于非日语系统的用户，我们不提供支持。

{{< /admonition >}}
