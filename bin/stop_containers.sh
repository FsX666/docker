#!/bin/bash

cd /home/fsx/docker
for each in $(ls | grep yml| grep -vE "etcd|pure|rtorrent"); do docker-compose -f $each rm -sf ;done