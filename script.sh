#!/bin/bash

# Verifies how much swap memory needs to be allocated
if [ $(free -m| grep  Mem | awk '{ print int($2) }') -lt "1024" ]
 then
  SWAP=2G
  SWAPPINESS=60
elif [ $(free -m| grep  Mem | awk '{ print int($2) }') -gt "1024" ] && [ $(free -m| grep  Mem | awk '{ print int($2) }') -lt "2048" ]
 then
  SWAP=4G
  SWAPPINESS=40
else
  SWAP=8G
  SWAPPINESS=10
fi

# Especify docker-compose version to install on firstboot
COMPOSE_VERSION=1.22.0-rc1

# Changing to root to proceed
cd /root||exit 1

function firstboot {
    # Update, Upgrade & Dist Upgrade
    apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y

    # Install Basic Tools
    apt-get install -y software-properties-common apt-transport-https ca-certificates ca-certificates curl gnupg2 nmon htop sysstat iptraf-ng wget telnet ftp git lsof iotop vim

    # Install Docker Compose (Always verify the latest release)
    curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Install Docker Comunity Edition
    apt-get remove docker docker-engine docker.io
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get update && apt-get install -y docker-ce 

    # Install gitlab-runner
    curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
    gpasswd -a gitlab-runner dockerab-runner/script.deb.sh | bash
    apt-get install -y gitlab-runner

    # Make docker availabe to run with gitlab-runner account
    gpasswd -a gitlab-runner docker
    printf '%s\n' '#!/bin/sh -e' \
    'chmod 777 /var/run/docker.sock' \
    'exit 0' > /etc/rc.local
    chmod +x /etc/rc.local
    systemctl daemon-reload
    systemctl enable rc-local
    systemctl start rc-local
    systemctl status rc-local
    
    # Make gitlab-runner account to run root commands without sudo
    echo "gitlab-runner ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

    # Create & Enable Swapfile
    fallocate -l ${SWAP} /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    echo 'vm.swappiness='${SWAPPINESS}'' | tee -a /etc/sysctl.conf
    echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf
    sysctl -p
}

function osupdate {
    # Update & Upgrade & Dist Upgrade
    apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y

    # Update Docker Compose (Always verify the latest release)
    COMPOSE_VERSION=`cat ${PWD}/osupdate.key|grep DOCKER_COMPOSE|awk -F"=" '{ print $ 2}'`
    curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose  
}

if [ ! -f "${PWD}"/firstboot.key ]
 then
    touch "${PWD}"/firstboot.key
    firstboot
else
    echo "firstboot script already been executed" 
fi

if [ ! -f "${PWD}"/osupdate.key ]
 then
    exit 0
else
    echo "update main components"
    osupdate
    exit 0
fi

