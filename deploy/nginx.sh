#!/bin/bash

# This is where the application should probably
# decide how to set itself up when passed a 
# working directory. For now we'll write it here
depdir=${PWD}/data/$(date +%s)-nginx
mkdir -p $depdir
cp -R nginx/ $depdir/
sudo nginx -t -c $depdir/nginx.conf
sudo nginx -c $depdir/nginx.conf -s reload 
echo "Relaoded nginx configuration"