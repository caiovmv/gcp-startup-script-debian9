#!/bin/bash
gcloud components install beta --quiet
SERVER_NAME="keycloak-1"
gcloud compute instances create "$SERVER_NAME" \
--machine-type "g1-small" \
--image-family debian-9 \
--image-project "debian-cloud" \
--boot-disk-size "20" \
--boot-disk-type "pd-ssd" \
--boot-disk-device-name "$SERVER_NAME" \
--no-boot-disk-auto-delete \
--tags https-server,http-server \
--zone us-central1-a \
--deletion-protection \
--maintenance-policy=MIGRATE \
--restart-on-failure \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--metadata=dns=dev.pipeleap.com,app=keycloak,criticality=high,workload=network,type=single,purpouse=IdentityService,docker=yes,startup-script='#!/bin/bash
    sudo su -
    cd /root||exit 1
    curl -o- https://raw.githubusercontent.com/caiovmv/gcp-startup-script-debian9/master/script.sh | bash
    curl -o- https://raw.githubusercontent.com/caiovmv/gcp-startup-script-debian9/master/setup-keycloak.sh | bash'
