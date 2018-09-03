#!/bin/bash

cd /home/fsx/docker
for each in $(ls | grep yml| grep -vE "etcd|pure"); do docker-compose -f $each up -d ;done
