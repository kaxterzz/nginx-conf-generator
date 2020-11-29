#!/usr/bin/env bash

#variables
UP_SERVER_NAME=$(head -n 1 domains.txt | cut -f1 -d".")

SERVER_NAME=$(while IFS= read -r line; do
        echo -ne "unsubscribe.$line "; 
    done < domains.txt)

NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'

NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'

# Create nginx config file
sudo cat > $UP_SERVER_NAME.conf << EOF
upstream unsub-server-$UP_SERVER_NAME {
    server 127.0.0.1:5000;
    keepalive 64;
}

server {
    listen 80 ; 
    server_name $SERVER_NAME ;


    #Include Security Headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header Strict-Transport-Security "max-age=31536000;  includeSubdomains; preload";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options nosniff;
    #add_header set_cookie_flag HttpOnly secure;

    add_header 'Referrer-Policy' 'strict-origin-when-cross-origin';
    add_header Feature-Policy "usb 'none'; camera 'none'; vibrate ‘none’;";

    if (\$request_method !~ ^(GET|HEAD|POST)$)
    {
        return 405;
    }


    location / {
        proxy_set_header X-Forwarded-For "$proxy_add_x_forwarded_for";
        proxy_set_header X-Real-IP "$remote_addr";
        proxy_set_header Host "$http_host";

        proxy_http_version 1.1;
        proxy_set_header Upgrade "$http_upgrade";
        proxy_set_header Connection "upgrade";

        proxy_pass http://unsub-server-$UP_SERVER_NAME/;
        proxy_redirect off;
        proxy_read_timeout 240s;
    }
}
EOF