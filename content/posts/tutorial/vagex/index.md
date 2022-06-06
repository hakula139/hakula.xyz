---
title: Vagex 折腾记
date: 2019-04-11T17:48:00+08:00

tags: [VPS, Vagex, 挂机]
categories: [tutorial]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/74046731.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

近些天折腾了会儿 Vagex，本文整理了一下部署的过程，并解释为什么不建议继续使用 Vagex 挂机。

<!--more-->

{{< admonition info 封面出处 >}}
[グリーンホール - @mocha](https://www.pixiv.net/artworks/74046731)
{{< /admonition >}}

本站建立时间较短，知名度也很低。如果你碰巧点进了这篇文章，那么你很幸运，因为你将节省你人生中宝贵的几个小时，无论你看完本文后还是否打算使用 Vagex。

## 前言

### Vagex 是什么

[Vagex][vagex] 是一个提供代刷 YouTube 视频播放量（及点赞数、订阅量等）服务的平台。需要代刷服务的视频上传者通过积分（credit）换取播放量，积分可以通过付费购买或开通会员获得。这边有刷量的需求，另一边自然就会有负责提供这些播放量的用户。通过观看 Vagex 指定的视频，看完并得到 Vagex 的确认后，用户就可以获得视频上传者所提供积分的一份。利用挂机插件自动操作，积少成多，累积的积分最终可以申请兑换成真钱作为收入。Vagex 的实质就是这样一个灰色产业。

上一段中我提供了 Vagex 的官网链接，这个链接是不带 aff 信息的，因为我不会再使用 Vagex 这个平台。

[vagex]: https://vagex.com

### 如何注册 Vagex

Vagex 从来没有关闭注册一说，你只需要在官网右上角点击 Sign Up 就可以注册了。你在其他博客看到的所谓「近期 Vagex 又开放了注册，但注册必须通过别人的邀请，否则无法注册」都是骗人的说辞，其目的是为了让你使用他们的推广链接。诚然，辛苦写篇教程在文中加入自己的 aff 链接也无可厚非，但故意编造这种谣言骗人实在是挺要脸的。

## Why not?

目前看起来好像还不错。躺着赚钱，何乐不为？

本来我也是这么想的，直到后来我收到这样一封邮件：

{{< image src="assets/vagex-mail.webp" caption="IP Banned!" >}}

当时我就火大了，那不好意思，你滚吧。

好在我只玩了 4 天，着实也没什么损失（`$ 0.2`）。我这边正常挂机，又没整什么作弊手段，你转身就把我给 ban 了。那我完全可以理解为，如果哪天 Vagex 不想付款了，也可以在你达到提现门槛（`$ 5`）前想方设法把你 IP 给 ban 了，反正你也毫无办法，最终解释权归 Vagex 所有。正常挂机被封 IP，账号安全没有任何保障。这种想封谁就封谁的态度，让我对 Vagex 彻底失去信任。

也许有人要说了，「我挂机好几年了，怎么什么事都没有？肯定是你自己的问题。」麻烦你看看现在的日期，**今年是 2019 年**，Vagex 早已不像过去那么好挂了。最近一次（2019-04-11）Vagex 挂机插件升级后，请你表演再挂一年试试？

此外，由于 Vagex 通常需要使用 Linux 的图形化界面配合 Firefox（及其挂机插件）观看大量 YouTube 视频，很吃系统资源。一般来说，每台 VPS 每月至少需确保有 100 GB 以上的闲置流量，并配置有至少 512 MB 的内存。这两点倒是相对容易达到，比较麻烦的是之后一个问题——挂机时系统将长期占用一定的 CPU 资源。这个占用比例是不确定的，我的 Vultr 主机（1 核）是 25% ~ 50%，DigitalOcean 主机（1 核）是 15% ~ 35%。而 VPS 商家一般都有不成文的 CPU 使用限制，长期大量占用 CPU 是极可能导致被停机（suspend）的。35% 左右的占用率其实已经接近警戒线，严格一点的 VPS 商家（例如 Virmach）这时已经发工单警告并停机了。因此 Vagex 挂机还要冒着一定的被封 VPS 的风险，考虑到 Vagex 那微薄的收益，我认为这并不值得。

提到 Vagex 的收益，目前新注册用户积分兑换美元的汇率为 25000 : 1（这个汇率一直在调整），提现门槛是 `$ 5`。通常来说，1 台 VPS 用 1 个账号挂机 1 天获得的积分在 1200 ~ 2000 左右（2019 年），一个月也就是 36000 ~ 60000 点，折合美元约 `$ 1.4` ~ `$ 2.4`。回本是没多大希望，大概也就能抵一下域名费用。想想为之花费的时间和精力，实在没什么必要。

有兴趣可以在 [全球主机交流论坛][hostloc] 搜索「Vagex」关键词，查看关于 Vagex 挂机的更多讨论。

总的来说，得不偿失，吃力不讨好。从 2019 年开始，不建议继续使用 Vagex 挂机。当然，eBesucher 和 AlexaMaster 就更烂了，曝光的文章很多，这里不再赘述。

如果你看到这里还打算使用 Vagex 挂机，以下我整理了一篇简单的教程。配置期间我遇到过各种坑，这里直接列出了较优的解决方案，不建议再做其他无意义的尝试。

[hostloc]: https://www.hostloc.com

## 部署教程

Vagex 挂机教程铺天盖地，不过我还是想简单写一写，顺便测试一下博客主题的代码框显示效果。

以下内容基于 Ubuntu Server 18.04 LTS 系统，其他系统可自行灵性修改。

### 安装图形化界面

Ubuntu Server 默认是不带图形化界面的，需要手动安装。这里我们使用 [Xfce][xfce] 桌面环境，对配置的要求相对较低。

```bash
sudo apt update
sudo apt install xfce4 xfce4-goodies -y
```

[xfce]: https://www.xfce.org

### 安装 VNC

桌面环境安装完成后，建议使用 [VNC][vnc] 进行远程连接，不要使用 XDMCP（X11 转发），后者的速度慢到令人发指。这是我遇到的第一个坑，当时光是研究如何配置 XDMCP 就浪费了很多时间。

[vnc]: https://www.realvnc.com

#### 安装服务端

在 VPS 上安装 VNC Server。

```bash
sudo apt install vnc4server -y
```

#### 安装客户端

在自己的电脑上安装 [VNC Viewer](https://www.realvnc.com/en/connect/download/viewer)。

#### 配置服务端

将 `~/.vnc/xstartup` 文件的内容修改为：

```bash
#!/bin/sh

unset SESSION_MANAGER
exec /etc/X11/xinit/xinitrc

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
x-window-manager &
startxfce4 &
```

#### 启动服务端

```bash
vncserver
```

默认启动 `1` 号桌面。详细说明可添加 `--help` 参数查看。

初次启动时会要求设定密码，之后客户端连接时需要用到。如果忘记密码可直接删除 `~/.vnc` 文件夹以初始化。

```bash
rm -rf ~/.vnc
```

#### 停止服务端

```bash
vncserver -kill :1
```

其中 `1` 为需要停止的桌面号，在启动时会有显示。

#### 加密 VNC 连接

VNC 远程连接本身是未加密的，存在一定的安全风险，故推荐通过 SSH 隧道加密连接。

本步骤为可选项，这里以 [Xshell][xshell] 为例。

右键属性，切换到 Connection > SSH > Tunneling 页面，点击 Add... 选项。

{{< image src="assets/xshell/tunneling.webp" caption="Xshell 配置 - Connection > SSH > Tunneling" >}}

如图所示，设定 Listening Port 为客户端端口、Destination Port 为服务端端口。其中端口号为桌面号加 `5900`，例如 `5905` 端口即对应 `5` 号桌面。如果 VPS 设置了防火墙，记得放行相应端口。

{{< image src="assets/xshell/forwarding-rule.webp" caption="Xshell 配置 - Forwarding Rule" >}}

此后 VNC 远程连接前需先建立 SSH 连接。

[xshell]: https://www.netsarang.com/en/xshell

#### 配置客户端

服务端启动后，配置客户端。

`Ctrl` + `N` 新建配置，如图所示填写。其中桌面号为之前指定的客户端端口（Listening Port）号减 `5900`。若未进行 [加密 VNC 连接](#加密-vnc-连接) 步骤，则 VNC Server 栏填写 `<服务器 IP>:<服务端桌面号>`，如 `1.2.3.4:1`。

{{< image src="assets/vnc-viewer-properties.webp" caption="VNC Viewer 配置" >}}

Options 页面里调整 Picture quality 选项可指定画面质量，画质越高则反应速度越慢。

此后双击即可连接，初次连接需要输入之前设定的密码。

### 启动 Firefox

点击左上角打开开始菜单，启动 Firefox 浏览器。

{{< image src="assets/xfce.webp" caption="Xfce 桌面" >}}

进入设置（Preferences），切换到 Privacy & Security 页面。

#### 禁用历史记录

找到 History 栏，如图所示设置。

{{< image src="assets/firefox/history.webp" caption="Firefox 设置 - History" >}}

点击 Settings...。

{{< image src="assets/firefox/clear-history.webp" caption="Firefox 设置 - Settings for Clearing History" >}}

如此使得 Firefox 在保留 Cookies 的同时清除历史记录。

#### 允许自动播放及弹窗

找到 Permissions 栏，如图所示设置。

{{< image src="assets/firefox/permissions.webp" caption="Firefox 设置 - Permissions" >}}

如此使得 Firefox 允许 YouTube 自动播放视频（否则会被判定为作弊），且允许 Vagex 插件自动弹窗（否则插件无法正常运行）。

### 启动 Vagex 插件

在 Firefox 里进入 Vagex 官网 <https://vagex.com>，在右上角注册（Sign Up）或登录（Login）。此后进入插件下载页面 <https://vagex.com/members/viewers.php>，选择 Firefox Viewer，点击 Latest Version 下载安装。

{{< image src="assets/vagex/firefox-viewer-download.webp" caption="Vagex 插件 - Firefox Viewer 下载" >}}

安装完插件后，点击插件按钮，输入 Vagex 账号密码登录。调整 Start with Firefox 选项为 true，使 Vagex 插件随 Firefox 自启动。此后点击 Start 启动插件，点击 Stop 停止插件。

{{< image src="assets/vagex/firefox-viewer-start.webp" caption="Vagex 插件 - Firefox Viewer 启动" >}}

启动后会弹出 Google 的登录页面，建议使用小号登录。

- 为什么要登录？因为如果不登录，Vagex 会限制每日的浏览量（目前是 140 个视频），超出限制的浏览不算积分。此外登录后还能自动做点赞和订阅任务，会有额外积分。
- 为什么要用小号？因为有可能被 Google 识别为垃圾账号导致封禁，小号的话即使被封也没有什么影响。

### 关于 Google 账号注册

然而不像以前，现在国内想注册 Google 账号并不容易，这是我遇到的第二个坑。

{{< admonition success "2019-04-14 可行方案" >}}
最终找到的方法是在手机上使用 Gmail 的 APP 注册，可以跳过手机验证，那接下来就没什么好讲的了。
{{< /admonition >}}

以下是我之前的折腾历程，都是些不可行的方案，就当排雷了。

{{< admonition failure "2019-04-14 不可行方案" false >}}

首先，网页注册似乎无法绕开手机验证步骤，网上找到的方法基本全部失效。

其次，如果你输入手机号后能顺利进行到下一步，那没问题，你可以跳过剩下的部分了。否则（提示「此电话号码无法用于进行验证」/「This phone number cannot be used for verification」）就会比较麻烦：

1. 虚拟手机号无法用于验证——我注册 [TextNow][textnow] 账号（过程很麻烦，这里不展开了）获得了一个虚拟美国手机号，然而这个号码仍然提示无法用于验证。
2. 虚拟手机号无法用于获得 [Google Voice][google-voice] 号码——我尝试用这个 TextNow 手机号注册 Google Voice，可以收到验证码，也可以验证并绑定成功，但接下来无事发生，并没有获得之前选择的 Google Voice 号码。

那该怎么办呢？因为以前我已经注册过两个账号，所以我到这一步就直接放弃了。据说用实体美国手机号可以，不过我没有试过，有时间精力的可以自己找点教程试一试。

[textnow]: https://www.textnow.com
[google-voice]: https://voice.google.com

{{< /admonition >}}

### 自动重启脚本

由于挂机时 Firefox 可能会卡死，所以需要定时重启来避免这种情况。

定时重启 VPS 不是好的解决方案，因为我们可能还希望在 VPS 上同时运行其他程序。这里我们选择定时重启 Firefox，并自动清理 VNC Server 产生的日志。

修改计划任务：

```bash
crontab -e
```

在结尾附加以下内容：

```bash
0 * * * * rm -rf ~/.vnc/*.log &> /dev/null
*/20 * * * * killall -9 firefox &> /dev/null
*/20 * * * * sleep 30; export DISPLAY=:1; firefox &> /dev/null
```

### 启用 Swap

如果 VPS 内存较小（≤ 512 MB），推荐启用 Swap（类似 Windows 的虚拟内存）。

查看当前是否已启用 Swap：

```bash
sudo swapon -s
```

如果结果为空，则说明未启用（否则可以直接跳过本节）。

#### 创建 Swap 文件

输入以下命令创建并启用 Swap 文件（1 GB）：

```bash
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

查看效果：

```bash
sudo free -h
```

#### 设置开机自启动

修改 `/etc/fstab` 文件以设置开机自启动。在结尾附加以下内容：

```bash
/swapfile none swap defaults 0 0
```

#### 禁用 Swap

之后如果想禁用 Swap，可输入以下命令删除并禁用 Swap 文件：

```bash
sudo swapoff -a
sudo rm -rf /swapfile
```

同时移除 `/etc/fstab` 文件里之前附加的内容（如果有）。

{{< admonition tip 参考 >}}
[Swap - ArchWiki](https://wiki.archlinux.org/index.php/Swap)
{{< /admonition >}}

## 一些限制

Vagex 挂机有一些限制，如下所示。

{{< admonition failure 限制 >}}

1. 根据星级限制同时挂机的 IP 数，0 ~ 2 星限制为 2 个 IP、3 星 3 个、4 星 4 个、5 星 5 个。
2. 未登录 Google 账号的情况下，每日的浏览量限制为 140 个视频。
3. 同 IP 下挂多个 Viewer 会提示「You are viewing too fast with this IP」错误，导致没有积分。
4. 同 IP 下不允许挂多个账号，从第二个账号起没有积分，同时可能被封号。
5. 多个 IP 登录同一个 Google 账号，将被判定为同一个 IP，从而引发 3. 的错误。

{{< /admonition >}}

## 结语

最后积分攒够了就可以申请提现 **（可能拖好几个月不发，甚至可能拒付）**，目前只支持提现到 [PayPal][paypal]。至于在哪里兑换以及如何注册 Paypal 就不作赘述了。

反正该说的都说了，目前 YouTube 方面也在严防各种刷数据现象，我寻思 Vagex 差不多也该凉了。**最后祝贵公司早日倒闭。**

[paypal]: https://www.paypal.com/us/home
