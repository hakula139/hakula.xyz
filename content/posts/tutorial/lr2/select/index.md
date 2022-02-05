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

{{< image src="assets/folder-list.webp" caption="目录列表" width="1280" >}}

{{< image src="assets/song-list.webp" caption="选曲列表" width="1280" >}}

这是 WMIX 的选曲界面。按鼠标左键 / 键盘 :arrow_right: 键 / 回车键 / 手台白键进入，按鼠标右键 / 键盘 :arrow_left: 键 / 手台 2 或 4 号键返回，按 `Esc` 键退出游戏。

下面我们分区域进行讲解。

## 最左侧

### PLAY OPTION

{{< image src="assets/left/play.webp" caption="PLAY OPTION" width="1280" >}}

这些选项除了可以用鼠标点击来调整，也可以通过键盘 / 手台的对应按键调整（参考 IIDX）。

#### LANE OPTION

| 选项        | 别称  | 存分        | 含义                                                    |
| :---------- | :---- | :---------- | :------------------------------------------------------ |
| OFF         | 正规  | 是          | 原始谱面                                                |
| MIRROR      | 镜像  | 是          | 键盘区谱面镜像翻转[^mirror]                             |
| RANDOM      | 随机  | 是          | 键盘区谱面随机交换轨道顺序[^random]                     |
| S‑RANDOM    | S‑RAN | 是          | 键盘区每个 note 随机出现在任意轨道[^s-ran]              |
| H‑RANDOM    | H‑RAN | 否[^assist] | S‑RANDOM 基础上，尽可能避免纵连[^h-ran]                 |
| ALL‑SCRATCH | 全皿  | 否          | RANDOM 基础上，将键盘区的 note 尽可能移进皿轨[^all-scr] |

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

{{< style "table { min-width: 30rem; }" >}}

| 选项      | 含义                              |
| :-------- | :-------------------------------- |
| SUDDEN    | 50% 上隐                          |
| HIDDEN    | 50% 下隐                          |
| SUD + HID | SUDDEN + HIDDEN，基本等同于全隐了 |

{{< /style >}}

由于不能调节可视区域的范围，这个选项没什么实用价值，还是设置为 OFF 吧。

如果你需要上隐，直接用上挡板就可以了；如果你需要下隐，可以考虑修改挡板的素材图[^lane-cover-img]，将需要下隐的部分以外的区域改成透明色，然后在游玩界面将挡板拉到底即可。

[^lane-cover-img]: 位于 WMIX 皮肤根目录下的 `play/parts/lanecover`。

#### ASSIST

免盘开关，开启后皿就不用管了，既不影响血量也不算分。当然，最终分数也不保存。

「皿曲是发狂表的一环，不爽不要玩」.jpg :wink:

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

{{< style "table { min-width: 30rem; }" >}}

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

设定目标后，在游玩界面[^ghost-position]和结算界面将显示与目标分数的分差。

{{< admonition warning 注意 >}}
[BATTLE](#battle) 模式下默认目标为对手的当前分数，此时本选项无效。
{{< /admonition >}}

[^ghost-position]: 需开启 [GHOST POSITION](#ghost-position)。

#### BATTLE

除了 G-BATTLE，其他模式个人觉得没有多大意义，此处从略。以下只介绍本选项中的 G-BATTLE 模式。

##### G-BATTLE

G-BATTLE 是一个独特且实用的对战模式。它可以通过 LR2IR 服务器上存储的纪录数据[^ir-record]，模拟一局和纪录持有者的实时对战，在游玩过程中你可以看到自己和对手的实时分差。更重要的是，对战使用和纪录**完全相同的谱面**和 [血槽设置](#groove-gauge)。这意味着你可以利用这个特性来借用别人（或自己）之前随机到的好型，而很多时候一个好型确实能省不少事，甚至能助你越级点灯[^why-random]。比如我在九段时绿的 [SP★14 orion ring -IR-][orion-ring]，就是 G-BATTLE @雪凛 点上的。还有像更著名的 SP★20 銀の風[^gin-no-kaze]：「你再把我随成对拍，我就要举报你了」.jpg :rage:

使用 G-BATTLE 首先需要连接到 IR 并开启这里的 G-BATTLE 选项，然后在选曲界面选择需要 G-BATTLE 的歌曲，尝试按住 4 号键[^key-4]调出 IR 排行榜，滚动列表选择需要 G-BATTLE 的玩家进入游戏，这样就进入 G-BATTLE 模式了。当然，这个先后顺序也可以反过来。你可以先添加需要 G-BATTLE 的玩家为 Rival，然后在选曲界面进入这位玩家的 Rival Folder[^rival-folder]，选择需要 G-BATTLE 的歌曲进入游戏。

{{< admonition warning 注意 >}}
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
[^key-4]: 如果 4 号键是空格键，可以先按住 [START 键](#key-config) 再按空格键，也可以另外设置一个 4 号键。这里由于需要下载 IR 排行榜数据，可能需要等待一段时间。
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

### SYSTEM OPTION

{{< image src="assets/left/sys.webp" caption="SYSTEM OPTION" width="1280" >}}

#### SKIN · SOUNDSET

点击进入皮肤 / 音频设置界面。由于此部分内容较多，我们将在 [WMIX](../wmix) 篇进行讲解。

在右侧面板里也可以调整设置，只是没有实时预览。

#### KEY CONFIG

点击进入键位设置界面。画面缩在左上角是正常现象，参见 [目录](../directory-structure/#theme) 篇的说明。

{{< image src="assets/key-config.webp" caption="KEY CONFIG" width="640" >}}

这里我们以 7K 模式为例。推荐先按 `F2` 键清空原有的键位设置，防止莫名的键位冲突。在最上方标题的左右侧各有一个小箭头，可以切换到其他模式。

{{< admonition warning 注意 >}}
与其他皮肤不同，WMIX 的 5K 模式用的是 7K 模式里与皿相邻的 5 个按键的键位设置，而不是 5K 模式的键位设置。
{{< /admonition >}}

设置键位映射时，先选中下方的第一个框，然后依次点击上方的白色按键，并按下键盘或手台上的实体按键。对于 7K 模式，只需设置其中一侧即可，左侧为 1P，右侧为 2P。如需清除某个键位，先选中下方的框，然后按 `Del` 键清除。

{{< style "table td { min-width: 6rem; }" >}}

| 按键         | 说明                                                                               |
| :----------- | :--------------------------------------------------------------------------------- |
| 7 个矩形按键 | 从左到右依次为 1 ~ 7 号键，奇数键为白键，偶数键为黑键，分别对应键盘区的 7 条轨道。 |
| 1 个圆形转盘 | 在 BMS / IIDX 里称为「皿」，圆盘的左 / 右半边分别对应逆 / 顺时针转动圆盘的操作。   |
| 2 个圆形按钮 | 上面的是 START 键，下面的是 SELECT 键。                                            |

{{< /style >}}

{{< admonition info "START / SELECT 键使用说明" >}}

- 选曲界面
  - 按住 START 键打开 PLAY 面板
  - 按 SELECT 键快速切换难度
- 游玩界面
  - 双击 START 键开关挡板（需开启 [SUDDEN+](#sudden)）
  - 按 START + 黑 / 白键调速
  - 按 START + SELECT 键退出

{{< /admonition >}}

事实上，每个按键可以映射到多个不同的键位，多个不同的按键也可以映射到同一个键位。一个典型的应用就是「全押映射」，也就是将所有轨道都映射到同一个实体按键上。对于一些有键位冲突的键盘，遇到全押时就可以按这个全押键。当然，最好还是买一把全键无冲的键盘。

尽管键位设置因人而异，但对于键盘 7K，我们还是推荐使用以下键位或其变种[^keymap-alt]：

{{< style "table td { min-width: 3rem; }" >}}

|  皿   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |  皿   |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
|   A   |   S   |   D   |   F   | Space |   J   |   K   |   L   |   ;   |

{{< /style >}}

同时建议 1P 空格键使用右手拇指，2P 空格键使用左手拇指。

{{< admonition tip 关于双指皿 >}}

皿只有一条轨道，为什么还要设置两个按键呢？

这是因为有一种键型叫「连皿」，不知道什么是连皿可以参考 [SP☆12 灼熱 Beach Side Bunny (SPA)](https://www.bilibili.com/video/BV14b4y1v7Pe)。本来连皿是为 IIDX 控制器设计的，玩家可以来回搓皿。但键盘玩家只能戳按键，用单指硬抗长连皿显然比较困难。因此我们给皿设置两个按键，这样就可以用双指交互来应对连皿了，这种技巧也被称为「双指皿」。

当然，双指皿属于上位技巧，不用急着练。

{{< /admonition >}}

:x: 不推荐以下键位及其变种：

{{< style "table td { min-width: 3rem; }" >}}

|  皿   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |  皿   |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
|   A   |   S   |   D   |   F   |   J   |   K   |   L   |   ;   | Space |

{{< /style >}}

- 纯直线键位：发狂后打高 BPM 交叉将异常困难，基本只能糊。建议键盘区一定要带上拇指，不要用小指。

{{< style "table td { min-width: 3rem; }" >}}

|   皿   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |  皿   |
| :----: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| LShift |   Z   |   S   |   X   |   D   |   C   |   F   |   V   | LCtrl |

{{< /style >}}

- 仿手台键位：有多卡手暂且不论，对 IIDX 实机也**不会有任何帮助**。建议直接买手台。

[^keymap-alt]: 可以整体平移或者微调位置，但不改变各个手指对应的轨道。

#### GHOST POSITION

是否在游玩界面实时显示当前分数与 [目标分数](#target) 的分差，以及其显示位置。

{{< style "table { min-width: 20rem; }" >}}

| 选项   | 含义           |
| :----- | :------------- |
| OFF    | 不显示         |
| TYPE_A | 谱面显示区域内 |
| TYPE_B | 谱面显示区域外 |
| TYPE_C | 判定线旁边     |

{{< /style >}}

Fast / Slow 指示开启后，默认显示位置为 TYPE_A。

#### SCORE GRAPH

分数柱状图开关。开启后，谱面显示区域旁从内到外将分别显示【本局当前分数】【本地最高纪录当前分数】【目标当前分数】三个柱状图。

#### DEFAULT TARGET

默认目标分数，范围为总分的 50% ~ 100%。

#### BGA

背景动画开关。

{{< admonition bug >}}
如果你确定谱面有自带 BGA，但显示为黑屏，参见 [FAQ](../faq/#8-bga-黑屏或报错)。
{{< /admonition >}}

#### BGA SIZE

BGA 显示尺寸设置。

{{< style "table { min-width: 20rem; }" >}}

| 选项   | 含义             |
| :----- | :--------------- |
| NORMAL | 自动裁剪为 1 : 1 |
| EXTEND | 原始比例 4 : 3   |

{{< /style >}}

#### JUDGE TIMING

判定延迟微调设置，范围为 -99 ms ~ +99 ms。由于 BMS 是真 key 音音游，且游玩设备是 PC 而不是什么安卓平板，因此这个值通常可以直接设为 0 ms。开启 Fast / Slow 统计后，如果 Fast 更多则往 - 方向微调，反之往 + 方向微调。

不同玩家使用的设备延迟不同，个人习惯也不同，因此其他玩家的 JUDGE TIMING 没有任何参考价值。

音频延迟可以通过调低 [音频缓冲区大小](../launcher/#system)、使用 [ASIO 驱动](../launcher/#system) 减小，显示延迟可以通过关闭 [垂直同步](../launcher/#system)、使用 [全屏模式](#screen-mode)、更换低延迟显示器减小。

{{< admonition tip 小知识 >}}
音游的延迟设置里显示的 0 ms 并不是真正的 0 ms，而是开发者经过校准后预设的某个固定偏移量。因此即使是相同的设备、相同的环境，不同音游的延迟设置之间也没有可比性，因为这与开发者的校准水平有关。同时，延迟设置为负数也不反映什么问题，一种可能是你的设备延迟比开发者的基准设备更低。
{{< /admonition >}}

#### AUTO ADJUST

是否根据游玩过程中每个 note 的判定情况实时自动调整 JUDGE TIMING。

相当实用的功能，但请不要过度依赖。不推荐新手在刚开始熟悉判定的阶段开启，建议等判定基本稳定后再使用。

#### LANE COVER

同 [SUDDEN+](#sudden)。

#### SCREEN MODE

切换窗口 / 全屏模式。选曲界面下也可按 `F4` 键快速切换。

{{< style "table { min-width: 20rem; }" >}}

| 选项   | 含义     |
| :----- | :------- |
| WINDOW | 窗口模式 |
| FULL   | 全屏模式 |

{{< /style >}}

{{< admonition bug >}}
全屏模式下切换程序或者任何弹窗都将导致 LR2 崩溃，建议开启专注助手 / 各种勿扰模式以避免弹窗。
{{< /admonition >}}

#### REPLAY SAVE

设置保存回放的条件。

{{< style "table { min-width: 20rem; }" >}}

| 选项      | 含义                   |
| :-------- | :--------------------- |
| OFF       | 不保存                 |
| ALWAYS    | 始终保存               |
| HISCORE   | 超过本地最高纪录时保存 |
| CLEAR     | 通过时保存             |
| FULLCOMBO | 全连时保存             |

{{< /style >}}

{{< admonition warning 注意 >}}
新回放将始终覆盖旧回放。
{{< /admonition >}}

{{< admonition bug >}}

- [G-BATTLE](#g-battle) 模式下回放可能保存失败。
- 段位 / Course 的回放可能保存失败，解决方案参见 [FAQ](../faq/#5-段位回放没有保存)。

{{< /admonition >}}

### SCORE DETAIL

{{< image src="assets/left/score.webp" caption="SCORE DETAIL" width="1280" >}}

#### JUDGE COUNT

{{< style "table { min-width: 20rem; }" >}}

| 名称            | 含义               |
| :-------------- | :----------------- |
| PGREAT ... POOR | 最高纪录的判定分布 |
| EX SCORE        | 最高分数           |
| MAX COMBO       | 最大连击数         |
| MIN MISS        | 最小断连数         |

{{< /style >}}

这里最高分数、最大连击数、最小断连数都是**分别**统计的，取各自最好纪录。

#### PLAY COUNT

{{< style "table { min-width: 20rem; }" >}}

| 名称   | 含义         |
| :----- | :----------- |
| TOTAL  | 谱面游玩次数 |
| CLEAR  | 通过次数     |
| FAILED | 未通过次数   |

{{< /style >}}

#### OPTION HISTORY

通过本谱使用过的所有模式 / 选项。

#### Internet Ranking

连接到 IR 时，点击跳转到本谱的 IR 页面。选曲界面下也可按 `F5` 键快速跳转。

### TAG EDITOR

{{< image src="assets/left/tag-song.webp" caption="TAG EDITOR - 歌曲" width="1280" >}}

选中歌曲时，这里显示此 BMS 谱面的相关信息。其中 TAG 以外的信息不建议修改，否则之后上传纪录到 IR 时将被视作不同的谱面，从而无法参与原谱的 IR 排名。

下方的 DEFAULT 按钮将使所有信息恢复到初始状态（同时清除 TAG），据说能解决部分乱码问题，不过我没有试过。旁边的 FAVORITE 按钮第一次点击将本谱标记为 FAVORITE，第二次点击标记为 IGNORE（从选曲列表隐藏），第三次点击取消标记[^favorite-folder]。

{{< image src="assets/left/tag-folder.webp" caption="TAG EDITOR - 文件夹" width="1280" >}}

选中文件夹时，这里显示此文件夹的相关信息。其中在 COMMAND 处根据谱面信息填写相应的 SQL 查询语句片段后，此文件夹就成为一个 Custom Folder，常用于自制难易度表。

{{< admonition tip 参考 >}}
[カスタムフォルダで BMS を仕分けしてみた - KasaBlog](https://www.kasacontent.com/musicgame/bms/1655)
{{< /admonition >}}

不过我们一般很少自制难易度表，通常还是直接导入别人做好的难易度表。

{{< image src="assets/left/tag-course.webp" caption="TAG EDITOR - Course" width="1280" >}}

选中段位 / Course 时，这里就变成了 COURSE EDITOR，可以调整此段位 / Course 的相关配置，常用于自制段位 / Course。

{{< admonition warning 注意 >}}
一旦开启 Internet Ranking 选项，所有配置均不能再作调整。
{{< /admonition >}}

[^favorite-folder]: 谱面将出现在 FAVORITE FOLDER / IGNORE FOLDER 里，参见 [启动器](../launcher/#jukebox2) 篇。

### EQ / FX (EFFECTOR)

{{< image src="assets/left/eq.webp" caption="EFFECTOR" width="1280" >}}

#### VOLUME

{{< style "table { min-width: 20rem; }" >}}

| 名称   | 含义       |
| :----- | :--------- |
| MASTER | 主音量     |
| KEY    | Key 音音量 |
| BGM    | 背景音音量 |

{{< /style >}}

#### EQUALIZER

内置的均衡器，使用前记得先打开标题右侧的小开关，下同。

#### PITCH

{{< style "table { min-width: 20rem; }" >}}

| 名称  | 含义                         |
| :---- | :--------------------------- |
| FREQ  | 同时改变音高和速度，效果最好 |
| PITCH | 只改变音高                   |
| SPEED | 只改变速度                   |

{{< /style >}}

调速参照 [十二平均律][equal-temperament-wiki]，即 FREQ + $x$ 对应 $2^{x/12}$ 倍速。例如 osu!mania 的 DT 模式就约等于 FREQ + 7。

{{< admonition warning 注意 >}}

- 减速不保存分数，但加速会保存（无分数加成）。
- 段位不允许加减速，但 Course 允许。

{{< /admonition >}}

{{< admonition tip 提示 >}}
开启后 BGM 也会变调哦～
{{< /admonition >}}

[equal-temperament-wiki]: https://en.wikipedia.org/wiki/Equal_temperament

#### FX

各种内置的效果器。

### PLAYER INFO

{{< image src="assets/left/info.webp" caption="PLAYER INFO" width="1280" >}}

{{< style "table { min-width: 30rem; }" >}}

| 名称              | 含义                 |
| :---------------- | :------------------- |
| TOTAL PLAY COUNT  | 全局游玩次数         |
| TOTAL JUDGE COUNT | 全局判定分布         |
| RUNNING COMBO     | 跨曲连击数           |
| TRIAL             | 并没有人用的任务系统 |

{{< /style >}}

由于是本地数据，如果没有备份 [数据库文件](../directory-structure/#database)，更换 LR2 本体后就会清空。

10000 PC 只是刚刚开始，请继续努力！

## 左下区

{{< image src="assets/bottom-left.webp" caption="左下区" width="480" >}}

### 快捷 PLAY OPTION

同 [PLAY OPTION](#play-option)。

## 中央区

{{< image src="assets/center.webp" caption="中央区" width="480" >}}

### BMS 基本信息

从上到下为：横幅图（如果有）、曲风、曲名、差分名、作者（音乐、BGA、谱面）、BPM。

### 快速访问栏

从左到右为：自动播放、回放（如果有）、FAVORITE / IGNORE 标记[^tag-editor]、判定难度[^judge-rank]（见下表）。

{{< style "table { min-width: 20rem; }" >}}

| JUDGE RANK | PGREAT 区间 |
| :--------- | :---------- |
| EASY       | ± 21 ms     |
| NORMAL     | ± 18 ms     |
| HARD       | ± 15 ms     |
| V.HARD     | ± 8 ms      |

{{< /style >}}

### DIFFICULTY

难度选择。由于 BMS 谱面的标定等级没有参考价值，这个选项也没什么意义。

### SCORE DATA

同 [SCORE DETAIL](#score-detail)。其中 IR RANKING 是你的当前 IR 排名，不过由于网络原因，并不一定能随时保持同步。

[^tag-editor]: 黄色 ★ 表示标记为 FAVORITE，红色 ★ 表示标记为 IGNORE，空心 ☆ 表示取消标记。
[^judge-rank]: 如果谱面的 Judge Rank 未填写，则此处显示为 V.HARD，但实际判定难度为 NORMAL。

## 右侧区

{{< image src="assets/right.webp" caption="右侧区" width="480" >}}

### 选曲列表

滚动鼠标滚轮 / 按键盘 :arrow_up: :arrow_down: 键 / 转动皿均可滚动选曲列表。

只要谱面里有长条 note，左边就会显示一个 `LN` 标记，当然这并不意味着这就是个 LN 谱。旁边的 **`[`** 就是我们 [之前](#groove-gauge) 提到的灯，像图中的白灯就表示 Hard Clear。

这里的数字就是谱面等级。发狂表外显示的等级是谱师自定的等级，和难度一样没有参考价值；发狂表内显示的等级是 EX Level，其含义见下表（SP 限定，DP 不太了解）。

{{< style "table { min-width: 30rem; }" >}}

| EX Level | 等级      | 含义                       |
| :------- | :-------- | :------------------------- |
| 01 ~ 25  | ★01 ~ ★25 | 发狂难易度                 |
| 31 ~ 42  | ☆01 ~ ☆12 | 通常难易度                 |
| 43       | ☆13       | 原 ☆12 升格 :fearful:      |
| 44       | ☆X        | 艺术谱 :question:          |
| 99       | ★???      | 规格外 :thinking:          |
| 52       |           | 修正前差分                 |
| 53       |           | 表内削除谱 :do_not_litter: |

{{< /style >}}

{{< admonition tip 参考 >}}
[:(fas fa-play-circle):  不知道 BMS 的真实难度？不知道 ☆ 和 ★ 说的是什么？BMS 难度大全兼难度参照合集](https://www.bilibili.com/video/BV1nT4y137G2)
{{< /admonition >}}

## 右上区

{{< image src="assets/top-right.webp" caption="右上区" width="480" >}}

### 倒计时

毕竟不是街机游戏，右上角的倒计时自然是不起作用的，只是装饰。

### 搜索框

- 输入曲名搜索曲目，支持英文 / 日文 / 罗马音
- 输入数字筛选等级，例如 `9+` 表示 9 级及以上
- 输入命令进行相应操作
  - `/hash`：显示谱面的哈希值（MD5）
  - `/path`：显示谱面的所在位置
  - `/deletescore`：删除谱面的本地纪录

{{< admonition bug >}}
`/deletescore` 命令对段位 / Course 无效。
{{< /admonition >}}

### 排序 / 筛选

从左到右为：排序方式（按分数、按通过情况等）、按 [游戏模式](#style) 筛选、按难度筛选。

## 右下区

{{< image src="assets/bottom-right.webp" caption="右下区" width="480" >}}

### MODE

按 [游戏模式](#style) 筛选。

### 快捷 SYSTEM OPTION

同 [SYSTEM OPTION](#system-option)。

IR 即当前 Internet Ranking 的连接情况。

{{< admonition warning 注意 >}}

这里的 SCORE SAVE 正常情况下应显示 OK，否则**不保存分数**。

如果这不符合预期，请在本文搜索关键词「存分」以查看可能是哪些选项影响了存分。

{{< /admonition >}}

## 进阶

{{< admonition tip 提示 >}}
以下内容为进阶部分，不了解也不影响游玩。
{{< /admonition >}}

### Fn 功能键

| 按键 | 作用                                                                  |
| :--- | :-------------------------------------------------------------------- |
| `F1` | 查看功能键帮助                                                        |
| `F2` | 用于游玩界面的各种神奇隐藏功能，可以自行探索体验[^f2] :kissing_heart: |
| `F3` | 调整谱面难度和等级[^f3]，对于玩家没什么意义                           |
| `F4` | 切换窗口 / 全屏模式                                                   |
| `F5` | 连接到 IR 时，跳转到本谱的 IR 页面                                    |
| `F6` | 游戏内截屏，截图保存到 LR2 根目录下                                   |
| `F7` | 显示实时 FPS[^f7]                                                     |
| `F8` | 当前目录检查曲包更新[^f8]                                             |

[lunaris]: https://www.bilibili.com/video/BV1Ms411w7ng

[^f2]: 按住 F2 键后，按 :arrow_up: :arrow_down: 键移动光标，:arrow_left: :arrow_right: 键调整选项，具体效果参见下方的日语说明。最后一个选项 LUNARIS 即 LUNAtic rave + tetRIS——你甚至可以 [在 LR2 里玩 Tetris][lunaris]！其他音游做得到吗？方块下落速度与 BPM 和 HI-SPEED 正相关。
[^f3]: 按住 F3 键后，按 :arrow_up: :arrow_down: 键调整谱面难度，:arrow_left: :arrow_right: 键调整谱面等级。
[^f7]: 由于没有 FPS 限制，LR2 基本会跑满 GPU，帧率上千不是梦，真实显卡跑分游戏。手机测评跑原神，以后咱 PC 就跑 LR2。如果发现全屏后 FPS 锁定为 60 帧，参见 [FAQ](../faq/#6-笔记本全屏锁帧)。
[^f8]: 参见 [启动器](../launcher/#song-reload) 篇。

### EXTRA MODE

打开 [PLAY OPTION](#play-option)，按住 2 号键直到选曲界面背景变成红色，就进入了 LR2 里模式（EXTRA MODE）。

{{< image src="assets/extra-mode.webp" caption="EXTRA MODE" width="1280" >}}

EXTRA MODE 的效果是将谱面的背景 key 音塞进键盘区里（排列方式可能是 H‑RANDOM），建议発狂六段以下的玩家不要随意在发狂表内尝试（

独立点灯，但不保存分数。可以作为练习。

### 8K LANE OPTION

本来，各种 [LANE OPTION](#lane-option) 都只针对键盘区，而 8K LANE OPTION 则是将 8 条轨道（包括皿轨）一起调整，在 IIDX 里被称为 RANDOM+。

{{< admonition tip 参考 >}}
[:(fas fa-play-circle):  皿谱开全随机后会发生什么？](https://www.bilibili.com/video/BV1ns411V7Ze)
{{< /admonition >}}

开启方法有点复杂。首先在 LANE OPTION 提前设置好选项（如 RANDOM / S-RANDOM），然后在选曲界面下**按住**一个白键进入曲目，在决定界面（选曲界面和游玩界面之间的过渡界面）**黑屏前**同时按一下 START 和 SELECT 键，最后一起放开。这个时机可以多试几次找找感觉。

这个隐藏选项知道的人很少。由于开启后部分皿谱会变得异常简单（例如 SP★★1 Gun to Childhead），而且还能**正常保存成绩**，我个人认为有点作弊，不推荐使用。
