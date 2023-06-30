---
title: LR2 配置教程 - 启动器
date: 2018-09-30T13:09:00+08:00

tags: [LR2]
categories: [tutorial]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/66360679.webp
license: CC BY-NC-SA 4.0
---

本部分将介绍 LR2 启动器的相关配置。

<!--more-->

{{< admonition info 封面出处 >}}
[水鏡桜 - @藤原](https://www.pixiv.net/artworks/66360679)
{{< /admonition >}}

## 注册

双击 `LR2_HD.exe` 启动，欢迎来到 BMS！:tada:

如果之前没有转区的话，从现在开始每一步都可能出现乱码。为了方便未转区的玩家，这里我提供每步操作的窗口截图，看得懂日语的话可以参考一下。

{{< image src="assets/register-prompt.webp" caption="注册提示" >}}

{{< image src="assets/register.webp" caption="注册界面" >}}

ID 栏填写用户名，PASSWORD 栏填写密码。其中用户名只能包含英文和数字，否则会报错。

下面这两项是用于 LR2IR 账号继承的，新玩家可以直接跳过。如果你换了新电脑 / 新本体，那这里可以勾选并填写你的 LR2IR ID，点击 OK，随后 LR2 就会自动将所有**已上传**到 LR2IR 的成绩数据下载到本地。当然，你需要确保填写的密码和原账号的密码一致。

{{< image src="assets/register-success.webp" caption="注册成功" >}}

## MAIN

进入启动器界面。未转区的玩家会遇到乱码，我们点击左上角的 Language 选项将语言切换成 English。

{{< image src="assets/switch-language.webp" caption="切换语言" >}}

{{< image src="assets/main.webp" caption="MAIN" >}}

### PLAYER

玩家的本地账号。点击 New player 注册新账号。

删除账号功能似乎有问题，如有需要可以到 `config.xmh`[^config] 根据用户名手动删除相关字段。

### Window mode

勾选为窗口模式，否则为全屏模式。修改 Window size 可以调整窗口大小，当然直接拖拽边框也是可以的。

### Song reload

什么时候检查曲包更新？

| 选项               | 更新模式                                    |
| :----------------- | :------------------------------------------ |
| Manual reload      | 游戏内选中 / 进入目录，按 `F8` 手动检查更新 |
| Auto reload type 1 | 游戏内进入目录时检查更新                    |
| Auto reload type 2 | 游戏启动时扫描全部目录检查更新              |

### LR2 InternetRanking

LR2IR 即 LR2 的在线排行榜，勾选表示连接到 LR2IR，本地成绩将上传到排行榜。

{{< admonition failure 注意 >}}
如果你使用 LR2 游玩 Beatmania IIDX 解析 BMS，**请勿勾选此选项**。
{{< /admonition >}}

下方的两个选项分别是：

- 游戏启动时是否更新 Rival（可以看作是好友）的成绩数据
- 游戏内是否自动更新排行榜数据

当未连接到 LR2IR 时，这两个选项无效。

最底下的两个按钮分别是：

- LR2IR 个人页面
- LR2IR 首页

不过这两个按钮在一开始是点不了的，点击后会触发以下错误提示：

{{< image src="assets/ir-error.webp" caption="IR 错误提示" >}}

这是因为新玩家还没有 LR2IR ID。联网并勾选 LR2IR 选项，首次进入游戏后将自动获得 LR2IR ID，之后这两个按钮就可以点了。

## JUKEBOX1

这里是我们导入曲包、段位 / Course 和 Custom Folder 的地方。

{{< image src="assets/jukebox1.webp" caption="JUKEBOX1" >}}

图中的 `BMS` 是整合包预导入的测试用曲包根目录。你完全可以移除这个目录，导入其他曲包根目录。

导入曲包的方式有两种：一种是将曲包**所在的目录**直接拖进 JUKEBOX1，另一种是点击下方的「Add」按钮，个人比较推荐前一种方式。比如你的曲包位于 `BMS/started`，那么应该导入的就是 `BMS`[^bms]。

{{< admonition warning 注意 >}}

- 虽然上面提示导入 ZIP / RAR 压缩包，但其实不支持。导入前请先解压。
- 请确保至少导入了一个曲包，否则无法进入游戏。

{{< /admonition >}}

导入段位 / Course 也是类似的，将 `.lr2crs` 文件拖进 JUKEBOX1 即可。需要注意拖动的不是 `.lr2crs` 文件所在的目录，而是文件本身。如果 `.lr2crs` 文件消失，则说明导入成功。LR2 没有重复检查功能，请勿重复导入。

Custom Folder 在目前语境下通常表示第三方难易度表，导入方式同理，将 BeMusicSeeker 输出的文件夹拖进 JUKEBOX1 即可。不过可能 BeMusicSeeker 已经帮你自动导入了，无需手动导入。具体如何利用 BeMusicSeeker 导入第三方表可以参考 [这篇教程](../tools/#BeMusicSeeker)。

右键已导入的目录，选择「データベースから除外」即可移除。

尽管 LR2 支持 [自动检查曲包更新](#song-reload)，但有时数据库会出错，导致无法正常检测到新曲包。这时可以右键问题曲包所在的目录，选择「更新」手动重载。如果还是没有解决，可以点击下方的「全曲レロード」按钮进行全曲重载。

{{< admonition note 说明 >}}

导入曲包时，如果曲包非常多（如你所见，上百个 G 呢），启动器会暂时进入未响应状态，这是正常现象。请耐心等待它恢复响应，别乱动，乱动程序就会崩溃。

导入完成后，进入游戏时 LR2 将再次开始**漫长**的读取。建议先去忙别的事情或者睡一觉，这样等你几个小时后回来发现 LR2 还在读取时，你就会感谢这个明智的决定。

{{< /admonition >}}

## JUKEBOX2

{{< image src="assets/jukebox2.webp" caption="JUKEBOX2" >}}

上面 8 个选项是 LR2 内置的 Custom Folder 开关，除了「発狂 BMS FOLDER」以外的选项意义都不太大，这里就不作介绍了，有兴趣的可以自行了解。

本页面如图配置即可。建议勾选「発狂 BMS FOLDER」，这就是官方的难易度表。勾选后，[**联网并连接 LR2IR**](#lr2-internetranking)，进入游戏后就可以使用了。

## OPTION

{{< image src="assets/option.webp" caption="OPTION" >}}

| 选项                            | 含义                                                                                 |
| :------------------------------ | :----------------------------------------------------------------------------------- |
| HI SPEED - MIN, MAX, MARGIN     | 游玩界面里 note 下落速度（HI-SPEED）的范围和调整步幅                                 |
| Base speed                      | HI-SPEED 的基准速度[^base-speed]                                                     |
| Lane cover - MARGIN             | 挡板高度的调整步幅                                                                   |
| Miss BGA                        | 出现 BAD / POOR 判定时 BGA 处 Miss 帧的显示时长                                      |
| Minimum input interval          | 同键位的最短输入间隔[^input-interval]                                                |
| Music list - First, Next        | 按住 :arrow_up: :arrow_down: 键时，选曲列表连续滚动的触发延迟和时间间隔[^music-list] |
| User font                       | 使用用户字体，极可能造成显示问题，不建议设置                                         |
| PM controller                   | 启用 pop'n 手台模式[^pm-controller]                                                  |
| Assign 1/3 key to scroll        | 使用 1 和 3 号键滚动选曲列表                                                         |
| Output system log               | 输出系统日志                                                                         |
| Disable parallel loading        | 禁止系统同时加载多首歌曲                                                             |
| Disable right click exit        | 禁止通过鼠标右键退出游玩界面                                                         |
| Folder lamp                     | 文件夹大灯[^folder-lamp]，推荐开启                                                   |
| Disable system keys             | 禁用系统按键，防止误触干扰游玩，推荐开启                                             |
| Disable skin preview            | 皮肤设置界面禁用皮肤预览                                                             |
| Assign up/down key to HS change | 疑似描述有误，实为勾选后**禁用** :arrow_up: :arrow_down: 键调整 HI-SPEED             |

可根据实际需要调整。如果有不理解的选项，进游戏自己试试就知道了。

## SELECT

{{< image src="assets/select.webp" caption="SELECT" >}}

| 选项    | 含义                                     |
| :------ | :--------------------------------------- |
| Preview | 选曲界面启用歌曲预览，推荐关闭[^preview] |

其他选项此处从略。

## SYSTEM

{{< image src="assets/system.webp" caption="SYSTEM" >}}

| 选项                     | 含义                                   |
| :----------------------- | :------------------------------------- |
| DISPLAY - Wait for vsync | 启用垂直同步，因为会增加延迟，推荐关闭 |
| SOUND - OUTPUT TYPE      | 音频输出方式[^output-type]             |
| SOUND - Buffer size      | 音频缓冲区大小[^buffer-size]           |

其他选项此处从略。

[asio4all]: https://www.asio4all.org

[^config]: 其位置参见 [目录结构](../directory-structure/#config) 篇。
[^bms]: 注意曲包目录的 [层次结构](../directory-structure/#bms)。
[^base-speed]: 480P / 720P / 1080P 版应分别为 100 / 150 / 225，如此设置即可保持各版本的 HI-SPEED 同步。
[^input-interval]: 调高此值可在一定程度上缓解一些老键盘连键的情况。
[^music-list]: 参考键盘设置里的重复延迟和重复速度。
[^pm-controller]: 启用后，选曲界面采用 pop'n 手台的交互逻辑，游玩界面强制使用 9K 模式。
[^folder-lamp]: 根据文件夹内所有歌曲的最低通过情况决定，例如大白灯表示该文件夹内全曲 Hard Clear。
[^preview]: 启用后，在选曲界面选中歌曲停留若干秒，将自动播放选中歌曲的预览片段。该选项默认开启，但关闭后能有效降低 LR2 的崩溃概率，可以视情况自行决定是否开启。
[^output-type]: DirectSound 比较接近街机延迟；ASIO / WASAPI 能有效降低音频延迟，但需要进行额外配置，这里就不展开了。不了解的话可以从 [ASIO4ALL][asio4all] 开始了解。
[^buffer-size]: 此值越大则音频延迟越高，但过小的话会导致爆音。可以自行调低到一个不会爆音的临界值。
