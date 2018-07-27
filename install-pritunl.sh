#!/bin/bash

function install {
    echo "[Unit]" >> /lib/systemd/system/mongod.service
    echo "Description=database" >> /lib/systemd/system/mongod.service
    echo "After=network.target" >> /lib/systemd/system/mongod.service
    echo "[Service]" >> /lib/systemd/system/mongod.service
    echo "User=mongodb" >> /lib/systemd/system/mongod.service
    echo "ExecStart=/usr/bin/mongod --config /etc/mongod.conf" >> /lib/systemd/system/mongod.service
    echo "[Install]" >> /lib/systemd/system/mongod.service
    echo "WantedBy=multi-user.target" >> /lib/systemd/system/mongod.service
    echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" > /etc/apt/sources.list.d/mongodb-org-4.0.list
    echo "deb http://repo.pritunl.com/stable/apt stretch main" > /etc/apt/sources.list.d/pritunl.list
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
    apt-get update -y
    apt-get install pritunl mongodb-org -y --allow-unauthenticated
    systemctl start pritunl mongod
    systemctl enable pritunl mongod
    # Collect setup key
    echo "###SETUP KEY###"
    pritunl setup-key
    echo "###############"
}
if [ ! -f "${PWD}"/install.key ]
then
    install
    touch "${PWD}"/install.key
else
    echo "install script already been executed"
fi
