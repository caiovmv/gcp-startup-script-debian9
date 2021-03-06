#!/bin/bash
echo deb http://httpredir.debian.org/debian stretch-backports main | tee /etc/apt/sources.list.d/backports.list
curl https://haproxy.debian.net/bernat.debian.org.gpg | apt-key add -
echo deb http://haproxy.debian.net stretch-backports-1.8 main | tee /etc/apt/sources.list.d/haproxy.list
apt-get update
apt-get install -y haproxy=1.8.\* -t stretch-backports
