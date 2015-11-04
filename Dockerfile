FROM quay.io/loicmahieu/alpine-nginx

MAINTAINER Porawit Poboonma <ball6847@gmail.com>

RUN apk --update add bash && \
    wget -O /usr/local/bin/mo --no-check-certificate "https://raw.githubusercontent.com/tests-always-included/mo/master/mo" && \
    chmod +x /usr/local/bin/mo && \
    mkdir -p /nginx-proxy

COPY . /nginx-proxy/
COPY nginx.conf /etc/nginx/conf/nginx.conf

WORKDIR /etc/nginx

EXPOSE 80 433

CMD ["bash", "-c", "/nginx-proxy/entrypoint.sh"]
