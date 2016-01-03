#!/bin/sh

start_listener() {
  docker events --filter 'event=start' | while read event
  do
    /generate.sh
  done
}

# run generate script
/generate.sh

start_listener&

# start nginx service
nginx -g "daemon off;"
