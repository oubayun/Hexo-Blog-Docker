#!/bin/bash
#Config Certs
mkdir -p /etc/nginx/certs && mkdir -p /var/run/nginx
rm -rf /etc/nginx/conf.d/default.conf
/root/.acme.sh/acme.sh --issue --dns dns_dp -d $domainname -d www.$domainname --cert-file /etc/nginx/certs/www.$domainname.crt --key-file /etc/nginx/certs/www.$domainname.key --ca-file /etc/nginx/certs/www.$domainname.ca.cer --fullchain-file /etc/nginx/certs/www.$domainname.pem --dnssleep 60
#Config Nginx Server
cat > /etc/nginx/conf.d/www.$domainname.conf << EOF
server {
    listen 80;
    server_name $domainname www.$domainname;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $domainname www.$domainname;
    ssl_protocols TLSv1.2;
    ssl_ciphers AESGCM+ECDH:ARIAGCM+ECDH:CHACHA20+ECDH:!aNULL:!MD5:!DSS:!AESCCM:!RC4:!DHE;
    ssl_certificate /etc/nginx/certs/www.$domainname.pem;
    ssl_certificate_key /etc/nginx/certs/www.$domainname.key;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    add_header X-Frame-Options "DENY";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header X-Download-Options noopen;
    add_header X-Permitted-Cross-Domain-Policies none;
    client_max_body_size 512M;
    fastcgi_buffers 64 4K;
    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 16k;
    gzip_comp_level 6;
    gzip_types text/plain application/x-javascript text/css application/xml;
    gzip_vary on;
    location / {
        root /blog/public/;
        index index.html index.htm;
    }
}
EOF
crond
nginx
# 替换域名
sed -i "s/domainname/$domainname/g" /blog/public/robots.txt
sed -i "s/domainname/$domainname/g" /blog/_config.yml
# 设置百度收录Token
sed -i "s/baidutoken/$baidutoken/g" /blog/_config.yml
#实时检测并同步文件
inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T|%e|%w%f' -e modify,delete,create,attrib /blog/source/_posts |  while read file 
do  
    if [[ $file == *.md ]]
    then
        INO_EVENT=$(echo $file | awk -F '|' '{print $2}')
        if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]]
        then
            INO_FILE=$(echo $file | awk -F '|' '{print $3}')
            sleep 2
            sed -i "s#(_v_images#(/_v_images#g" "$INO_FILE"
        fi
        hexo g -d 
    elif [[ $file == *.png ]] || [[ $file == *.jpg ]]
    then
        rsync -avz /blog/source/_posts/_v_images /blog/public/ --delete
    fi
done
