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

{{< admonition note 注意 >}}
[BATTLE](#battle) 模式下默认目标为对手的当前分数，此时本选项无效。
{{< /admonition >}}

[^ghost-position]: 需开启 [GHOST POSITION](#ghost-position)。

#### BATTLE

除了 G-BATTLE，其他模式个人觉得没有多大意义，此处从略。以下只介绍本选项中的 G-BATTLE 模式。

##### G-BATTLE

G-BATTLE 是一个独特且实用的对战模式。它可以通过 LR2IR 服务器上存储的纪录数据[^ir-record]，模拟一局和纪录持有者的实时对战，在游玩过程中你可以看到自己和对手的实时分差。更重要的是，对战使用和纪录**完全相同的谱面**和 [血槽设置](#groove-gauge)。这意味着你可以利用这个特性来借用别人（或自己）之前随机到的好型，而很多时候一个好型确实能省不少事，甚至能助你越级点灯[^why-random]。比如我在九段时绿的 [SP★14 orion ring -IR-][orion-ring]，就是 G-BATTLE @雪凛 点上的。还有像更著名的 SP★20 銀の風[^gin-no-kaze]：「你再把我随成对拍，我就要举报你了」.jpg

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

皿区只有一条轨道，为什么还要设置两个按键呢？

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

![LR2 / Select - Score](https://hakula-1257872502.file.myqcloud.com/usr/uploads/2018/12/Select_left_Score.jpg)

（因说明需要，这里起切回了自己的号。）

#### JUDGE COUNT

当前歌曲最高纪录的判定分布情况、具体分数等统计信息一览。

#### PLAY COUNT

由上至下分别为：当前歌曲的总游玩次数（TOTAL）、通过次数（CLEAR）、失败次数（FAILED）。

#### OPTION HISTORY

Clear 本曲所使用过的模式一览。

#### Internet Ranking

IR 开启的情况下，点击本选项会在浏览器内打开该曲所在的 IR 页面。Select 界面下快捷键：`F5`。

### TAG EDITOR

![LR2 / Select - Tag (Song)](https://hakula-1257872502.file.myqcloud.com/usr/uploads/2018/12/Select_left_Tag_Song.jpg)

选曲列表处的光标指向歌曲时，此处显示该 BMS 的相关信息。其中 TAG 以外的栏目一般不建议修改（除非你就是作者），否则之后上传成绩到 IR 时将被视作不同的谱，从而无法参与 IR 排名。

下方的 DEFAULT 选项会使 BMS 信息恢复到初始状态，听说可以解决部分乱码问题，不过我没有试过。需注意初始化时也将清除 TAG 信息。

没事别点 FAVORITE 选项，否则选中歌曲将会被隐藏，只有到启动器 JUKEBOX2 栏开启 FAVORITE FOLDER 后才能在那个文件夹里找到。徒增麻烦，没有什么意义。

![LR2 / Select - Tag (Folder)](https://hakula-1257872502.file.myqcloud.com/usr/uploads/2018/12/Select_left_Tag_Folder.jpg)

光标指向文件夹时，此处显示该文件夹的相关配置。其中的 Command 栏配合相关 BMS 的 TAG 栏合理设置后，该文件夹就可以成为一个 Custom Folder，常用于自制难易度表（如图中所示的「第 2 発狂難易度」）。实际上这里 TAG 就相当于是起到了一个筛选的作用。

至于 TAG 和 Command 的详细配置语法就超出了本教程的范围，有兴趣的读者可以自（请）行（教）了（雪）解（凛）（[相关教程](http://www.kasacontent.com/musicgame/bms/1655)）。不过 TAG 信息一般并非手动添加，而是使用 BeMusicSeeker 或 GLAssist 等第三方辅助工具批量添加，具体会在之后的章节中讲到。

![LR2 / Select - Tag (Course)](https://hakula-1257872502.file.myqcloud.com/usr/uploads/2018/12/Select_left_Tag_Course.jpg)

光标指向段位 / Course 时，TAG EDITOR 就变成了 COURSE EDITOR，可以调整对应 Course 的相关配置，如相邻两曲间的衔接方式等。需注意，一旦开启了 Internet Ranking，所有的选项将不能再作调整。

### EQ / FX (EFFECTOR)

![LR2 / Select - EQ](https://hakula-1257872502.file.myqcloud.com/usr/uploads/2018/12/Select_left_EQ.jpg)

#### VOLUME

由上至下分别为：主音量、KEY 音的音量、背景音的音量。

#### EQUALIZER

LR2 自带的均衡器。~~这才叫音乐游戏，懂吗？~~

使用前记得先点亮小标题右侧的开关，下同。

#### PITCH

最振奋人心的功能来了！（x

1. FREQ：同时改变音高和速度，效果最佳
2. PITCH：只改变音高
3. SPEED：只改变速度

采用[十二平均律](https://en.wikipedia.org/wiki/Equal_temperament)，调速公式为：

$$ \Large y = 2^{\frac x {12}} $$

表示 FREQ + x 对应 y 倍速（如 + 12 就是 2 倍速，- 12 就是 0.5 倍速）。

LR2 歌曲加减速的效果（音质）可能是所有音游里最好的，没有之一（虽说绝大多数音游其实根本没这功能…）。

[scode type="yellow"]注意：

1. 减速不保存成绩，但加速会保存（当然，不会有分数加成）
2. 段位不允许加减速（但 Course 可以）

[/scode]

开启后 Select 界面的 BGM 也会变调，超带感的！

#### FX 1 / 2 / 3

各种效果器，可以自行研究。

### PLAYER INFO

![LR2 / Select - INFO](https://hakula-1257872502.file.myqcloud.com/usr/uploads/2018/12/Select_left_Info.jpg)

玩家游玩信息一览（本地）。

1. TOTAL PLAY COUNT：总游玩次数
2. TOTAL JUDGE COUNT：总判定分布情况
3. RUNNING COMBO：连续 Combo 数（跨曲）
4. TRIAL：没人用的可怜任务系统

因为是本地数据，更换 LR2 本体后（如果没有保留数据库文件）就会被清空。

10000 PC 才只是刚刚开始，请继续努力！！！

## 左下区

下面的模式调整栏和 PLAY OPTION 面板的功能完全一样，这里不再赘述。

上面的 SCORE DATA 就是选曲列表处的光标所指向曲目或段位的最佳成绩信息，其中各数据（EX SCORE、Max Combo、Miss Count、点灯情况）都是**分别**统计的，取各自最高纪录。IR Ranking 是当前的 IR 排名，但也并非随时保持同步的，有时网络连接不畅可能就不会更新。

## 中央区

![LR2 / Select](https://hakula-1257872502.file.myqcloud.com/usr/uploads/2018/12/Select_center.jpg)

上方是 BMS 谱面基本信息。由上至下分别为：Banner 图（如果有）、风格（Genre）、曲名、[差分](http://spiral.cside.com/pprc/beginner/step12.html)名、作者（曲师、谱师等）、BPM。

中间一栏从左到右依次是：Autoplay、Replay（如果有）、添加到 FAVORITE / IGNORE（别点，理由前文已说明）、判定难度（谱面属性，具体如下所示）。

|  EASY   | NORMAL  |  HARD   | V.HARD |
| :-----: | :-----: | :-----: | :----: |
| ± 21 ms | ± 18 ms | ± 15 ms | ± 8 ms |

（如果谱师 Judge Rank 留空没填，则这里默认显示为 V.HARD，但实际上是 NORMAL。）

下方是难度选择（筛选）。然而事实上这些难度都是谱师自己定的，基本没有参考价值。建议从难易度表内选曲，否则很容易踩雷。

## 右侧区

选曲列表。通过鼠标滚轮、键盘 `↑` `↓` 键、手台转皿（或键盘按皿键）均可滚动列表。

每行左端【 型的就是所谓的灯（Lamp），在启动器开启 Folder Lamp 选项后文件夹也会有大灯（文件夹内全曲最低 Clear 情况）。各颜色灯所对应的 Clear 情况如下所示：

| FAILED | EASY  | GROOVE | HARD  | FC / PA |
| :----: | :---: | :----: | :---: | :-----: |
|   坏   |  绿   |   黄   |  白   |   彩    |

每行左侧的数字是谱面等级。发狂表外显示的等级均为谱师自定等级（Level），同难度（Difficulty）一样没有参考价值；发狂表内显示的等级（EX Level）含义如下所示（SP 限定，DP 不太了解）：

|  01 ~ 25   |  31 ~ 42   |     43      |     44     |  99   |     52     |     53     |
| :--------: | :--------: | :---------: | :--------: | :---: | :--------: | :--------: |
| ★01 ~ ★25  | ☆01 ~ ☆12  |     ☆13     |     ☆X     | ★???  |     /      |     /      |
| 发狂难易度 | 通常难易度 | 原 ☆12 升格 | 迫真艺术谱 | SB??? | 修正前差分 | 表内削除谱 |

相关视频：

> [不知道 BMS 的真实难度？不知道 ☆ 和 ★ 说的是什么？BMS 难度大全兼难度参照合集](https://www.bilibili.com/video/BV1nT4y137G2)

如果谱内有长条 note，则最左侧会显示一个 `LN` 图标。当然，这并不意味着这就是 LN 谱。

## 右上区

不同于 IIDX，右上角的倒计时是不起作用的，到 0 也不会发生什么事情。可以视为装饰。

左侧搜索栏可用于搜索曲目，英文 / 假名 / 罗马字均可。输入数字可筛选等级（虽然没什么意义，因为谱面自带等级是乱标的），如 `10+` 表示 Level 10 及以上。此外，搜索框也是个简易控制台，可键入以下命令进行相关操作：

1. `/hash`：显示当前曲目的 MD5 值
2. `/path`：显示当前谱面所在文件夹路径
3. `/deletescore`：删除当前谱面本地成绩（对段位 / Course 无效是个 bug）

下方是一些筛选 / 排序选项，从左至右依次为排序方式、键数筛选、难度筛选。按需调整即可。

## 右下区

和 SYSTEM OPTION 里的设置完全一样，这里不再赘述。

需要注意这里 SCORE SAVE 一般应为 OK（除非你知道自己在干什么），如果为 NO 则**不存成绩**，可能是因为开了像 CONSTANT、AUTO-SC 之类的特殊模式，在本文搜索（Ctrl + F）关键词「不存成绩」即可知道是哪些设置影响了成绩保存。

IR 即 Internet Ranking 连接状况。

## 进阶

[scode type="lblue"]以下内容为进阶部分，可以了解~~，但没必要~~[/scode]

欢迎补充。

### F1 ~ F8 功能键

- `F1`：功能键帮助*（会日语的话以下部分可以直接跳过）*
- `F2`：各种各样的~~神经病~~隐藏功能，用于 Play 界面，可以自行研究，超好玩的！（雾）；按住 F2 键后，`↑` `↓` 键移动光标，`←` `→` 键调整选项，具体作用看下方日语说明；最后一个选项 LUNARIS 即 LUNAtic (rave) + tetRIS，你甚至可以在 LR2 玩《俄罗斯方块》，其他音游做得到吗？？（下落速度与 BPM 和 HI-SPEED 正相关，得分规则与一般的 Tetris 类似）
- `F3`：按住 F3 键后，`↑` `↓` 键调整谱面难度（Difficulty），`←` `→` 键调整谱面等级（Level）；对于玩家没有什么意义
- `F4`：切换窗口 / 全屏模式
- `F5`：IR 开启的情况下，在浏览器内打开该曲所在的 IR 页面
- `F6`：截屏，保存到 LR2 根目录
- `F7`：显示 [FPS](https://en.wikipedia.org/wiki/Frame_rate)；由于没有帧数限制，LR2 基本会吃满 GPU，帧数往往成百上千~~，真实显卡跑分游戏~~；如果发现全屏后 FPS 锁定为 60 帧，见 [FAQ](https://hakula.xyz/tutorial/lr2_faq.html)
- `F8`：当前文件夹重新加载曲包

相关视频：

> [LR2 牛逼模式之俄罗斯方块 mode！](https://www.bilibili.com/video/av28178521)

### EXTRA MODE

打开 PLAY OPTION 面板，长按 2 号键（不是数字 2），发现 Select 界面背景变为红色，即进入了 LR2 里模式（EXTRA MODE）。

![LR2 / EXTRA MODE](https://hakula-1257872502.file.myqcloud.com/usr/uploads/2019/01/Select_EX.jpg)

EXTRA MODE 的效果是将每个谱的背景 key 音塞到键区里（塞法可能是 H‑RANDOM），建议発狂六段以下的玩家不要在发狂表里尝试（

单独存灯，但不存成绩。可以作为练习。

### 8K LANE OPTION

[scode type="red"]不推荐使用[/scode]

本来，各种 LANE OPTION 都只针对键区（7K），皿位的键是不会改变位置的，而 8K LANE OPTION 将键区和皿位（7K + 1）视为 8K 一起调整，也就是说可以将皿位的键随机到键区（相当于 IIDX 里的 RANDOM+）。

效果视频：

> [皿谱开全随机后会发生什么？](https://www.bilibili.com/video/av26171122)

如果你玩过原谱的话，就会知道这里发生什么了（

操作方法是在 Select 界面下**按住**一个白键（1 / 3 / 5 / 7 号键）进入曲目，然后在 Decide 界面（进入游玩界面前的过渡界面）**黑屏前**同时按一下 Start 和 Select 键，最后一起放开。具体时机可以自己多试几次找找感觉。当然，LANE OPTION 要提前先设置好（如 RANDOM 或 S‑RANDOM）。

这个隐藏功能知道的人很少。因为开启后部分皿谱会变得异常简单（如 SP★★1 - Gun to Childhead），而且**能够正常保存成绩**，我个人认为有点作弊，不推荐使用。
