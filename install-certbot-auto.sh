#!/bin/bash
mkdir /opt/certbot
cd /opt/certbot
wget https://dl.eff.org/certbot-auto 
chmod a+x ./certbot-auto
./certbot-auto --version
