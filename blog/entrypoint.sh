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
#实时检测并同步文件
inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T|%e|%w%f' -e modify,delete,create,attrib /blog/source/_posts |  while read file 
do
    hexo g -d
done