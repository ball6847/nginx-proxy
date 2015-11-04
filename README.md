# nginx-proxy

nginx-proxy is simple nginx container acting as proxy server to your running container (do not use in production)

## Usage:

```sh
docker run -d \
  --name nginx-proxy \
  -p 80:80 \
  -v $PWD/proxy.conf:/nginx-proxy/proxy.conf \
  ball6847/nginx-proxy
```

### Example of `proxy.conf`

```
example.com nginx:80
example2.com my-container:80
```

while `example.com` is domain name you want to use to access the proxy, and `nginx:80` is proxy backend in `HOSTNAME:PORT` format, you can use container name or ip address.

**Note:** You need to restart the container if you modify `proxy.conf` to make it take effect.

### VHOST Template

You can use you own vhost template using [Mustache Template Engine for Bash](https://github.com/tests-always-included/mo) Syntax,
just mount a volume at /nginx-proxy/vhost.tpl, please see [vhost.tpl](https://github.com/ball6847/nginx-proxy/blob/master/vhost.tpl) for original template.

```sh
docker run -d --name nginx-proxy \
  -p 80:80 \
  -v $PWD/proxy.conf:/nginx-proxy/proxy.conf \
  -v $PWD/vhost.rpl:/nginx-proxy/vhost.tpl \
  ball6847/nginx-proxy
```
