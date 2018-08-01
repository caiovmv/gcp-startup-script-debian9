#!/bin/bash

function install {
    echo "[Unit]" >> /lib/systemd/system/keycloak.service
    echo "Description=Identity and Access Management" >> /lib/systemd/system/keycloak.service
    echo "After=network.target" >> /lib/systemd/system/keycloak.service
    echo "[Service]" >> /lib/systemd/system/keycloak.service
    echo "User=root" >> /lib/systemd/system/keycloak.service
    echo "ExecStart=/usr/bin/mongod --config /etc/mongod.conf" >> /lib/systemd/system/keycloak.service
    echo "[Install]" >> /lib/systemd/system/keycloak.service
    echo "WantedBy=multi-user.target" >> /lib/systemd/system/keycloak.service
    
    touch "${PWD}"/install.key
}

function update {
   echo "Updating Keycloak ..."
   rm -rf "${PWD}"/install.key

}
if [ ! -f "${PWD}"/install.key ]
then
    install
elif [ -f "${PWD}"/update.key ]
 then
    update
else
  echo "Nothing to install or update."
fi
