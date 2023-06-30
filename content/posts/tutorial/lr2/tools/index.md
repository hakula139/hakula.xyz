---
title: LR2 配置教程 - 辅助工具
date: 2019-07-20T02:47:00+08:00

tags: [BMS, LR2]
categories: [tutorial]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/72296053.webp
license: CC BY-NC-SA 4.0
---

一些辅助工具 / 网站的介绍及使用说明。

<!--more-->

{{< admonition info 封面出处 >}}
[レミリア - @吉岡よしこ](https://www.pixiv.net/artworks/72296053)
{{< /admonition >}}

## Walkure

> [発狂 BMS 難度推定など - walkure.net](http://walkure.net/hakkyou/index.html)

Walkure 是一个基于 LR2IR 的辅助网站，提供了谱面难度推定、玩家实力值推定等实用功能。

{{< admonition warning 注意 >}}
SP 発狂 BMS 玩家限定，「实力值推定」需要达成至少一个 SP★01 Easy Clear 及以上的成绩才能使用。
{{< /admonition >}}

### 难度推定

> [発狂 BMS 難度推定表 - walkure.net](http://walkure.net/hakkyou/bms.html)

基于 LR2IR 上的玩家成绩大数据，对发狂表内谱面、Overjoy 表内谱面和发狂段位的难度进行了相对更精确的推定。不定时更新，仅供参考。

{{< admonition note 说明 >}}

- 如果无人通过，难度推定处将留空。
- 已达成 Hard Clear 的谱面将被同时判定为已达成 Normal Clear，但实际上 Normal Clear 比 Hard Clear 更难的情况是可能发生的（例如 SP★★6 unhappy century），此时 Normal Clear 的难度推定将不准确。对于个别 Normal Clear 比 Full Combo 更难的情况同理（例如 SP★★4 Heart To Heart -collect sky blue-）。

{{< /admonition >}}

#### 难度

「难度」指的是以 Easy Clear 为基准的推定通过难度。例如，一个谱面 Hard Clear 的推定难度为 ★4.00，即表示其难度与 Easy Clear 一个标准 ★4 谱面的难度相同。

{{< admonition tip 题外话 >}}

- 发狂表的评级以 Normal Clear 为基准
- Satellite / Stella 表的评级以 Easy Clear 为基准

你之后就会理解这意味着什么（

{{< /admonition >}}

#### 地力谱面度

「地力谱面度」反映的是一个谱面的个人差程度。一个谱面的地力谱面度越高则越倾向于地力谱面，反之则越倾向于个人差谱面。通常地力谱面度较低的谱面可能包含这些要素：纵连、连皿、拍砖、高 Total。[^1]

一般地力谱面的通过情况更能反映一位玩家的实力。建议大家多玩地力谱面度高的谱面，对实力的提升更有帮助。

### 实力推定

> [「リコメンド」 - walkure.net](http://walkure.net/hakkyou/recommended.html)

基于玩家已通过和未通过[^2]的谱面，推定玩家的实力值。**仅供参考。**

{{< admonition note 说明 >}}

- 未游玩的谱面不会参与实力推定
- 地力谱面度越高的谱面权重越大

{{< /admonition >}}

#### 更新数据

使用本功能前需要先更新 IR 数据，以下提供两种方案。

##### 一键更新

> [リコメンド更新 URL 発行 - pasta-soft](https://pasta-soft.com/bms/recommend.php)

输入 LR2ID 后，点击 Show 即可。

##### Bookmarklet

首先将以下内容保存为浏览器书签：

```js
javascript: (function () {
  if (
    location.href.indexOf('http://www.dream-pro.info/~lavalse/LR2IR/search.cgi') === 0 &&
    document.body.innerHTML.match(/guestmode=1/)
  ) {
    const s = document.createElement('script');
    s.src = 'http://walkure.net/hakkyou/lib/s.js';
    document.body.appendChild(s);
  } else {
    alert('请先登录到 LR2IR，然后在个人页面下点击本书签');
  }
})();
```

然后进入 LR2IR 的个人页面（已登录状态、非访客模式），点击此书签即可。

如果点击后，浏览器打开了一个新页面，说明你的浏览器可能不支持 Bookmarklet。还是尽早更换 Chrome 等现代浏览器吧！

#### 个人页面

数据更新后，浏览器将自动跳转到你的个人页面。

> [Hakula♪ の個人データ - 「リコメンド」 - walkure.net](http://walkure.net/hakkyou/recommended_mypage.html?playerid=122423)

{{< image src="assets/walkure/my-page.webp" caption="Walkure - 个人页面" >}}

「あなたの実力」就是你当前的实力值，表示 Walkure 认为你有 50% 的概率通过这个 [难度](#难度) 的谱面。下方的「リコメンド」和「逆リコメンド」分别表示「推荐」和「逆推荐」。

##### 推荐

在「推荐」页面中，Walkure 根据其 [推荐度模型](#推荐度) 推荐了一些目标课题，右侧显示推定的通过概率（推荐度）。

{{< image src="assets/walkure/recommendations.webp" caption="Walkure - 推荐" >}}

##### 逆推荐

在「逆推荐」页面中，Walkure 列出了所有你通过的难度高于你当前实力值的谱面，右侧显示推定的通过概率。

这些基本属于 Walkure 不认为你能通过但你却神秘通过了的谱面，~~可以用来装逼 :sunglasses:（然后被人[骂]^(kuā) sb）~~。

{{< image src="assets/walkure/reverse-recommendations.webp" caption="Walkure - 逆推荐" >}}

##### 推荐度

{{< admonition note 推荐度模型介绍 false >}}

Walkure 的推荐度模型基于 [项目反应理论][irt-wiki]：

$$ p(\theta) = \frac{1}{1+e^{-a(\theta-b)}} $$

其中，$p$ 为玩家通过谱面的概率，$\theta$ 为玩家的实力值，$a$ 为谱面的地力谱面度，$b$ 为谱面的难度。

{{< image src="assets/walkure/irt.webp" caption="通过概率" >}}

如图，横坐标为玩家的实力值 $\theta$，纵坐标为通过概率 $p(\theta)$。这里黑色线为 $(a,b) = (3,2)$ 时的曲线，灰色线为 $(a,b) = (3,1),\ (10,2)$ 时的曲线。

可见：

- 玩家的实力值等于谱面的难度时，通过概率为 50%（而不是 100%）。
- 对于同等难度的谱面，地力谱面度越低，实力不够的玩家越有可能（凭借个人差）实现越级点灯。
- 地力谱面就像一道坎，你的实力稍微差一点儿就大概率过不了，但只要实力一到，可能突然就会打了。

[irt-wiki]: https://en.wikipedia.org/wiki/Item_response_theory

{{< /admonition >}}

## 点灯情况

一些网站能够很直观地统计展示玩家各个等级的歌曲通过情况。

### Notepara

> [SP Insane 1 - Notepara](https://www.notepara.com/bms_table/insane1/122423)

除了发狂表外，Notepara 还支持各种第三方表。

{{< image src="assets/lamps/notepara.webp" caption="Notepara" >}}

### pasta-soft

> [BMS Lamp Graph - pasta-soft](https://pasta-soft.com/bms/lamp.php?id=122423&type=insane)

{{< image src="assets/lamps/pasta-soft.webp" caption="Notepara" >}}

## 谱面预览

> [BMS Score Viewer](http://www.ribbit.xyz/bms/score)

BMS 谱面在线预览，支持上传谱面 / 搜索已上传的谱面。

{{< image src="assets/score-viewer.webp" caption="谱面艺术欣赏" >}}

## BeMusicSeeker

BeMusicSeeker 是一个用于管理 BMS 曲包、导入第三方表的辅助工具。别再用 GLAssist 啦！

{{< admonition success 安装包 >}}
[:(fas fa-download):  本地下载](https://files.hakula.xyz/LR2/%E7%9B%B8%E5%85%B3%E8%B5%84%E6%BA%90/BeMusicSeeker.exe)
{{< /admonition >}}

{{< admonition tip 阅读 >}}

[使用 BeMusicSeeker 导入各类表的方法 - 腾讯文档](https://docs.qq.com/doc/DUkV2cFRlTUh2SG94)

感谢 @双子 写的使用教程！

{{< /admonition >}}

[^1]: 当然，你要是各种个人差要素都齐全了，地力谱面度就又高了 :smile:，正所谓全方位的个人差 = 地力。SP★09 愛と煩悩と輪廻と常識の極彩世界 [皿と乱打と階段と縦連の同時押世界]：「嗯嗯嗯嗯对对。」
[^2]: 这意味着如果 Walkure 认为你有该点的灯没点上，也会导致实力值虚低。因此低等级的坏灯和绿灯还是需要清理一下的。
