---
title: LR2 配置教程 - Select
date: 2019-01-14T21:42:00+08:00

tags: [LR2]
categories: [tutorial]
featuredImage: /images/article-covers/65262289.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

本部分将介绍 LR2 的选曲界面。很大一部分游戏内设置都位于这个界面，其中也包括游玩界面的键位设置。

<!--more-->

{{< admonition info 封面出处 >}}
[あなたがいる世界に私も生きてる - @藤原](https://www.pixiv.net/artworks/65262289)
{{< /admonition >}}

{{< image src="assets/folder-list.webp" caption="目录列表" width="100%" >}}

{{< image src="assets/song-list.webp" caption="选曲列表" width="100%" >}}

这是 WMIX 的选曲界面。按鼠标左键 / 键盘 :arrow_right: 键 / 回车键 / 手台白键进入，按鼠标右键 / 键盘 :arrow_left: 键 / 手台 2 或 4 号键返回，按 `Esc` 键退出游戏。

下面我们分区域进行讲解。

## 最左侧

### PLAY OPTION

{{< image src="assets/left/play.webp" caption="PLAY OPTION" width="100%" >}}

这些设置除了可以用鼠标点击来调整，也可以通过键盘 / 手台的对应按键调整（参考 IIDX）。

#### LANE OPTION

| 选项        | 别称  | 存分        | 含义                                                    |
| :---------- | :---- | :---------- | :------------------------------------------------------ |
| OFF         | 正规  | 是          | 原始谱面                                                |
| MIRROR      | 镜像  | 是          | 键盘区谱面镜像翻转[^mirror]                             |
| RANDOM      | 随机  | 是          | 键盘区谱面随机交换轨道顺序[^random]                     |
| S‑RANDOM    | S‑RAN | 是          | 键盘区每个 note 随机出现在任意轨道[^s-ran]              |
| H‑RANDOM    | H‑RAN | 否[^assist] | S‑RANDOM 基础上，尽可能避免纵连[^h-ran]                 |
| ALL‑SCRATCH | 全皿  | 否          | RANDOM 基础上，将键盘区的 note 尽可能移进皿区[^all-scr] |

一些隐藏选项参见 [进阶](#8k-lane-option) 部分。

[^mirror]: 1 ~ 7 号轨道分别对应原来的 7 ~ 1 号轨道。
[^random]: 1 ~ 7 号轨道分别对应原来的比如 2 5 7 3 6 1 4 号轨道。发狂后常用，但请不要过度依赖。
[^s-ran]: 不常用，偶尔用于一些键型比较单纯的纵连 / 拍砖谱。
[^assist]: 不保存分数，任意模式下通过均判定为 Easy Clear。
[^h-ran]: 原版皮肤里称为 SCATTER。不常用。
[^all-scr]: 原版皮肤里称为 CONVERGE。不常用，有些玩家利用这个模式练习连皿和复合皿。

#### SUDDEN+

上挡板开关，用于调节可视区域的范围，常用于变速谱中的低速段。我们将在 [Play](../play/#按键操作) 篇讲解挡板的使用方法。

{{< admonition tip "To IIDX 玩家" >}}
LR2 没有 HIDDEN+（下挡板）和 LIFT。毕竟 LR2 诞生时，IIDX 才刚出到 16 EMPRESS (2008)。
{{< /admonition >}}

#### GROOVE GAUGE

游玩歌曲后，系统将保存你的通过情况和分数。不同模式对应不同的通过条件，通过后也会在选曲列表的歌曲标题处点亮不同颜色的灯。当一个文件夹内所有歌曲均点上某个颜色的灯后，该文件夹也将点上对应颜色的灯[^folder-lamp]。

| 模式     | 点灯 | 通过情况          | 通过条件                                                                                                    |
| :------- | :--- | :---------------- | :---------------------------------------------------------------------------------------------------------- |
| GROOVE   | 黄灯 | Normal&nbsp;Clear | 初始血量 20%，结束时达到 80% 通过，回血速度与 Total[^total] 有关。游玩过程中血量最低掉到 2%，不会终止游戏。 |
| EASY     | 绿灯 | Easy&nbsp;Clear   | 通过条件同 GROOVE，但掉血更慢、回血更快。                                                                   |
| HARD     | 白灯 | Hard&nbsp;Clear   | 初始血量 100%，掉血更快、回血更慢，掉血速度与 Total 有关。游玩过程中血量掉到 0% 即死，撑到结束通过。[^hard] |
| HAZARD   | 彩灯 | Full&nbsp;Combo   | 通过条件同 HARD，但出现 BAD / POOR 即死、空 POOR 不掉血。其他模式下全连同样判定为 Full Combo。[^hazard]     |
| P‑ATTACK | 彩灯 | ★Full&nbsp;Combo  | 通过条件同 HARD，但出现 GOOD / BAD / POOR / 空 POOR 即死、GREAT 掉血、PGREAT 回血。[^p-attack]              |
| G‑ATTACK | 白灯 | Hard&nbsp;Clear   | 通过条件同 HARD，但 **GOOD** 回血、其余判定均掉血。这是什么沙雕模式？:sweat_smile:                          |
| 任意     | 坏灯 | Failed            | 未通过。                                                                                                    |

{{< admonition tip "To IIDX 玩家" >}}
LR2 没有 ASSISTED‑EASY 和 EX‑HARD 模式。
{{< /admonition >}}

删除本地纪录的方法参见 [这里](#搜索框)，删除线上纪录的方法参见 [LR2IR](../internet-ranking/#删除纪录) 篇。

[^folder-lamp]: 需开启 [Folder lamp](../launcher/#option)。
[^total]: 谱面自身属性。其定义为所有 note 均判定为 (P)GREAT 时，在 GROOVE 模式下的总回血量。
[^hard]: 原版皮肤里称为 SURVIVAL。
[^hazard]: 原版皮肤里称为 DEATH。
[^p-attack]: 在 LR2 里和 Full Combo 无区别，在 LR2IR 上将显示为 ★Full Combo。

#### EFFECT

{{< style "table { min-width: 460px; }" >}}

| 选项      | 含义                              |
| :-------- | :-------------------------------- |
| SUDDEN    | 50% 上隐                          |
| HIDDEN    | 50% 下隐                          |
| SUD + HID | SUDDEN + HIDDEN，基本等同于全隐了 |

{{< /style >}}

由于不能调节可视区域的范围，这个选项没什么实用价值，还是设置为 OFF 吧。

如果你需要上隐，直接用上挡板就可以了；如果你需要下隐，可以考虑修改挡板的素材图[^lane-cover]，将需要下隐的部分以外的区域改成透明色，然后在游玩界面将挡板拉到底即可。

[^lane-cover]: 位于 WMIX 皮肤根目录下的 `play/parts/lanecover`。

#### ASSIST

免盘开关，开启后皿就不用管了，既不影响血量也不算分。当然，最终分数也不保存。

「皿曲是发狂表的一环，不爽不要玩」.jpg

#### STYLE

| 选项     | 游戏模式           | 参照游戏            |
| :------- | :----------------- | :------------------ |
| 7KEY     | 7K 键盘 + 1 皿     | Beatmania IIDX (SP) |
| 5KEY     | 5K 键盘 + 1 皿     | Beatmania (SP)      |
| 9KEY     | 9K 键盘            | pop'n music         |
| 14KEY    | 单人双侧 7KEY 模式 | Beatmania IIDX (DP) |
| 10KEY    | 单人双侧 5KEY 模式 | Beatmania (DP)      |
| SINGLE   | 7KEY / 5KEY / 9KEY |                     |
| DOUBLE   | 14KEY / 10KEY      |                     |
| ALL KEYS | 全部模式           |                     |

本选项的作用就是筛选出指定模式下的谱面。

#### TARGET

{{< style "table { min-width: 460px; }" >}}

| 选项       | 含义                             |
| :--------- | :------------------------------- |
| NO TARGET  | 无目标                           |
| MY BEST    | 以当前自己的最高纪录为目标       |
| RANK AAA   | 以 AAA (88.88%) 为目标           |
| RANK AA    | 以 AA (77.77%) 为目标            |
| RANK A     | 以 A (66.66%) 为目标             |
| DEFAULT    | 使用 [默认目标](#default-target) |
| IR TOP     | 以当前 IR 第一名的纪录为目标     |
| IR NEXT    | 以当前 IR 前一位的纪录为目标     |
| IR AVERAGE | 以当前 IR 的中位分数为目标       |

{{< /style >}}

设定目标后，在游玩界面[^ghost-position]和结算界面将显示与目标分数的差距。

{{< admonition note 注意 >}}
BATTLE 模式下默认目标为对手的当前分数，此时本选项无效。
{{< /admonition >}}

[^ghost-position]: 需开启 [GHOST POSITION](#ghost-position)。

#### BATTLE

除了 G-BATTLE，其他模式个人觉得没有多大意义，此处从略。以下只介绍本选项中的 G-BATTLE 模式。

##### G-BATTLE

G-BATTLE 是一个独特且实用的对战模式。它可以通过 LR2IR 服务器上存储的纪录数据[^ir-record]，模拟一局和纪录持有者的实时对战，在游玩过程中你可以看到自己和对手的实时分差。更重要的是，对战使用和纪录**完全相同的谱面**和 [GROOVE GAUGE](#groove-gauge)。这意味着你可以利用这个特性来借用别人（或自己）之前随机到的好型，而很多时候一个好型确实能省不少事，甚至能助你越级点灯[^why-random]。比如我在九段时绿的 [SP★14 orion ring -IR-][orion-ring]，就是 G-BATTLE @雪凛 点上的。还有像更著名的 SP★20 銀の風[^gin-no-kaze]：「你再把我随成对拍，我就要举报你了」.jpg

使用 G-BATTLE 首先需要连接到 IR 并开启这里的 G-BATTLE 选项，然后在选曲界面选择需要 G-BATTLE 的歌曲，尝试按住 4 号键[^key-4]调出 IR 排行榜，滚动列表选择需要 G-BATTLE 的玩家进入游戏，这样就进入 G-BATTLE 模式了。当然，这个先后顺序也可以反过来。你可以先添加需要 G-BATTLE 的玩家为 Rival，然后在选曲界面进入这位玩家的 Rival Folder[^rival-folder]，选择需要 G-BATTLE 的歌曲进入游戏。

{{< admonition note 注意 >}}
G-BATTLE 模式下，游玩界面使用的是 BATTLE 模式的皮肤，需要另行设定。
{{< /admonition >}}

{{< admonition bug >}}
如果你开启了 [AUTO ADJUST](#auto-adjust)，需注意 G-BATTLE 模式下游玩过程中自动调整后的延迟是不保留的。此外，如果你 G-BATTLE 的谱面开启了 [LANE OPTION](#lane-option)，那么回放也有一定概率不能正常保存。
{{< /admonition >}}

[orion-ring]: https://www.bilibili.com/video/BV1dx411t7M4
[gin-no-kaze]: https://www.bilibili.com/video/BV1F4411L7Zw
[gin-no-kaze-random]: https://www.bilibili.com/video/BV1Ys411y7xM

[^ir-record]: 其中记录了玩家游玩时的每一次按键操作和每个 note 的判定 / 得分情况。
[^why-random]: 这主要是因为有些谱面正规和随机的难度差距太大，有时可能随一个好型，难度能降 5 级以上。
[^gin-no-kaze]: 对比同一个谱面的 [正规][gin-no-kaze] 和 [随机][gin-no-kaze-random] 版本，注意尾杀部分。
[^key-4]: 如果 4 号键是空格键，可以先按住 Start 键再按空格键，也可以另外设置一个 4 号键。这里由于需要下载 IR 排行榜数据，可能需要等待一段时间。
[^rival-folder]: 如果你的 Rival 较多，由于 LR2 每次启动时只会随机加载其中一部分的数据，你可能需要通过反复重启来刷出想要的 Rival。

#### HI-SPEED

HI-SPEED 就是游玩界面里 note 的下落速度[^hi-speed]。新手可以先从较低的下落速度开始，熟悉键位后再慢慢提高速度。至于最后稳定在多快的下落速度比较好，因人而异，适合自己的就是最好的。没有下落速度越快就越强的说法。

{{< admonition note 对判定的影响 >}}
不同于有些音游，BMS 的判定机制是时间判定而非距离判定，因此谱面的 BPM 和游戏设置里的 HI-SPEED 都**不会**影响判定难度。BMS 的判定难度只和谱面自身属性 Judge Rank 有关。
{{< /admonition >}}

[^hi-speed]: 准确地说，应该是和 [Base speed](../launcher/#option) 的比率。

#### HI-SPEED FIX

由于 BMS 里 note 的下落速度与 BPM 成正比[^negative-bpm]，不同谱面的默认下落速度往往也是不同的。如果每次游玩前都要先根据谱面的 BPM 调整一下 HI-SPEED，显然太麻烦了。这时我们就可以利用这个选项，根据指定的对齐规则统一不同谱面的下落速度，而无需手动调整 HI-SPEED。开启本选项后，HI-SPEED 表示以 150 BPM 为基准的 note 下落速度。

| 选项     | 存分 | 含义                                                             |
| :------- | :--- | :--------------------------------------------------------------- |
| OFF      | 是   | 直接根据谱面 BPM 得到下落速度[^hs-fix-off]                       |
| MAX BPM  | 是   | 将谱面最高 BPM 与 150 BPM 对齐，按比例得到各段的下落速度，最常用 |
| MIN BPM  | 是   | 将谱面最低 BPM 与 150 BPM 对齐[^hs-fix-min]                      |
| AVERAGE  | 是   | 将谱面平均 BPM[^avg-bpm] 与 150 BPM 对齐[^hs-fix-avg]            |
| CONSTANT | 否   | AVERAGE 基础上，无视变速段，全谱统一下落速度[^hs-fix-cst]        |

[u9]: https://www.bilibili.com/video/BV1ax411177G

[^negative-bpm]: 当 BPM < 0 时，note 甚至可以 [倒退][u9]。
[^hs-fix-off]: 只用于极特殊的谱面，一般只有当其他选项都失效时才使用。
[^hs-fix-min]: 常用于存在高速段的谱面，例如 SP★01 Faceless Moon。
[^avg-bpm]: 按各 BPM 段的 note 数量加权平均，不是最低 BPM 和最高 BPM 的简单算数平均。
[^hs-fix-avg]: 常用于同时存在低速段和高速段的谱面，例如 SP★01 duty。
[^hs-fix-cst]: 谱面中的 STOP 骤停不受影响，例如 SP★01 点、線、面、立体。
