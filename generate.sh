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
  echo "[DEBUG] $PROXY_FILE found, try to remove and regenerate it."
  rm $PROXY_FILE
fi

# read proxy configuration then generate nginx vhost file using
INDEX=0
while read entry
do
  IFS=" " read DOMAIN PROXY  <<< $entry
  IFS=":" read PROXY_HOST PROXY_PORT <<< $PROXY

  echo "[DEBUG] processing $DOMAIN."

  # check proxy hostname, if it is a container name we need to resolve it to ip address
  if ! valid_ip $PROXY_HOST ; then
    PROXY_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $PROXY_HOST)

    # use proxy_host if proxy_ip cannot be resolved
    if [[ "$PROXY_IP" == "" ]]; then
      echo "[DEBUG] cannot resolve container name to ip address, the entry will be skipped."
      continue
    fi
  else
    PROXY_IP=$PROXY_HOST
  fi

  # default proxy port is 80
  if [[ "$PROXY_PORT" == "" ]]; then
    echo "[DEBUG] no \$PROXY_PORT has been set, :80 will be used by default."
    PROXY_PORT="80"
  fi

  INDEX=$INDEX \
  DOMAIN=$DOMAIN \
  PROXY=$PROXY \
  PROXY_IP=$PROXY_IP \
  PROXY_HOST=$PROXY_HOST \
  PROXY_PORT=$PROXY_PORT \
    mo /vhost.tpl >> $PROXY_FILE

  echo "[DEBUG] added vhost rules for $DOMAIN."

  INDEX=$((INDEX+1))
done < /proxy.conf

# final check if /nginx-proxy.conf has not been created, we need to create an empty one
if [[ ! -f $PROXY_FILE ]]; then
  echo "[DEBUG] $PROXY_FILE not created, will create an empty one."
  touch $PROXY_FILE
fi

# debug our result
echo "[DEBUG] $PROXY_FILE result -------------------------------"
cat $PROXY_FILE

# reload nginx if neccessary
if [[ `ps aux | grep -q nginx` ]]; then
  echo "[DEBUG] nginx is running, try to reload its service."
  nginx -s reload
fi

echo "[DEBUG] completed!"
