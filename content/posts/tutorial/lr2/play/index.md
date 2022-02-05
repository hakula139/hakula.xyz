---
title: LR2 配置教程 - Play
date: 2019-01-20T21:46:00+08:00

tags: [LR2]
categories: [tutorial]
featuredImage: /images/article-covers/61930743.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

本部分将介绍 LR2 的游玩界面。

<!--more-->

{{< admonition info 封面出处 >}}
[和洋折衷ライブラリー - @藤原](https://www.pixiv.net/artworks/61930743)
{{< /admonition >}}

{{< image src="assets/decide.webp" caption="决定界面" width="1280" >}}

这是 WMIX 的决定界面。从现在起按键盘 `Esc` 键 / START + SELECT 键可以中途退出。

{{< image src="assets/play.webp" caption="游玩界面" width="1280" >}}

此后我们就进入了 WMIX 的游玩界面。你看到的界面很可能与图中有许多不同，这是因为 WMIX 有很多可以自定义的地方，详见 [WMIX](../wmix) 篇。

{{< admonition warning 注意 >}}

**中途退出时，只要当前有非 POOR 的判定就将进入结算界面。如果谱面尚未打完，则直接判定为 FAILED。**

无论结尾还有多少个 note 没打，都不会按照剩余 note 数量扣血，而是血槽**直接归零**。因此请务必确认谱面已经结束再按 `Esc` 键。

如果当前所有判定均为 POOR，则不进入结算界面直接退出，本局不计入 Play Count。

{{< /admonition >}}

{{< admonition tip 关于暂停 >}}
不同于许多音游，LR2 **不存在**暂停功能。
{{< /admonition >}}

## 谱面显示区域

如图所示，`GREAT 489` 即当前的判定指示和连击数，`-0003` 即与 [目标分数](../select/#target) 的分差[^ghost-position]，`+007` 即当前的 [判定延迟](../select/#judge-timing)。在皮肤设置里可以开启 Fast / Slow 指示，开启后将显示在 `-0003` 的右侧。

{{< admonition bug >}}
回放模式下不显示 Fast / Slow 指示。
{{< /admonition >}}

## SCORE GRAPH

参见 [SCORE GRAPH](../select/#score-graph)。

## 按键操作

| 按键                   | 按键          | 作用              |
| :--------------------- | :------------ | :---------------- |
| START + 2 / 4 号键     | :arrow_up:    | 提高 HI-SPEED     |
| START + 1 / 3 / 5 号键 | :arrow_down:  | 降低 HI-SPEED     |
| START + 6 号键         | :arrow_left:  | 提高挡板[^sudden] |
| START + 7 号键         | :arrow_right: | 降低挡板[^sudden] |
| 双击 START             |               | 开关挡板[^sudden] |
| START + SELECT         | `Esc`         | 退出游玩界面      |

{{< image src="assets/tip.webp" caption="温馨小贴士" width="360" >}}

## 进阶

{{< admonition tip 提示 >}}
以下内容为进阶部分，不了解也不影响游玩。
{{< /admonition >}}

### 数字键

按住数字键后，按 :arrow_up: :arrow_down: :arrow_left: :arrow_right: 键调整。

{{< style "table { min-width: 20rem; }" >}}

| 按键 | 作用                                     |
| :--- | :--------------------------------------- |
| `1`  | 整体平移画面                             |
| `2`  | 整体缩放画面                             |
| `3`  | 平移判定指示位置                         |
| `4`  | 调整 note 宽度和厚度                     |
| `5`  | 开启 [DARK 模式](#dark-模式)             |
| `6`  | 平移 1P 谱面显示区域，**可以当 LIFT 用** |
| `7`  | 平移 2P 谱面显示区域                     |

{{< /style >}}

### DARK 模式

DARK 模式可以隐藏画面里的部分素材，减少对读谱的干扰，十分有用。

按住 `5` 键后，按一次 :arrow_right: 键进入 DARK 1 模式：

{{< image src="assets/play-dark1.webp" caption="游玩界面（DARK 1）" width="1280" >}}

再按一次进入 DARK 2 模式：

{{< image src="assets/play-dark2.webp" caption="游玩界面（DARK 2）" width="1280" >}}

我个人比较习惯使用 DARK 1 模式。

[^ghost-position]: 其显示位置取决于 [GHOST POSITION](../select/#ghost-position)。
[^sudden]: 需开启 [SUDDEN+](../select/#sudden)。
