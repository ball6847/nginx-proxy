#!/bin/bash

PROXY_FILE="/nginx-proxy.conf"

# ---------------------------------------------------

function valid_ip()
{
  local  ip=$1
  local  stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

# ---------------------------------------------------

# remove proxy file if already exists
if [[ -f $PROXY_FILE ]]; then
  rm $PROXY_FILE
fi

# read proxy configuration then generate nginx vhost file using
INDEX=0
while read entry
do
  IFS=" " read DOMAIN PROXY  <<< $entry
  IFS=":" read PROXY_HOST PROXY_PORT <<< $PROXY

  # check proxy hostname, if it is a container name we need to resolve it to ip address
  if ! valid_ip $PROXY_HOST ; then
    PROXY_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $PROXY_HOST)
  fi

  # use proxy_host if proxy_ip cannot be resolved
  if [[ "$PROXY_IP" == "" ]]; then
    PROXY_IP=$PROXY_HOST
  fi

  # default proxy port is 80
  if [[ "$PROXY_PORT" == "" ]]; then
    PROXY_PORT="80"
  fi

  INDEX=$INDEX \
  DOMAIN=$DOMAIN \
  PROXY=$PROXY \
  PROXY_IP=$PROXY_IP \
  PROXY_HOST=$PROXY_HOST \
  PROXY_PORT=$PROXY_PORT \
    mo /vhost.tpl >> $PROXY_FILE

  INDEX=$((INDEX+1))
done < /proxy.conf

# debug our result
#cat $PROXY_FILE

# reload nginx if neccessary
if [[ `ps aux | grep -q nginx` ]]; then
  nginx -s reload
fi
