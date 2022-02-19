---
title: LR2 配置教程 - WMIX
date: 2019-02-11T21:29:00+08:00

tags: [LR2]
categories: [tutorial]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/62549069.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

本部分将介绍 LR2 的皮肤设置（WMIX）。

<!--more-->

{{< admonition info 封面出处 >}}
[Infinity Red - @MISSILE228](https://www.pixiv.net/artworks/62549069)
{{< /admonition >}}

在 [Select](../select/#skin--soundset) 篇里我留了一个坑，现在我们来把它填掉。

在 SYSTEM OPTION 页面下点击 SKIN · SOUNDSET 按钮进入皮肤 / 音频设置界面。

{{< image src="assets/skin-customize.webp" caption="SKIN CUSTOMIZE" width="640" >}}

在上方预览区域的左右侧各有一个小箭头，可以切换到其他皮肤。

## 选曲界面

点击 MUSIC SELECT 标签进入选曲界面设置。

| 选项                   | 含义                                   |
| :--------------------- | :------------------------------------- |
| back brightness        | 背景亮度（百分比越低，亮度越低）       |
| Wallpaper              | 背景图[^1]                             |
| Wallpaper transparency | 背景图透明度（百分比越低，透明度越高） |
| Movie                  | *不懂，欢迎评论区补充*                 |
| Shutter                | 切换界面时的过渡动画                   |
| Clock                  | 是否显示时钟（底端中间）               |
| BEAM                   | 是否显示扫描线动画效果                 |
| banner                 | 是否显示歌曲的横幅图（如果有）         |

## 游玩界面

点击 SEVEN KEYS 标签进入 7K 模式的游玩界面设置，其他模式同理。WMIX 的游玩界面有 AC 和 WIDE 两个版本，可以自行选择。

| 选项                 | 含义                                           |
| :------------------- | :--------------------------------------------- |
| PLAY SIDE            | 选择 1P / 2P 侧                                |
| Lane darkness        | 谱面显示区域的轨道亮度（百分比越高，亮度越低） |
| Display judge        | 是否显示判定分布                               |
| Display judge timing | 是否显示判定延迟及其显示位置                   |
| Display FAST / SLOW  | 是否显示 Fast / Slow 指示及其显示位置          |
| GRAPH SIDE           | 是否显示 SCORE GRAPH 及其显示位置              |
| loading ACTION       | 加载谱面时的动画                               |
| LAST NOTE ACTION     | 谱面结束时的动画                               |
| BGA Brightness       | BGA 亮度（百分比越低，亮度越低）               |
| BG                   | 背景图[^1]                                     |
| FRAME BG             | 框架背景图                                     |
| NOTES                | note 的样式                                    |
| BOMB                 | 打击光效的样式                                 |
| LANECOVER            | 挡板图                                         |
| Turntable            | 皿的样式                                       |
| LASER                | 打击光柱的样式                                 |
| FC effect            | 达成 FULL COMBO 时的结束动画                   |
| keyflash             | 按键时黑白键的颜色                             |
| progress bar         | 进度条的颜色                                   |
| JUDGE                | 判定指示的样式                                 |
| GAUGE COLOR          | 血槽的颜色                                     |
| CLOSE                | STAGE FAILED 时的闭店动画                      |

{{< admonition bug >}}
游玩界面的 GAUGE COLOR 和 CLOSE 在重启游戏 / 重进设置界面后可能会被误改成其他选项。
{{< /admonition >}}

## 决定界面

点击 DECIDE 标签进入决定界面设置。

| 选项       | 含义                           |
| :--------- | :----------------------------- |
| BG         | 背景图[^1]                     |
| STAGE FILE | 是否显示歌曲的封面图（如果有） |

## 结算界面

点击 RESULT 标签进入结算界面设置。

| 选项                     | 含义                                    |
| :----------------------- | :-------------------------------------- |
| side                     | 选择 1P / 2P 侧                         |
| clear type playskin link | 选 ON                                   |
| chart COLOR link (W‑MIX) | 选 OFF                                  |
| CLOSE shutter            | 选 WMIX-SELECT LINK                     |
| Shutter (W‑MIX)          | 切换界面时的过渡动画                    |
| Shutter (EC‑SE)          | 无视（需 Endless Circulation 皮肤）     |
| battle skin              | 是否启用 Battle 模式皮肤                |
| Song data                | 是否显示 SONG DATA                      |
| clear / failed image     | CLEAR / FAILED 的背景图[^1]             |
| A / AA / AAA clear       | A / AA / AAA 的背景图，将覆盖上一个设置 |
| DJ LEVEL                 | 评价等级的样式                          |
| NUMBER COLOR             | 数字的颜色                              |
| chart COLOR (link off)   | 血线图的背景颜色                        |
| FAST SLOW VIEW           | 是否显示 Fast / Slow 统计               |
| COMBO BREAK VIEW         | 是否显示 COMBO BREAK 统计               |
| EX LEVEL VIEW            | 是否显示 EX Level                       |

## 段位 / Course 结算界面

点击 COURSE RESULT 标签进入段位 / Course 的结算界面设置。与 RESULT 类似，此处不再赘述。

## 音频

点击 SOUNDSET 标签进入音频设置。

| 选项               | 含义                                    |
| :----------------- | :-------------------------------------- |
| SELECT BGM         | 选曲界面的背景音乐[^2]                  |
| CLEAR / FAILED BGM | CLEAR / FAILED 时进入结算界面的音效[^3] |

[^1]: 自定义方式参见 [目录](../directory-structure/#wmix_hd) 篇 WMIX_HD 部分。
[^2]: 自定义方式参见 [目录](../directory-structure/#bgm) 篇 Bgm 部分。
[^3]: 自定义方式参见 [目录](../directory-structure/#sound) 篇 Sound 部分。
