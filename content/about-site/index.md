---
title: 关于本站
date: 2022-10-14T15:30:00+08:00
weight: -2

featuredImage: https://hakula-1257872502.file.myqcloud.com/images/3/article-covers/4010eeb1-bb77-4b22-a57d-1faeeaff57f8_70180757.webp
---

<!-- markdownlint-disable MD053 -->

{{< admonition info 封面出处 >}}
[Prism Castle - @c.c.R](https://www.pixiv.net/artworks/70180757)
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
| 网盘 | [Cloudreve] & [Backblaze B2][B2]              |
| 图床 | [兰空图床][Lsky] & [腾讯云 COS][COS]          |
| 监控 | [Netdata] & [UptimeRobot]                     |

[@Dillon]: https://github.com/dillonzq
[B2]: https://www.backblaze.com/cloud-storage
[CloudCone]: /links/cloudcone-cn
[Cloudflare]: https://www.cloudflare.com
[Cloudreve]: https://cloudreve.org
[COS]: https://cloud.tencent.com/product/cos
[h5ai]: https://larsjung.de/h5ai
[Hugo]: https://gohugo.io
[Lighthouse]: https://cloud.tencent.com/product/lighthouse
[LoveIt]: https://hugoloveit.com
[Lsky]: https://www.lsky.pro
[Netdata]: https://www.netdata.cloud
[OneDrive]: https://www.microsoft.com/microsoft-365/onedrive/onedrive-for-business
[Twikoo]: https://twikoo.js.org
[UptimeRobot]: https://uptimerobot.com

{{< /style >}}

## 更新日志

| 日期           | 更新内容                                                                                                                                 |
| :------------- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| 2025‑07‑28     | 文件库迁移至 [Cloudreve] 方案，底层使用 [Backblaze B2][B2] 对象存储。                                                                    |
| 2025‑04‑07     | [LoveIt] sync upstream 至 v0.3.0 版本，Hugo 升级至 v0.145.0 版本，解决各种兼容性问题。                                                   |
| **2022‑11‑13** | [LoveIt] 主题魔改基本完毕。新站迁移计划完成，总耗时 346 小时。                                                                           |
| 2022‑10‑28     | 使用 [兰空图床][Lsky] 自建图床，实现评论区图片上传功能。                                                                                 |
| 2022‑10‑24     | 原站所有评论迁移完毕。                                                                                                                   |
| 2022‑10‑14     | 原站所有文章迁移并审校完毕。                                                                                                             |
| 2022‑09‑29     | 使用 [Netdata] 实现服务器各项指标的实时监控。                                                                                            |
| 2022‑09‑28     | 配置 [GitHub Webhooks][Webhooks] 实现网站自动化部署，作为 [Cloudflare Pages][cf-pages] 的替补方案。                                      |
| 2022‑03‑03     | 服务器迁移完毕。从 [CloudCone] 迁移至 [腾讯云 :singapore:][Lighthouse]，内存配置从 1 GB 升级至 2 GB。                                    |
| 2022‑02‑10     | 接入 [Twikoo] 评论系统，原站所有评论待转移。                                                                                             |
| 2022‑01‑25     | 接入 [Algolia] 实现站内搜索功能。                                                                                                        |
| 2022‑01‑24     | 接入 [Cloudflare Pages][cf-pages] 实现网站 Serverless 部署。                                                                             |
| **2022‑01‑17** | 新站迁移计划启动，弃用 [Typecho]，改用 [Hugo] 框架。所有文章重新审校并优化排版。                                                         |
| 2021‑09‑01     | 由于被 Pixiv 官方封禁，现停止维护 Pixiv 镜像站。                                                                                         |
| 2020‑12‑29     | 服务器迁移完毕。CPU 配置从 1 核升级至 2 核，年付 `$ 16`。弃用 [gdrive]，改用 [rclone] 定期全量备份到 [腾讯云 COS][COS]。                 |
| 2020‑01‑14     | 由于免费域名 .ml 被 Freenom 回收，且兴趣已过，现停止维护 Google 和 Wikipedia 镜像站，仅维护 Pixiv 镜像站。                               |
| 2020‑01‑03     | 服务器迁移完毕。趁圣诞特惠，内存配置从 512 MB 升级至 1 GB，年付 `$ 18`。                                                                 |
| 2019‑06‑06     | 由于目前本站的垃圾评论几乎全部来自俄罗斯，封了一堆 IP 仍屡禁不止，考虑到本站基本也不会有真正的俄罗斯访客，今日起全面禁止俄罗斯 IP 访问。 |
| 2019‑05‑13     | 更新了音乐播放器使用的 cookies，尝试解决网易云的防盗链问题。                                                                             |
| 2019‑05‑09     | 使用 [h5ai] 提供私有云存储的补充方案。                                                                                                   |
| 2019‑05‑06     | [PyOne] 仍未解决 API 调用超限的问题，考虑到 [OneDrive] 企业版无需科学上网即可直接访问，现直接使用 [OneDrive] 自带的分享功能。            |
| 2019‑04‑27     | 由于 [OneIndex] 存在 API 调用次数限制，尝试改用 [PyOne] 方案。                                                                           |
| 2019‑02‑09     | [handsome] 主题更新至 5.0 版本。                                                                                                         |
| 2019‑01‑10     | 使用 [LoveKKComment] 插件实现评论邮件通知功能。                                                                                          |
| 2019‑01‑01     | 接入 [UptimeRobot] 实现服务上线时间监控。                                                                                                |
| 2018‑11‑25     | 服务器迁移完毕。趁黑五特惠，内存配置从 256 MB 升级至 512 MB，年付 `$ 15`。                                                               |
| 2018‑11‑05     | 由于服务器负载及流量消耗较大，弃用 [Nextcloud]，改用 [OneDrive] + [OneIndex] 方案。                                                      |
| 2018‑11‑04     | 使用 [Nextcloud] 自建私有云存储。                                                                                                        |
| 2018‑10‑21     | 使用 [腾讯云 COS][COS] 作为图床，提高图片在国内的加载速度。                                                                              |
| 2018‑09‑16     | [handsome] 主题更新至 4.5 版本。                                                                                                         |
| 2018‑08‑25     | [handsome] 主题魔改基本完毕。网站源码及数据通过 [gdrive] 定期全量备份到 Google Drive。                                                   |
| **2018‑08‑20** | HAKULA†CHANNEL 诞生，域名：[hakula.xyz]，框架：[Typecho]，主题：[handsome]。                                                             |

[Algolia]: https://www.algolia.com
[B2]: https://www.backblaze.com/cloud-storage
[cf-pages]: https://pages.cloudflare.com
[CloudCone]: /links/cloudcone-cn
[Cloudreve]: https://cloudreve.org
[COS]: https://cloud.tencent.com/product/cos
[gdrive]: https://github.com/prasmussen/gdrive
[h5ai]: https://larsjung.de/h5ai
[hakula.xyz]: https://www.whois.com/whois/hakula.xyz
[handsome]: https://www.ihewro.com/archives/489
[Hugo]: https://gohugo.io
[Lighthouse]: https://cloud.tencent.com/product/lighthouse
[LoveIt]: https://hugoloveit.com
[LoveKKComment]: https://github.com/ylqjgm/LoveKKComment
[Lsky]: https://www.lsky.pro
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
