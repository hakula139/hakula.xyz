---
title: LR2 配置教程 - Result
date: 2019-02-10T20:31:00+08:00

tags: [LR2]
categories: [tutorial]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/59521621.webp
license: CC BY-NC-SA 4.0
---

本部分将介绍 LR2 的结算界面。

<!--more-->

{{< admonition info 封面出处 >}}
[織の檻 - @藤原](https://www.pixiv.net/artworks/59521621)
{{< /admonition >}}

游玩结束，进入结算界面。按鼠标左键 / 键盘回车键 / 手台黑白键退出。

{{< image src="assets/result.webp" caption="结算界面" >}}

## 成绩显示区域

### 血线图

背景是整局游戏过程中的血量变化曲线，中央是本次游玩的 [评价等级](#dj-level)，底部是当前使用的 [血槽设置](https://hakula.xyz/tutorial/lr2_body_select.html#GROOVEGAUGE) 和剩余血量。

### CLEAR TYPE

通过情况。左侧是个人最高纪录，右侧是本次成绩，下同。

{{< admonition bug >}}
当个人最高纪录是 FULL COMBO 时，本次 CLEAR TYPE 总是显示为 FULL COMBO。
{{< /admonition >}}

### DJ LEVEL

评价等级，与 SCORE RATE 的对应关系见下表。

{{< style "table { min-width: 20rem; }" >}}

| DJ LEVEL | SCORE RATE |
| :------- | :--------- |
| AAA      | ≥ 88.88%   |
| AA       | ≥ 77.77%   |
| A        | ≥ 66.66%   |
| B        | ≥ 55.55%   |
| C        | ≥ 44.44%   |
| D        | ≥ 33.33%   |
| E        | ≥ 22.22%   |
| F        | > 0%       |
|          | 0%         |

{{< /style >}}

{{< admonition note 关于边界情况 >}}

你可能会遇到显示 AAA + 0，但评价等级却是 AA 的情况。这是因为你的实际 SCORE RATE < 88.88%，所谓 + 0 只是取整后的结果。

反正就是被性了，你要习惯这个过程。:kissing_heart:

{{< /admonition >}}

{{< admonition note "关于 MAX" >}}
恭喜理论值！:tada: 不过 LR2 的最高评价等级就是 AAA，所以即使 100% 也不会显示 MAX。很遗憾！
{{< /admonition >}}

### EX SCORE

$$\mathrm{EX\ SCORE} = \mathrm{PGREAT}\times 2 + \mathrm{GREAT}$$

别的都是 0 分，哈哈。

### MISS COUNT

$$\mathrm{MISS\ COUNT} = \mathrm{BAD} + \mathrm{POOR}$$

### TARGET

目标分数及本次分数与其的分差，参见 [TARGET](../select/#target)。

### JUDGE DETAIL

#### FAST / SLOW

在皮肤设置里打开 [FAST SLOW VIEW](../wmix/#结算界面) 选项后，这里将显示 Fast / Slow 统计信息。

{{< admonition bug >}}
回放模式下 Fast / Slow 统计数据将不准确。
{{< /admonition >}}

#### COMBO (BREAK)

在皮肤设置里打开 [COMBO BREAK VIEW](../wmix/#结算界面) 选项后，这里将显示 COMBO BREAK 统计信息。

{{< admonition note "与 MISS COUNT 的关系" >}}
[MISS COUNT](#miss-count) 包含空 POOR，而 COMBO BREAK 不包含。
{{< /admonition >}}

{{< admonition note "什么是空 POOR" >}}

空 POOR 是 LR2 里的一种防混机制（源自 Beatmania）。在附近有 note 的情况下，玩家每错误地多按一次键就判定为一个空 POOR，使用 GROOVE 血槽时每个空 POOR 扣 2% 血，不影响连击数。

特别地，如果谱面里有地雷 note，当玩家不慎按到时，按键期间将**持续**产生大量空 POOR，这时空 POOR 就很有杀伤力了。

{{< /admonition >}}

#### INTERNET RANKING

当前 IR 排名。由于网络原因，显示会有一定的延迟。

{{< admonition tip 提高退出速度 >}}
很多玩家遇到过结算界面想退出却退不出去，每次都要等上一段时间才能退出的问题，其原因在于 LR2 在结算界面会尝试拉取本谱的 IR 排行榜数据，阻塞了退出操作。解决方案参见 [FAQ](../faq/#28-结算界面退出时卡住)。
{{< /admonition >}}

#### JUDGE

判定分布。

{{< admonition note "什么是连 BAD" >}}

前面讲到空 POOR 的问题，这里再讲讲连 BAD。

同样出于防混考虑，当一次按键操作被判定为 BAD 后，同轨道的下次按键操作如果落在 GOOD 的判定区间，**将继续被判定为 BAD**，这个惩罚机制我们一般称为连 BAD 机制。

因此当你在打轴、纵连、拍砖这样的键型时，如果注意到某条轨道上有 BAD 发生，一定要及时调整节奏，有时宁可放掉一个 / 一排键也要尽量避免出现持续的连 BAD。

{{< /admonition >}}

#### RATE

$$\mathrm{SCORE\ RATE} = \mathrm{PGREAT}\times 100\\% + \mathrm{GREAT}\times 50\\%$$

其实就是 [EX SCORE](#ex-score) 的百分比表示，决定了你的 [DJ LEVEL](#dj-level)。

## 底栏

在皮肤设置里打开 [EX LEVEL VIEW](../wmix/#结算界面) 选项后，右下角将显示谱面的 EX Level。

{{< admonition info 说明 >}}
在 @MsrButterfly 的修改版 WMIX 中，原 EX Level 处改为显示当前所在的 Folder，以支持第三方难易度表。
{{< /admonition >}}

## 背景图

背景图是可以自定义的，参见 [目录](../directory-structure/#wmix_hd) 篇。

## 进阶

{{< admonition tip 提示 >}}
以下内容为进阶部分，不了解也不影响游玩。
{{< /admonition >}}

### 快速重试

退出结算界面前，**按住**至少一个黑键和一个白键（此时会播放退出动画）直到再次载入游玩界面，即可快速重试。

快速重试不仅可以节省时间，更重要的是可以确保本次的谱型和重试前一致。当你随机到一个好型时，利用快速重试就可以保留这个好型。
