---
title: 关于本站
date: 2022-10-14T15:30:00+08:00

featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/67767892.webp
---

{{< admonition info 封面出处 >}}
[log3 - @凪白みと](https://www.pixiv.net/artworks/67767892)
{{< /admonition >}}

## 技术选型

{{< style "table { min-width: initial; th, td { white-space: nowrap; } }" >}}

| 项目 | 方案                                          |
| :--- | :-------------------------------------------- |
| 框架 | [Hugo]                                        |
| 主题 | [LoveIt] - [@Dillon]                          |
| 评论 | [Twikoo]                                      |
| VPS  | [腾讯云 Lighthouse][Lighthouse] & [CloudCone] |
| DNS  | [Cloudflare]                                  |
| CDN  | [Cloudflare]                                  |
| 图床 | [腾讯云 COS][COS]                             |
| 网盘 | [OneDrive] & [h5ai]                           |
| 监控 | [Netdata] & [UptimeRobot]                     |

[@Dillon]: https://github.com/dillonzq
[CloudCone]: /links/cloudcone-cn
[Cloudflare]: https://www.cloudflare.com
[COS]: https://cloud.tencent.com/product/cos
[h5ai]: https://larsjung.de/h5ai
[Hugo]: https://gohugo.io
[Lighthouse]: https://cloud.tencent.com/product/lighthouse
[LoveIt]: https://hugoloveit.com
[Netdata]: https://www.netdata.cloud
[OneDrive]: https://www.microsoft.com/microsoft-365/onedrive/onedrive-for-business
[Twikoo]: https://twikoo.js.org
[UptimeRobot]: https://uptimerobot.com

{{< /style >}}

## 留言板

如对本站有任何建议或想法，欢迎在本页面下方留言。对于具体文章的留言请移步文章评论区。

头像将根据你填写的邮箱地址自动获取。如使用 QQ 邮箱则解析为 QQ 头像，否则解析为 [Gravatar] 头像。若未设置 Gravatar 头像，则使用 [identicon] 生成的随机头像。

目前暂时没有严格的评论审核机制，**请勿**在评论区发布广告或其他垃圾信息，违者没有警告，直接封禁 IP。评论收到回复后，你将在之前填写的邮箱地址收到邮件通知。

[Gravatar]: https://en.gravatar.com
[identicon]: https://www.npmjs.com/package/identicon

## 更新日志

{{< style `
.details .details-content {
  padding: 0;
}

.admonition .admonition-content {
  padding: 0;

  .table-wrapper {
    margin: 0;
  }
}

table td {
  min-width: 6.5rem;
}
` >}}

| 日期       | 更新内容                     |
| :--------- | :--------------------------- |
| 2022-10-14 | 原站所有文章迁移并审校完毕。 |

{{< admonition note 历史更新日志 false >}}

| 日期           | 更新内容                                                                                                                                 |
| :------------- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| 2022-09-29     | 使用 [Netdata] 实现服务器各项指标的实时监控。                                                                                            |
| 2022-09-28     | 配置 [GitHub Webhooks][Webhooks] 实现网站自动化部署，作为 [Cloudflare Pages][cf-pages] 的替补方案。                                      |
| 2022-03-03     | 服务器迁移完毕。从 [CloudCone] 迁移至 [腾讯云 :singapore:][Lighthouse]，内存配置从 1 GB 升级至 2 GB。                                    |
| 2022-02-10     | 接入 [Twikoo] 评论系统，原站所有评论待转移。                                                                                             |
| 2022-01-25     | 接入 [Algolia] 实现站内搜索功能。                                                                                                        |
| 2022-01-24     | 接入 [Cloudflare Pages][cf-pages] 实现网站 Serverless 部署。                                                                             |
| 2022-01-17     | 新站迁移计划启动，弃用 [Typecho]，改用 [Hugo] 框架。所有文章重新审校并优化排版。                                                         |
| 2021-09-01     | 由于被 Pixiv 官方封禁，现停止维护 Pixiv 镜像站。                                                                                         |
| 2020-12-29     | 服务器迁移完毕。CPU 配置从 1 核升级至 2 核，年付 `$ 16`。弃用 [gdrive]，改用 [rclone] 定期全量备份到 [腾讯云 COS][COS]。                 |
| 2020-01-14     | 由于免费域名 .ml 被 Freenom 回收，且兴趣已过，现停止维护 Google 和 Wikipedia 镜像站，仅维护 Pixiv 镜像站。                               |
| 2020-01-03     | 服务器迁移完毕。趁圣诞特惠，内存配置从 512 MB 升级至 1 GB，年付 `$ 18`。                                                                 |
| 2019-06-06     | 由于目前本站的垃圾评论几乎全部来自俄罗斯，封了一堆 IP 仍屡禁不止，考虑到本站基本也不会有真正的俄罗斯访客，今日起全面禁止俄罗斯 IP 访问。 |
| 2019-05-13     | 更新了音乐播放器使用的 cookies，尝试解决网易云的防盗链问题。                                                                             |
| 2019-05-09     | 使用 [h5ai] 提供私有云存储的补充方案。                                                                                                   |
| 2019-05-06     | [PyOne] 仍未解决 API 调用超限的问题，考虑到 [OneDrive] 企业版无需科学上网即可直接访问，现直接使用 [OneDrive] 自带的分享功能。            |
| 2019-04-27     | 由于 [OneIndex] 存在 API 调用次数限制，尝试改用 [PyOne] 方案。                                                                           |
| 2019-02-09     | [handsome] 主题更新至 5.0 版本。                                                                                                         |
| 2019-01-10     | 使用 [LoveKKComment] 插件实现评论邮件通知功能。                                                                                          |
| 2019-01-01     | 接入 [UptimeRobot] 实现服务上线时间监控。                                                                                                |
| 2018-11-25     | 服务器迁移完毕。趁黑五特惠，内存配置从 256 MB 升级至 512 MB，年付 `$ 15`。                                                               |
| 2018-11-05     | 由于服务器负载及流量消耗较大，弃用 [Nextcloud]，改用 [OneDrive] + [OneIndex] 方案。                                                      |
| 2018-11-04     | 使用 [Nextcloud] 自建私有云存储。                                                                                                        |
| 2018-10-21     | 使用 [腾讯云 COS][COS] 作为图床，提高图片在国内的加载速度。                                                                              |
| 2018-09-16     | [handsome] 主题更新至 4.5 版本。                                                                                                         |
| 2018-08-25     | [handsome] 主题魔改基本完毕。网站源码及数据通过 [gdrive] 定期全量备份到 Google Drive。                                                   |
| **2018-08-20** | HAKULA†CHANNEL 诞生，域名：[hakula.xyz]，框架：[Typecho]，主题：[handsome]。                                                             |

[Algolia]: https://www.algolia.com
[cf-pages]: https://pages.cloudflare.com
[CloudCone]: /links/cloudcone-cn
[COS]: https://cloud.tencent.com/product/cos
[gdrive]: https://github.com/prasmussen/gdrive
[h5ai]: https://larsjung.de/h5ai
[hakula.xyz]: https://www.whois.com/whois/hakula.xyz
[handsome]: https://www.ihewro.com/archives/489
[Hugo]: https://gohugo.io
[Lighthouse]: https://cloud.tencent.com/product/lighthouse
[LoveKKComment]: https://github.com/ylqjgm/LoveKKComment
[Netdata]: https://www.netdata.cloud
[Nextcloud]: https://nextcloud.com
[OneDrive]: https://www.microsoft.com/microsoft-365/onedrive/onedrive-for-business
[OneIndex]: https://github.com/0oVicero0/oneindex
[PyOne]: https://github.com/abbeyokgo/PyOne
[rclone]: https://rclone.org
[Twikoo]: https://twikoo.js.org
[Typecho]: https://typecho.org
[UptimeRobot]: https://uptimerobot.com
[Webhooks]: https://docs.github.com/en/developers/webhooks-and-events/webhooks/about-webhooks

{{< /admonition >}}

{{< /style >}}
