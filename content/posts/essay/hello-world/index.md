---
title: Hello, World!
date: 2018-08-23T12:15:00+08:00

slug: hello-world
tags: [建站, VPS]
categories: [essay]
license: CC BY-NC-SA 4.0

featuredImage: /images/article-covers/66372748.webp

toc: true
math: false
lightgallery: true
hiddenFromHomePage: false
hiddenFromSearch: false
---

建站以来第一篇文章，主要是建站后的一点感想，以及建站的整个大致流程。

<!--more-->

{{< admonition info 封面出处 >}}
[ARCANA - @MISSILE228](https://www.pixiv.net/artworks/66372748)
{{< /admonition >}}

## 一些感想

初次建站，没什么经验，折腾了好几天，不过真的建成了以后倒也觉得没什么了。我想这或许就类似于高中期间所做的课题，重要的并不完全是结果，而是从一开始突然产生了一个「大胆的想法」，到最后通过各种尝试终于实现了这个想法的过程。

建站时自然是遇到了不少困难，不过在解决各种问题的过程中也顺便学习了许多杂学，这样一次体验事后想想其实还是挺有意思的（虽然当时真是各种不爽，中途也曾全部删光重来了一趟……）。

主要的教训还是不能怕麻烦。开始时我直接用别人做好的 LNMP 一键安装脚本，心想这样大概会方便些。然而事后证明这反而需要更多的学习成本与时间成本，出了不少意料之外的错误（毕竟脚本作者很难考虑到所有情况），并没能达到预期的效果。而且相较于目前的方案，VPS 硬盘空间多占用了三倍。最终我还是跟着教程自己手动配置了一遍，反倒是事半功倍。

至于建完站后本站用来干什么，我其实并没有仔细考虑过，只是单纯想试试，然后就搭建了。或许可以写个 LR2 配置教程（现在网上能找到的教程大多有些年代了）+ 発狂 BMS 零基础到入门（発狂初段）的课题指导；或许随便写点 AVG 测评练笔，以前一般都是发空间的，但一直是以 iPhone 备忘录截图的形式，就没法留底；~~或许大半年不更新咕咕咕~~。反正大概会是各种杂七杂八的东西。

过几天就开学了，难得的一个没有作业的暑假，终于能过得比较充实，做了很多自己想做的事情，也不用担心作业的问题。稍微期待一下大学的自主学习生活？

## 建站流程

{{< admonition note 说明 >}}
原文写于 2018-08-23，那时候其实基本啥都不会。在进入本科学习一年半后，有了一些新的理解，对此部分内容进行了大幅修改。
{{< /admonition >}}

建站实际上并不是一件难事，反倒可以说是毫无难度，即使是小学生也完全可以具备这个能力。当然，这句话是我建站一年半后才写的，刚开始时任何初学者（包括我）都可能不知道从哪里下手。其实什么事情都是这样的，正所谓「万事开头难」，这很正常。

以下我整理了一个大概的建站流程（但不是教程），主要目的在于告诉读者需要完成哪些工作，以及在哪里可以**找到**相关信息和资料——你当然需要自己动手。

### 1 获得 VPS 主机

#### 1.1 为什么选择 VPS

[VPS][vps-wiki] 并不是必需的，你完全可以选择 [虚拟主机][vhost-wiki] 作为替代方案。本文推荐使用 VPS，单纯只是因为喜欢控制权完全在自己手中，或者说，喜欢折腾。毕竟生命在于折腾嘛。

[vps-wiki]: https://en.wikipedia.org/wiki/Virtual_private_server
[vhost-wiki]: https://en.wikipedia.org/wiki/Virtual_hosting

{{< admonition tip 参考 >}}

- [VPS，云服务器（云主机），虚拟主机有什么异同？ - 知乎](https://www.zhihu.com/question/19856629)
- [VPS 有什么有趣的用途？ - 知乎](https://www.zhihu.com/question/24284566)

{{< /admonition >}}

#### 1.2 VPS 服务商选择

{{< image src="assets/select-vps.webp" caption="VPS 选择三色图" >}}

基本就是这么回事。

市面上常见的几家 VPS 其实早被国人用烂了，线路基本都很差。目前 [CN2 线路][cn2-wiki] 要好一点，当然价格也相对贵很多，还是自己看需求和预算。

我自己选择的服务商是 [CloudCone][cloudcone-cn]，主要还是因为便宜，而且姑且还算靠谱，但线路确实比较一般。不过反正最后也要套 CDN 的，建站的话一般优先考虑稳定性和价格，速度并不很关键。

[cn2-wiki]: https://www.vultrblog.com/what-is-a-cn2-line
[cloudcone-cn]: https://app.cloudcone.com.cn/signup?ref=1722

{{< admonition tip 参考 >}}

- [分享我对于 VPS 主机的一些经验给入坑萌新 - 初行博客](https://www.zrj96.com/post-762.html)

{{< /admonition >}}

#### 1.3 VPS 系统选择

一般推荐用 Linux，不推荐 Windows，又贵又吃配置，配环境还麻烦，完全没有必要。至于用 Linux 的哪一个发行版，看个人习惯就行。新手的话推荐开箱即用的 Ubuntu。

本文选择的是 Ubuntu 18.04 LTS。

#### 1.4 如何连接到 VPS

Windows 下推荐使用 [Xshell][xshell]，免费的 Home & School 版其实就完全够用了。macOS 下可以试试 [Termius][termius]。

[xshell]: https://www.netsarang.com/products/xsh_overview.html
[termius]: https://termius.com

{{< admonition tip 参考 >}}

- [Xshell 6 安装和使用教程 - CSDN](https://blog.csdn.net/qq_32653877/article/details/81984745)

{{< /admonition >}}

### 2 获得域名

不推荐国内域名商，**强烈**不推荐 Freenom（切记，**免费的永远是最贵的**）。推荐使用 [Cloudflare Registrar][cf-registrar]，仅收取 [ICANN](https://www.icann.org) 的成本价，十分良心。你也可以考虑先在其他地方注册（例如 [namecheap][namecheap] 和 [namesilo][namesilo]），蹭个首年优惠，然后再迁移到 Cloudflare。

{{< admonition warning 关于付款方式>}}
目前 Cloudflare 不支持支付宝，可以使用 [PayPal](https://www.paypal.com/us/home)，然后绑定国内银行卡。注意别注册成国内版的 贝宝。
{{< /admonition >}}

[cf-registrar]: https://www.cloudflare.com/products/registrar
[namecheap]: https://www.namecheap.com
[namesilo]: https://www.namesilo.com

### 3 配置 CDN

想提高国内访问速度（而且有钱）就上国内 CDN，想提高全球（除中国大陆以外地区）访问速度就上 [Cloudflare](https://www.cloudflare.com)。

本文推荐使用 Cloudflare，主要是因为免费、配置方便、功能全面（可以说是一条龙服务了）。实际上对于个人网站来说，Cloudflare 的免费套餐已经完全够用：**无限** CDN 流量、自带抗 DDoS 防护、自带 SSL 证书。而且因为是海外服务，不需要备案。只能说，Cloudflare yyds！

{{< admonition tip 参考 >}}

- [创建 Cloudflare 帐户并添加网站 – Cloudflare Support](https://support.cloudflare.com/hc/zh-cn/articles/201720164-%E5%88%9B%E5%BB%BA-Cloudflare-%E5%B8%90%E6%88%B7%E5%B9%B6%E6%B7%BB%E5%8A%A0%E7%BD%91%E7%AB%99)
- [开始使用 Cloudflare – Cloudflare Support](https://support.cloudflare.com/hc/zh-cn/articles/360027989951)

{{< /admonition >}}

### 4 开始建站

{{< admonition tip 阅读 >}}

- [极限建站 - YangMame](https://blog.yangmame.org/%E6%9E%81%E9%99%90%E5%BB%BA%E7%AB%99.html)

{{< /admonition >}}

这里就不重复造轮子了，我当时建站就是参考的这篇教程，个人感觉是写得比较好的一篇。本文假定你选择了 [NGINX][nginx] + [MariaDB][mariadb] + [PHP][php] + [Typecho][typecho] 方案，如果你需要使用其他方案请自行灵性修改。

在此教程中，你主要需要关注以下章节：

- 配置 VPS > 开启 BBR (KVM)
- Nginx（「写入配置」处可以只选择你需要用到的部分）
- Acme.sh
- Mariadb（「创建数据库和用户」处可以只选择你需要用到的部分）
- PHP（注意你安装的版本，例如 `7.2`，并对应修改 Nginx 配置里的 PHP 版本）
- Typecho

其余章节可以根据需要阅读（如 Nextcloud, qBittorrent 等），不是建站的必要环节。

文中提到的 [V2Ray][v2ray] 是新一代梯子，有兴趣的话推荐 [了解一下][v2ray-guide]。为避免引火烧身，本站不提供相关教程。

[nginx]: https://www.nginx.com
[mariadb]: https://mariadb.org
[php]: https://www.php.net
[typecho]: https://typecho.org
[v2ray]: https://www.v2ray.com
[v2ray-guide]: https://github.com/ToutyRater/v2ray-guide

## 结语

流程部分基本上是全部重写了一遍，删改了很多东西。两年前的自己实在是太菜了，让大家见笑啦。

当然，Wordpress / Typecho 这类 [CMS][cms-wiki] 方案并非建站的唯一选择，你们也可以尝试一下 Hexo / Hugo 这样的静态网站方案。

希望能对新手有一定的帮助，如有错误也欢迎在评论区指正补充，谢谢！

[cms-wiki]: https://en.wikipedia.org/wiki/Content_management_system
