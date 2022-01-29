---
title: LR2 配置教程 - 目录结构
date: 2018-09-26T14:31:00+08:00

tags: [LR2]
categories: [tutorial]
featuredImage: /images/article-covers/66385542.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

本部分将介绍 LR2 游戏文件夹的目录结构。

<!--more-->

{{< admonition info 封面出处 >}}
[神饌神輿 - @藤原](https://www.pixiv.net/artworks/66385542)
{{< /admonition >}}

解压后，你看到的目录结构应该是这样的：

{{< image src="assets/root.webp" caption="根目录" >}}

以下我不会每个子文件 / 子文件夹都讲，而是选择一些可能会用到的解释其作用。

## BMS

这是我内置的曲包根目录，当然实际上你可以将这个根目录设置在任何地方（路径不能包含中文），不一定要在游戏根目录下。你会发现目录下有两个曲包，之后当你导入其他曲包时，目录的层次结构就应该以此为参考。

{{< image src="assets/bms.webp" caption="BMS" >}}

{{< admonition warning 注意 >}}

LR2 **不支持**嵌套文件夹，你需要确保导入的根目录和谱面文件之间只隔了一层文件夹。也就是说，如果你的谱面文件位于 `started/start_a14_ucc.bme`，那么你应该将 `started` 文件夹放在某个根目录 `BMS` 下，然后在 LR2 导入这个 `BMS` 文件夹。

以下操作都是**不正确**的：

- 直接导入 `started` 文件夹。
- 将曲包 `started.zip` 解压到同名目录，形成嵌套文件夹 `started/started`。当你解压 BOF 活动包时需要尤其注意这一点。推荐使用 Bandizip 的「自动解压」功能。

{{< /admonition >}}

## LR2_HD.exe

这就是 LR2 的启动器，下面的 `LRHbody.exe` 是 LR2 的主程序，不过我们启动游戏一般还是运行 `LR2_HD.exe`。只是当你需要调整 LR2 的显卡设置时，记得选择 `LRHbody.exe` 而不是 `LR2_HD.exe`，这只是个启动器。

## LR2files

接下来我们进入 `LR2files` 目录，你看到的目录结构应该是这样的：

{{< image src="assets/lr2files.webp" caption="LR2files" >}}

### Bgm

这是 LR2 的背景音乐目录。

{{< image src="assets/bgm.webp" caption="LR2files / Bgm" >}}

其中前三个是原版 LR2 内置的背景音乐，第四个是我附加在整合包里的。当然，你也可以在这里放置其他的音乐文件，然后在 `Sound` 目录下仿照其他 `.lr2ss` 文件写一个自己的 `.lr2ss` 文件，这样就可以自定义背景音乐了。

### Sound

这是 LR2 的效果音目录。

{{< image src="assets/sound.webp" caption="LR2files / Sound" >}}

同理，你也可以在这里放置其他的效果音，然后将路径写进自己的 `.lr2ss` 文件。

### Config

这是 LR2 的配置文件目录，一般不需要去动它。

如果哪天你忘记了自己的 LR2 密码，可以在本目录下的 `config.xmh` 文件里找到自己的明文密码。对于原版 LR2 则是 `config.xml` 文件。

如果你需要从原版 LR2 切换到高清版 LR2，只需将 `config.xml` 复制一份并改名为 `config.xmh` 即可（反之同理）。

### CustomFolder

这是 LR2 的 Custom Folder 目录，一般不需要去动它。

之后你可能会使用 BeMusicSeeker 或者 GLAssist 导入像「第 2 発狂難易度表」之类的 Custom Folder，届时导入成功后它们就会出现在这里。

### Database

这是 LR2 的数据库目录。

{{< image src="assets/database.webp" caption="LR2files / Database" >}}

当你初次进入游戏后，`Score` 文件夹里会自动生成以你用户名为文件名的数据库文件（如 `Hakula.db`），请妥善保管此文件，这里面储存了你所有的本地成绩数据。

`song.db` 储存了所有已导入的歌曲数据。如果需要全曲重新导入，除了在启动器界面操作外，也可以通过删除此文件来达到同样的目的。

### Help

作者写的说明文档，你要是懂日语的话可以看看。

如果打开是乱码的话，同样还是编码的问题。可以用 Locale Emulator 转到日区打开，也可以用 VS Code 之类的编辑器选择以 Shift-JIS 编码打开。

### Movie

这是 LR2 的泛用 BGA 目录。

当一个 BMS 谱面没有自带 BGA 时，LR2 就会加载本目录下的泛用 BGA。如果本目录下没有 BGA，那么就会显示为黑屏。

黑屏就黑屏吧，无所谓啦！

### Replay

这是 LR2 的回放文件目录。

进入游戏后，右下角会有关于回放保存条件的设置。每次打完一首歌后，LR2 将根据设置的条件决定是否保存回放。这些回放文件就会保存在这个目录下，之后就可以在游戏内观看回放。

{{< admonition warning 注意 >}}
段位的回放文件经常会保存失败，解决方案参见 [FAQ](../faq)。
{{< /admonition >}}

### Theme

这是 LR2 的皮肤目录。

{{< image src="assets/theme.webp" caption="LR2files / Theme" >}}

可见我还内置了一个 Seraphic 皮肤，这是因为 WMIX 没有设置界面，这里就沿用 Seraphic 的设置界面了。不过由于 Seraphic 是 480P 的，会存在一些分辨率上的问题。反正进设置界面的机会很少，就别管这些细节了 :innocent:。如果实在看着难受，可以用下面的皮肤转换工具 `SkinConverter.exe` 将同目录下 LR2 和 Seraphic 的分辨率都拉伸到 960 × 720。

如果你后续想更换其他皮肤，那么将新皮肤解压后放在这个目录下即可。

#### WMIX_HD

这是 WMIX 皮肤的根目录。

{{< image src="assets/wmix_hd.webp" caption="LR2files / Theme / WMIX_HD" >}}

LR2 所有界面的背景图都是可以自定义的，你只需确保背景图的长宽比为 16 : 9（原版 LR2 为 4 : 3）且为 **PNG** 格式。当然如果你一定要用 JPG 格式的图片，也可以编辑相应目录下的 `.lr2skin` 文件，将其中的 `.png` 按需替换成 `.jpg`。

以下是 WMIX 各界面的背景图位置，将你的背景图放置在相应目录下即可。

{{< admonition note 背景图位置 >}}

- 选曲界面：`select/wallpaper`
- 决定界面：`decide/bg`
- 游玩界面：`play/parts/BG/full bg`
- 结算界面：`result/IMAGE`
- 段位 / Course 结算界面：`courseresult/bg`

{{< /admonition >}}

整合包里内置的 WMIX 皮肤是 @MsrButterfly 的修改版，可以在结算界面显示一些额外信息。此外，本整合包还内置了 @MsrButterfly 在 WMIX 基础上制作的 WMIX_PMS 补丁（原版 WMIX 不支持 9K 模式），详情可参阅文档 `readme_pms.txt`。在此感谢 @MsrButterfly！:heart:
