---
title: CloudCone VPS
date: 2020-01-31T03:21:00+08:00

tags: [VPS]
categories: [vps]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/3/article-covers/f2df41d3-0d79-4676-9bd1-caa44241875a_cloudcone.webp
license: CC BY-NC-SA 4.0
---

本站选择的 VPS 商家。低配机年付 15 刀，月流量 1 TB 起，1 Gbps 端口，部署于洛杉矶 Multacom 机房，CN2 GIA 线路，支持支付宝。

<!--more-->

## 主观评价

从建站起用到现在，不吹不黑，对 CloudCone 作一个理性评价，请读者自行考虑是否要选用这家的 VPS。

CloudCone 最主要的特点还是便宜，在黑五、圣诞等特惠活动中有时会出现年付 `$ 15` 左右的机子（常见配置：1 核 + 512 MB 内存 + 1 TB 月流量），这在知名商家里已经算很低的价格了。对于个人建站或者科学上网的需求来说，这样的最低配置已经完全够用。没错，你当然有机会找到比这个价格更低的 VPS，但那些基本都可以称为「灵车」，要么来自随时可能跑路的小商家，要么用的是 OpenVZ 架构，超售现象严重。对于没什么 VPS 购买经验的新手来说，很容易上当受骗、灵车漂移。从这个角度来说，CloudCone 应该是**靠谱**商家里最便宜的之一。

如何判断一个商家靠不靠谱，看它的「工单回应速度」和「退款难易程度」就可以了。一般来说，如果一个商家给客服发工单得不到回应，或者磨蹭好几天甚至更久才回应的，还是趁早换一家吧。此外，你可以尝试在购买一个套餐后退款，一个靠谱的商家通常会立即按剩余时间直接退款到你的账户，好一点的还能原路退回你的支付途径；而垃圾的商家则不然，要么突然出现各种莫名其妙的手续费，要么发退款工单不给回应，总之退款难如登天（参考 ofo 小黄车退押金）。从这两方面来说，首先，CloudCone 的工单服务相当优秀，基本都是一线技术人员直接对接，因而能对症下药地给出切实可行的解决方案；同时，CloudCone 支持全额退款，你只需直接删除服务器，就会自动按剩余时间（按小时计费）退款，无需其他繁杂手续。

{{< admonition warning 注意 >}}
CloudCone 于 2021-10-06 修改了 [条款](https://help.cloudcone.com/en-us/article/how-billing-works-for-promotional-plans-19bj5lr)，目前只有购买后的**前 7 天**（作为试用期）月付 / 年付套餐可以按剩余时间全额退款，此后将**无法退款**。
{{< /admonition >}}

关于支付途径，目前 CloudCone 支持支付宝，这既是好事也是坏事。好事是对国人来说支付很方便、无门槛，坏事也同样在于此。所以单论 VPS 商家推荐的话，反而更推荐那些不支持支付宝 / 微信支付的商家。毕竟只要哪里国人一扎堆，哪里就烂了（或者在被用烂的路上）。

CloudCone 于 2019-05 接入了 CN2 GIA 线路，这很大程度上改善了曾经线路烂的情况。目前就我所在的地区（上海）而言，延迟大概在 180 ms 左右，速度也很快（不保证高峰期能看油管 4K，但至少 1080P 是没问题的）。当然，如此廉价的 CN2 GIA 线路也吸引了大量国人，未来线路逐渐变差可能也是大势所趋，反正现在先用着看吧。由于国人众多，特殊时期偶尔也会受到 GFW 的特别关照，这就是不可抗力了。

配置方面，CloudCone 的 CPU 通常是 Intel Xeon E5 (2.6 GHz)，但有些优惠套餐可能会缩水降频到 2.1 GHz，这点不会在配置单里明讲，需要到时候自己在机子上跑下分验货。此外，CloudCone 的硬盘如无特殊说明一般都是 HDD，速度较慢，有性能需求的话建议买标注 SSD 的机子（但建议也跑下分看看是不是真的 SSD）。

总体来说，CloudCone 的性价比还是比较高的，我个人比较推荐这家。本站目前也是部署在这家的 VPS 上（配置：2 核 @ 2.6 GHz + 1 GB 内存 + 25 GB SSD + 5 TB 月流量的 SC2，年付 `$ 16.16`，来自 2020 年黑五特惠）。

{{< image src="assets/instance.webp" caption="本站使用的 VPS 配置" >}}

## 一些特性

{{< admonition success 特性 >}}

- 采用 [KVM][kvm] 架构，支持 [BBR][bbr] 加速。
- 提供免费按需抗 1 Tb/s DDoS 防护，可升级至实时抗 1 Tb/s DDoS 防护，详见 [这里][ddos]。
- 非优惠套餐按小时计费，关机状态仅收取部分费用，中途删除服务器直接按剩余时间退款（月付 / 年付套餐不适用，详见 [这里][sc2-billing] 和 [这里][vps-billing]）。
- 支持支付宝、PayPal、信用卡三种支付途径。
- 支持公网 IPv6（需手动启用）。

[kvm]: https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine
[bbr]: https://github.com/google/bbr
[ddos]: https://cloudcone.com/ddos-protection
[sc2-billing]: https://help.cloudcone.com/en-us/article/how-am-i-billed-for-scalable-cloud-servers-x8afmx
[vps-billing]: https://help.cloudcone.com/en-us/article/how-billing-works-for-virtual-private-servers-19bj5lr

{{< /admonition >}}

{{< admonition warning 注意 >}}

CloudCone 直接开出来的 IP 有可能是被墙的（或许能 ping 通，但不能 SSH 连接），如果遇到这种情况建议直接 [提交工单][support] 要求更换 IP（英语交流），新 IP 将确保可用，每次更换 `$ 2`。

**不建议**通过反复删除重建服务器来刷 IP，基本刷不到可用的 IP，费时费力且效果甚微。

[support]: https://app.cloudcone.com/support/list

{{< /admonition >}}

## 立即购买

本来这篇文章会整理一些优惠套餐信息，因为这些套餐不会在官网直接展示。但我实在是太忙了，完全抽不出时间去整理。因此这里我打算「授人以鱼不如授之以渔」，直接提供获取这些信息的方法。

事实上，你只需要注册后进入账号设置（点击右上角头像 > Settings），在「Email Subscriptions」栏勾选「Compute Offers (Special offers for compute servers)」选项即可。这样你以后就会在邮箱里不定时收到最新的 VPS 优惠信息，不用等 affman 的二手消息了！考虑到一些高性价比限量 VPS（比如我现在用的这台）的火爆程度，等 affman 的文章更新出来再被你看到，早就售罄啦 :kissing_heart:。

如果对 CloudCone 感兴趣，可以先注册个账号看看情况（反正不要钱）。按目前的频率平均每周就有一封优惠信息邮件，届时按需购买即可。一般这些日常优惠的力度不算大，推荐等黑五、圣诞这两个时间节点再入手。注意理性消费。

{{< admonition success 官网地址 >}}

[:(fas fa-right-to-bracket):  官网注册（已被墙）](/links/cloudcone)

[:(fas fa-right-to-bracket):  官网注册 - 国内镜像](/links/cloudcone-cn)

{{< /admonition >}}

## 附加功能

CloudCone 还提供了一些附加功能，可以按需选择。有些位于控制面板内，有些则需要发工单申请。对于一些优惠套餐，有时也会附赠其中的一些功能（例如自动备份和快照）。

{{< style "table { min-width: 20rem; }" >}}

| 附加功能     | 定价（月付）   |
| :----------- | :------------- |
| 附加公网 IP  | `$ 1.00`       |
| DDoS 高防 IP | `$ 2.00`       |
| 自动备份     | 35% VPS 月租   |
| 快照         | `$ 0.09` / GB  |
| CDN 加速     | `$ 0.045` / GB |
| cPanel 面板  | `$ 12.50`      |
| CloudLinux   | `$ 9.00`       |

{{< /style >}}
