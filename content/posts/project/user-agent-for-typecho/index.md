---
title: UserAgent for Typecho
date: 2019-01-27T21:58:00+08:00

tags: [PHP, Typecho]
categories: [project]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/3/article-covers/77a35a51-7664-46a3-aa46-4ba353b7cff9_39186698.webp
license: CC BY-NC-SA 4.0
---

一个 Typecho 插件，用于在评论区显示用户使用的操作系统、浏览器信息及相应图标。自己动手，丰衣足食！

<!--more-->

{{< admonition info 封面出处 >}}
[クロス・ホエン - @おにねこ](https://www.pixiv.net/artworks/39186698)
{{< /admonition >}}

{{< admonition success 源码地址 >}}
[:(fab fa-github):  hakula139 / UserAgent-for-Typecho](https://github.com/hakula139/UserAgent-for-Typecho)
{{< /admonition >}}

## 使用说明

1. 解压并修改文件夹名为 `UserAgent`，将插件上传至网站目录的 `/usr/plugins` 下。
2. 在 Typecho 后台「插件管理」处启用插件。
3. 在需要显示 UserAgent 的地方插入以下代码[^1]。

```php
<?php UserAgent_Plugin::render($comments->agent); ?>
```

## 版本历史

{{< style "table td { min-width: 7rem; }" >}}

| 版本     | 完成日期   | 更新内容                                                             |
| :------- | :--------- | :------------------------------------------------------------------- |
| `v0.2.0` | 2019‑01‑28 | 将 UserAgent 的识别逻辑转移至本地，移植了 WordPress 插件的识别方法。 |
| `v0.1.0` | 2019‑01‑27 | 第一个版本，尚处于测试阶段，请勿用于生产环境。                       |

{{< /style >}}

## 致谢

### 原项目

{{< admonition success 源码地址 >}}
[:(fab fa-github):  ennnnny / typecho / UserAgent](https://github.com/ennnnny/typecho/tree/master/UserAgent)
{{< /admonition >}}

本项目基于 @ennnnny 的项目改写，在此感谢。

实际上本来我自己用的就是这个插件，但有些地方不是很满意，而原作者似乎也不更新了，于是我就打算「自己动手，丰衣足食」，本项目因此诞生。

### WordPress 原插件

> [WP-UserAgent - WordPress plugin - WordPress.org](https://wordpress.org/plugins/wp-useragent)

本项目的实质就是将 WordPress 的 UserAgent 插件移植到 Typecho，在此感谢原作者 [Kyle Baker](https://www.kyleabaker.com)。

### Iconfont

> [Iconfont - 阿里巴巴矢量图标库](https://www.iconfont.cn)

本项目中使用的操作系统、浏览器 SVG 图标均来自 Iconfont 矢量图标库，在此感谢。

## 问题反馈

由于本人实际只是代码初学者（甚至没学过 PHP :thinking:），又是第一次使用 GitHub，很多地方都不太明白，还请大家多多指教。

如果遇到问题，除了在 GitHub 提 issue 外，也可以在本文的评论区留言，或者通过 [邮箱](mailto:i@hakula.xyz) 联系我。

希望本插件能帮助到有需要的博主。

[^1]: 以 handsome 主题为例，即添加到 `handsome/component/comments.php` 里 `<span class="comment-author vcard">` ... `</span>` 的后面。
