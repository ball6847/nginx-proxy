#!/bin/bash

# run generate script
. /generate.sh

# start nginx service
nginx -g "daemon off;"
