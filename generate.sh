#!/bin/bash

PROXY_FILE="/nginx-proxy.conf"

# remove proxy file if already exists
if [[ -f $PROXY_FILE ]]; then
  rm $PROXY_FILE
fi

# read proxy configuration then generate nginx vhost file using
while read entry
do
  entry=(${entry//;/ })
  HOST=${entry[0]} PROXY=${entry[1]} mo /vhost.tpl >> $PROXY_FILE
done < /proxy.conf

# debug our result
#cat $PROXY_FILE

# reload nginx if neccessary
if [[ `ps aux | grep -q nginx` ]]; then
  nginx -s reload
fi
