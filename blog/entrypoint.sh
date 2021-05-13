#!/bin/bash
mkdir -p /var/run/nginx
rm -rf /etc/nginx/conf.d/default.conf
#Config Nginx Server
cat > /etc/nginx/conf.d/www.$domainname.conf << EOF
server {
    listen 80;
    server_name $domainname www.$domainname;
    location / {
        root /blog/public/;
        index index.html;
    }
}
EOF
nginx
echo "$(sed -e "s/domainname/$domainname/g" /blog/_config.yml)" > /blog/_config.yml
echo "$(sed -e "s/baidutoken/$baidutoken/g" /blog/_config.yml)" > /blog/_config.yml
echo "$(sed -e "s/bingtoken/$bingtoken/g" /blog/_config.yml)" > /blog/_config.yml
echo "$(sed -e "s/baiduanalytics/$baiduanalytics/g" /blog/themes/next/_config.yml)" > /blog/themes/next/_config.yml
hexo clean && hexo g -d
# 因为进行hexo clean的时候，会删除source/_posts/robots.txt文件，所以采用cat方式添加
cat > /blog/public/robots.txt << EOF
User-agent: *
Allow: /
Allow: /archives/
Allow: /categories/
Allow: /about/
Allow: /tags/
Sitemap: https://www.domainname/sitemap.xml
Sitemap: https://www.domainname/baidusitemap.xml

Disallow: /images/
Disallow: /js/
Disallow: /lib/
Disallow: /css/
Disallow: /fonts/
EOF
# 替换域名
echo "$(sed -e "s/domainname/$domainname/g" /blog/public/robots.txt)" > /blog/public/robots.txt
# 实时检测并同步文件
inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T|%e|%w%f' -e modify,delete,create,attrib /blog/source/_posts |  while read file 
do
    hexo g -d
done