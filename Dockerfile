FROM node:13.10.1-alpine3.11
# 设置标签
LABEL author=欧巴云 email=muzilee@oubayun.com site=https://oubayun.com
#添加网站代码
ADD ./blog/package.json /blog/package.json
#安装证书管理所需包及hexo所需包(package.json)
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk update && apk add --no-cache tzdata nginx inotify-tools \
    && npm config set unsafe-perm true \
    && npm config set registry https://registry.npm.taobao.org \
    && npm install -g hexo-cli \
    && cd /blog && npm install
#添加Nginx Gzip功能
RUN apk add --no-cache --virtual .build-deps curl tar gcc g++ \
    && curl -o nginx-1.16.1.tar.gz https://nginx.org/download/nginx-1.16.1.tar.gz \
    && tar -zxvf nginx-1.16.1.tar.gz \
    && cd nginx-1.16.1 \
    && ./configure --prefix=/etc/nginx --with-http_gzip_static_module --without-http_rewrite_module --without-http_gzip_module \
    && apk del .build-deps \
    && cd .. && rm -rf nginx-1.16.1* \
    && apk add bash 
#添加Blog源码
ADD ./blog /blog
# 设置时区
ENV TZ Asia/Shanghai
# 设置当前工作目录
WORKDIR /blog
# 使用hexo-server托管静态文件
ENTRYPOINT ["./entrypoint.sh"]
