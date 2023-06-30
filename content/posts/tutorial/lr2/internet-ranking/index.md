---
title: LR2 配置教程 - LR2IR
date: 2019-04-02T16:26:00+08:00

tags: [BMS, LR2]
categories: [tutorial]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/59288952.webp
license: CC BY-NC-SA 4.0
---

本部分将介绍 LR2IR，LR2 的线上排行榜。

<!--more-->

{{< admonition info 封面出处 >}}
[Juliet - @CinEraLiA](https://www.pixiv.net/artworks/59288952) @ [BOFU2016](https://manbow.nothing.sh/event/event.cgi?action=More_def&num=461&event=110)
{{< /admonition >}}

得益于此，LR2 存活至今。

> [LR2 internet ranking](http://www.dream-pro.info/~lavalse/LR2IR/search.cgi)

网址并不好记，也不容易搜到，因此建议保存个书签。

LR2IR 实际上并不是 LR2 的官网，现在却起着官网的作用。至于官网在哪里？早就没啦！

{{< image src="assets/lr2ir.webp" caption="LR2IR" >}}

## 个人页面

首先在顶栏输入你的 [LR2ID](../body/#进入游戏) 和 [密码](../launcher/#注册) 登录，然后点击导航栏的「マイページ」进入个人页面。

{{< image src="assets/my-page.webp" caption="个人页面" >}}

### Player Status

| 名称             | 含义                                              |
| :--------------- | :------------------------------------------------ |
| プレイヤー名     | IR 上显示的玩家名，与本地用户名无关               |
| LR2ID            | 玩家 ID，初次连接 IR 时获得，此后不可变更         |
| 段位認定         | 斜杠两侧分别为当前通过的最高 SP / DP 段位[^skill] |
| 自己紹介         | 个人介绍                                          |
| ホームページ     | 个人主页                                          |
| プレイした曲数   | 游玩过的歌曲总数                                  |
| プレイした回数   | 总游玩次数（Play Count）                          |
| ライバル         | Rival，可以看作是好友                             |
| 逆ライバル       | 添加你为 Rival 的玩家                             |
| 情報公開レベル   | 信息公开级别（隐私设置）                          |
| スコアキャッシュ | 成绩缓存[^score-cache]                            |

点击上方的「ゲストモードで見る」查看访客视角的个人页面，点击下方的「更新」按钮保存信息。

[^skill]: 其中 - 为无段位、☆ 为通常段位、★ 为发狂段位、(^^) 为 Overjoy 段位。
[^score-cache]: 关闭后可大幅提高 LR2 结算界面的退出速度，详见 [Result](../result/#internet-ranking) 篇。

### 统计信息

Player Status 下方是一些歌曲 / 段位 / Course 的游玩情况，如果不想公开可以将 Player Status 里的「情報公開レベル」设置为你希望的隐藏级别。

| 名称                 | 含义                       |
| :------------------- | :------------------------- |
| クリア曲数           | 歌曲通过情况[^clear-count] |
| よくプレイする曲     | 单曲游玩次数排行           |
| 最近プレイした曲     | 最近游玩的曲目             |
| 最近プレイしたコース | 最近游玩的段位 / Course    |

点击下方的「続きを見る」查看更多。

[^clear-count]: 事实上，查看歌曲通过情况我们有更好的选择，参见 [辅助工具](../tools/#点灯情况) 篇。

### 一行 BBS

留言区，在 [首页](http://www.dream-pro.info/~lavalse/LR2IR/search.cgi) 的「ラウンジ」里也会公开展示全站的最新留言。点击「書き込む」按钮提交留言，点击「書き込み削除」删除自己的留言，但不能删除别人的留言。

{{< admonition tip >}}
LR2IR 会自动将留言里出现的 `[bmsid]` 转换为相应谱面的 IR 页面链接。其中 bmsid 的值参见谱面的 IR 页面地址，例如 [SP★19 End Time -to the death-](http://www.dream-pro.info/~lavalse/LR2IR/search.cgi?mode=ranking&bmsid=79999) 的 bmsid 就是 79999。
{{< /admonition >}}

## 添加 Rival

首先到对方的 IR 个人页面。例如我的个人页面在 [这个地址](http://www.dream-pro.info/~lavalse/LR2IR/search.cgi?mode=mypage&playerid=122423)，那么将地址最后的 `122423` 改为对方的 LR2ID，就得到了对方的个人页面地址。随后点击 Player Status 下方的「ライバルリストに追加」按钮即可添加 Rival。在已添加 Rival 的情况下，点击相同位置的「ライバルリストから削除」按钮即可删除 Rival。

之后浏览器将自动跳转到你的个人页面，可以看到 Player Status 里的「ライバル」栏已经添加 / 删除了对方的名字。相应的，添加你为 Rival 的玩家将出现在下面的「逆ライバル」栏。

添加 Rival 后，在 LR2 的选曲界面将出现部分 Rival 的 Rival Folder。在此 Folder 里可以看到 Rival 的所有纪录、可以看到自己与 Rival 在各个谱面的分差、可以发起 [G-BATTLE](../select/#g-battle) 等等。

## 上传纪录

{{< admonition warning 注意 >}}
本地纪录上传到 IR 时，默认是**直接上传本地最高纪录，而不会与线上纪录进行比对**。也就是说，如果本地最高纪录**低于** IR 上的纪录，IR 上的纪录**将被直接覆盖**。如果你需要同时在不同的电脑 / 本体上游玩 LR2，并且没有自行同步数据库，则请务必注意这一点，以避免不必要的损失。
{{< /admonition >}}

## 删除纪录

进入谱面的 IR 页面，点击成绩栏上方的「スコア削除」即可删除线上纪录，删除本地纪录的方法参见 [Select](../select/#搜索框) 篇。

{{< image src="assets/score.webp" caption="删除纪录" >}}

初次删除纪录时，LR2IR 会提示需要先修改一次密码（点击页面顶栏的「パスワード変更」）。修改 IR 密码后，本地可能需要删除数据库[^database]并重新继承数据[^register]，否则 LR2 要么无法连接到 IR，要么无法访问数据库（如果你修改了本地密码）。当然，方便起见，你也可以选择修改成别的密码后再直接改回原密码，就无需进行上述操作。

修改过一次密码后，之后删除纪录时只需验证当前密码即可。

[^database]: 其位置参见 [目录](../directory-structure/#database) 篇。**先备份**，然后删除 `Score` 文件夹里的 `用户名.db`。
[^register]: 参见 [启动器](../launcher/#注册) 篇。你需要确保所有希望保留的成绩数据**已上传**到 LR2IR。

## 全网搜索

在导航栏下方的搜索框里输入关键词，点击「検索」即可进行全网搜索。

下方的 4 种搜索方式依次为：关键词搜索、按标签搜索、玩家搜索、段位 / Course 搜索。

## 発狂 BMS 检索

点击导航栏的「発狂 BMS」可以看到目前的发狂表全曲。如果想快速查看一首发狂表内歌曲的基本信息或个人纪录，就可以在这里检索。

## 段位认定

点击导航栏的「段位認定」可以查看当前官方段位（GENOSIDE 2018 段位認定）的考核曲目及各段位的通过人数和通过率。

你可以在本页面下载官方段位的 Course 文件。其中「シングル」为 SP 段位，「ダブル」为 DP 段位，每栏的第一个链接包含所有通常段位，第二个链接包含所有发狂段位和 Overjoy 段位。或者，你也可以选择在 [这里][courses] 下载 @MsrButterfly 整合好的官方段位 Course 文件，以及各种第三方段位的 Course 文件。

[courses]: https://github.com/MsrLab-org/LR2IRCourses
