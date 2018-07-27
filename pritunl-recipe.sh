#!/bin/bash
gcloud components install beta --quiet
SERVER_NAME="pritunl-1"
gcloud compute instances create "$SERVER_NAME" \
--machine-type "g1-small" \
--image-family debian-9 \
--image-project "debian-cloud" \
--boot-disk-size "20" \
--boot-disk-type "pd-ssd" \
--boot-disk-device-name "$SERVER_NAME" \
--no-boot-disk-auto-delete \
--tags https-server,http-server,pritunl \
--zone us-central1-a \
--can-ip-forward \
--deletion-protection \
--maintenance-policy=MIGRATE \
--restart-on-failure \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--metadata=dns=gr1d.io,app=pritunl,criticality=low,workload=networking,type=single,purpouse=VPN,docker=no,startup-script='#!/bin/bash
    sudo su -
    cd /root||exit 1
    curl -o- https://raw.githubusercontent.com/caiovmv/gcp-startup-script-debian9/master/script.sh | bash
    curl -o- https://raw.githubusercontent.com/caiovmv/gcp-startup-script-debian9/master/install-pritunl.sh | bash
'

IP=$(gcloud compute instances describe $SERVER_NAME --zone us-central1-a | grep natIP | cut -d: -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
gcloud beta compute firewall-rules create vpn-allow-8787-$SERVER_NAME --allow tcp:8787 --network default --priority 65535 --source-ranges $IP/32
gcloud beta compute firewall-rules create vpn-allow-3838-$SERVER_NAME --allow tcp:3838 --network default --priority 65535 --source-ranges $IP/32
echo "VPN server will be available for setup at https://$IP in a few minutes."
