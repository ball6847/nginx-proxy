server {
    listen 80;
    server_name {{HOST}};

    location / {
        proxy_pass http://{{PROXY}};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
    }
}
