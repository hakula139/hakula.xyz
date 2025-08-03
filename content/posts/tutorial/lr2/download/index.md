---
title: LR2 配置教程 - 下载
date: 2018-09-19T14:15:00+08:00

tags: [LR2]
categories: [tutorial]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/69065999.webp
license: CC BY-NC-SA 4.0
---

本部分将提供 LR2 的下载方式。

<!--more-->

{{< admonition info 封面出处 >}}
[魔女の彩の庭 - @藤原](https://www.pixiv.net/artworks/69065999)
{{< /admonition >}}

## 立即下载

**不推荐**从官网下载，要求新人从最原始的版本开始配置实在有点强人所难。总之，我们已经制作好了开箱即用的 LR2 整合包，内置了所有你应该会需要的东西。

{{< admonition success "LR2 整合包" >}}

- [:(fas fa-download):  本地下载](https://bms.hakula.xyz) - 新人请进 /【启动器】Lunatic Rave 2
- [:(fas fa-cloud):  百度云](https://pan.baidu.com/s/17J8SD82VemKUS0OW2c3y-w) - **fcn6**

由 @Hakula 整合，最后更新：2018-09-23

{{< /admonition >}}

如遇到链接失效等问题或者有任何疑问，请直接在本文评论区留言。

{{< admonition warning 注意 >}}
放置 LR2 的路径不能包含中文等全角字符。
{{< /admonition >}}

{{< admonition example 本整合包已内置 >}}

- 4 GB 内存补丁
  - 缓解 4 GB 及以上内存的电脑可能遇到的程序崩溃问题
- Fast / Slow 补丁
  - 在 WMIX 的游玩界面和结算界面分别显示 Fast / Slow 指示和统计信息
  - 需手动开启
- HD 补丁（720P）
  - 以支持 WMIX 等高分辨率皮肤
- WMIX 皮肤 - @MsrButterfly 改
  - 在 WMIX 的结算界面显示 Combo Break 统计信息及当前游玩模式等额外信息
  - 需手动开启
- 皮肤转换工具
  - 位于 `LR2files/Theme`，用于修改皮肤分辨率
- 東方ハードコアβ 背景音乐 + 音效
  - 如无法正常使用请转区
- 测试用 BMS
  - *started* - Ym1024 feat. lamie*
  - *紅月夜想 ～Scarlet Nocturne～* - nmk feat. °Ciel

{{< /admonition >}}

## 准备工作 - 转区

### Locale Emulator

在打开游戏前，推荐先使用 Locale Emulator 将 LR2 转到日本区（可选）。

{{< admonition tip 参考 >}}
[Locale Emulator 使用教程](https://xupefei.github.io/Locale-Emulator)
{{< /admonition >}}

### 全局转区

如果 Locale Emulator 没有效果，可以通过控制面板将系统全局转到日本区。

{{< image src="assets/system-locale.webp" caption="全局转区" >}}

全局转区的弊端是之后运行其他程序（例如记事本、汉化版 Galgame）时可能会出现乱码，不过我们可以再对这些程序使用 Locale Emulator 转回中国区，这样这个问题就解决了。

### 为什么要转区

因为 LR2 使用的是日文编码（Shift-JIS），而大多数国内玩家的 Windows 系统使用的是中文编码（GB2312），于是在导入 BMS 或 Custom Folder 时，如果文件名中存在非英文、数字的字符（中文、日文、特殊字符等），就可能导致导入失败、谱面无声、显示乱码等各种问题。

建议还是转一下区，当然不转区也能玩就是了，遇到问题请参考 [FAQ](../faq)。
