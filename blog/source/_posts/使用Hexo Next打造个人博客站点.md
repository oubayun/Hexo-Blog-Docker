---
title: 使用Hexo Next打造个人博客站点
date: 2020-03-28 12:30:00
tags: [Hexo Next,Hexo Blog,Alpine Hexo Blog Docker]
categories: IT杂类
copyright: true
top: 0
---
---

文章声明：此文基于木子实操撰写  
生产环境：node:13.10.1-alpine3.11 + Hexo v4.2.0 + NexT.Gemini v7.7.2  
问题关键字：Hexo Next,Hexo Blog,Alpine Hexo Blog Docker

---

# 镜像说明
此Docker镜像由[欧巴云](https://www.oubayun.com)基于node:13.10.1-alpine3.11 + Hexo v4.2.0 + NexT.Gemini v7.7.2打造。采用Traefik做为前端反向代理，使用ACME dnsChallenge功能进行Let's encrypt免费证书申请，并自动续期证书，通过 [SSL Labs](https://www.ssllabs.com/) A+级SSL/TLS证书认证。使用Nginx进行静态页面站点发布，采用Gitee作为[图床](https://www.oubayun.com/use-vnote-gitee-image-bed-hexo-docker-to-create-a-blog-wechat-public-account-markdown-post-editing-artifact.html)，并启用gzip压缩功能以提高网站访问速度。（Traefik功能未存在于此Docker镜像中，需要单独部署，此镜像仅支持http。）  

<!-- more -->

~~**原自带HTTPS：**此Docker镜像由[欧巴云](https://www.oubayun.com)基于node:13.10.1-alpine3.11 + Hexo v4.2.0 + NexT.Gemini v7.7.2打造。采用ACME dnsChallenge功能进行Let's encrypt免费证书申请，并使用定时任务实现证书自动续期。通过Nginx进行站点发布，在提高此博客系统并发访问能力的同时，通过 [SSL Labs](https://www.ssllabs.com/) A+级SSL/TLS证书认证。~~  

![](https://oubayun.gitee.io/blogimage/_v_images/20200401162824748_1757398107.png)

# 业务实现逻辑
![](https://oubayun.gitee.io/blogimage/_v_images/20200401162243616_1850925931.png)

# 站点主界面
![](https://oubayun.gitee.io/blogimage/_v_images/20200401162243616_1850925932.png)

# 版本说明
## 2020年3月27日主要功能说明 v1.0
* 采用Alpine3.11构建Hexo v4.2.0+NexT.Gemini v7.7.2个人博客Docker镜像；
* 新增基于Let's encrypt ACME DNS证书自动生成功能（腾讯云）；
* 新增inotifywait文件级修改监控，实现静态网站自动构建；
* 基于Nginx进行网站发布，提高网站并发能力；
* 配置rsync增量同步，实现vNote所写Markdown文档，直接sftp上传后自动构建部署功能；

## 2020年3月30日主要功能说明 v1.1
* 添加Nginx gzip模块；
* 配置站点启动Nginx gzip压缩功能；

## 2020年4月4日主要功能说明 v1.2
* 修正inotifywait监控文件多事件下Markdown文档多次构建部署问题；
* 新增基于vNote编写的Markdown文档sftp同步以后，\_v\_images自动替换路径为绝对路径功能；

## 2020年5月3日主要功能说明 v1.3
* 本次更新主要针对SEO优化；
* 添加网站地址(sitemap)功能；
* 添加爬虫规范文件robots.txt；
* 优化文章链接地址，自动翻译标题成拼音，并修改链接地址为: https://域名/文章拼音名.html；
* 添加nofollow功能，并排除友情链接；

## 2021年4月4日主要功能说明 v1.4
* 添加纯http模式Docker镜像，采用Traefik反向代理提供ACME证书管理与http跳转https，不再通过Docker本身提供ACME功能；
* 优化字体，优先采用【Sarasa Mono SC】等宽字体，提高代码可读性；

## 2021年5月6日主要功能说明 v1.5
* 添加百度专用sitemap: baidusitemap.xml;
* 全局使用域名环境变量，确保镜像可以直接拿来使用，不需要再修改任何配置；

## 2021年5月13日主要功能说明 v1.6
* 添加百度收录、Bing收录、Google收录主动推送功能；
* 将全局_config.yml及主题_config.yml配置成外部挂载模式，使用者可以根据自己需求挂载对应配置文件即可；
* 关于SEO插件设置，详细参考：[hexo-submit-urls-to-search-engine 中文文档](https://cjh0613.com/20200603HexoSubmitUrlsToSearchEngine.html)；
* 优化百度网站访问量统计管理，获取[百度统计ID](https://tongji.baidu.com/sc-web)，管理--代码管理--代码获取；

## 计划功能实现说明 v1.7
* ~~新增基于Let's encrypt ACME DNS证书自动生成功能（阿里云）；~~
* ~~新增基于阿里云、腾讯云 DNSAPI实现A记录解析自动添加；~~

# 部署方式
 **[推荐]** docker-compose方式部署参考配置文件:   

[Gitee docker-compose.yaml](https://gitee.com/oubayun/Hexo-Blog-Docker/blob/master/docker-compose.yaml)

[Github docker-compose.yaml](https://github.com/oubayun/Hexo-Blog-Docker/blob/master/docker-compose.yaml)
```bash
# 启动服务
docker-compose up -d
# 停止服务
docker-compose down
```

docker方式部署如下：
```bash
docker run -p 80:80 \
# 博文存放目录
-v /mdfiles:/blog/source/_posts \
# Google SEO 主动推送授权文件
-v /google_service_account.json:/blog/google_service_account.json \
# 公共配置文件
-v /_config.yml:/blog/_config.yml \
# 主题配置文件
-v /themes_config.yml:/blog/themes/next/_config.yml \
# 关于我们 页面
-v /index.md:/blog/source/about/index.md \
# 网站域名，不要带www，脚本会自动添加
-e "domainname=oubayun.com" \
# 百度 SEO 主动推送授权token
-e "baidutoken=xxx" \
# Bing SEO 主动推送授权Token
-e "bingtoken=xxx" \
# 百度网站访问量统计ID
-e "baiduanalytics=xxx"
oubayun/hexo-blog:latest
```

**[不再更新]** HTTPS docker方式部署如下：
```bash
docker run -p 80:80 -p 443:443 -v /mdfiles:/blog/source/_posts \
-e "domainname=www.oubayun.com" -e "baidutoken=xxxx" -e "DP_Id=xxxx" -e "DP_Key=xxxx" \
oubayun/hexo-blog:latest
```