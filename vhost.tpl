upstream docker{{INDEX}} {
  server {{PROXY_IP}}:{{PROXY_PORT}};
}
server {
  listen 80;
  server_name {{DOMAIN}};

  location / {
    proxy_pass http://docker{{INDEX}};
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Connection "";
    proxy_http_version 1.1;
    proxy_buffers 4 256k;
    proxy_buffer_size 128k;
    proxy_busy_buffers_size 256k;
  }
}
# END docker{{INDEX}}
