#!/bin/bash
echo "Preparing to install Portainer graphical interface..."

#######################################################install_portainer########################################################################################
install_portainer() {
echo "Starting installation of macvlan and custom bridge network"

NETWORK_NAME=vlan                                                  # Define network name
: ${VNAME:=$(ip route | grep "default via" |awk '{ print $5}')}    # MAC VLAN parent device name
# Check if the network already exists
EXISTING_NETWORK=$(docker network ls --format "{{.Name}}" | grep -w "^$NETWORK_NAME$")

if [ -z "$EXISTING_NETWORK" ]; then
    # If the network does not exist, create it
    docker network create \
      -d macvlan \
      --subnet=172.19.0.0/24 \
      --gateway=172.19.0.$(( (RANDOM % 53) + 201 )) \
      -o macvlan_mode=bridge \
      -o parent=$VNAME \
      "$NETWORK_NAME" > /dev/null 2>&1
      echo "Network $NETWORK_NAME has been successfully created."
else
    echo "Network $NETWORK_NAME already exists, skipping creation."
fi

NETWORK_NAME=cbridge                                                 # Define network name
# Check if the network already exists
EXISTING_NETWORK=$(docker network ls --format "{{.Name}}" | grep -w "^$NETWORK_NAME$")
if [ -z "$EXISTING_NETWORK" ]; then
    # If the network does not exist, create it
    docker network create -d bridge \
    --subnet=172.20.0.0/24 \
    --gateway=172.20.0.$(( (RANDOM % 53) + 201 )) \
    cbridge 1> /dev/null 2>&1
    echo "Network $NETWORK_NAME has been successfully created."
else
    echo "Network $NETWORK_NAME already exists, skipping creation."
fi

echo "Starting installation of toolbox container"
docker stop toolbox 1> /dev/null 2>&1
docker rm toolbox 1> /dev/null 2>&1
docker pull lihaixin/toolbox
docker run -id \
--restart=always \
--privileged \
--network=host \
--pid=host \
--name toolbox \
-v /root/.ssh/id_rsa:/root/.ssh/id_rsa \
-v /var/run/docker.sock:/var/run/docker.sock \
lihaixin/toolbox

echo ""
echo "Starting installation of Portainer graphical interface"
DEFAULT_PASSWD="@china1234567"
prompt="Please enter admin password (press Enter to use default password $DEFAULT_PASSWD): "
USER_PASSWD=""
while true; do
    read -t 40 -p "$prompt" USER_PASSWD
    if [ -z "$USER_PASSWD" ]; then
        USER_PASSWD=$DEFAULT_PASSWD
        echo "Using default password: $DEFAULT_PASSWD for installation."
        break
    elif [ ${#USER_PASSWD} -ge 12 ]; then
        echo "Using password: $USER_PASSWD for installation."
        break
    else
        echo "Password is less than 12 characters, please re-enter."
    fi
done

DEFAULT_TEMPLATES="https://dockerfile.15099.net/index.json"
prompt="Please enter your custom template URL, if no input within 60 seconds, the default value ($DEFAULT_TEMPLATES) will be used: "
read -t 120 -p "$prompt" USER_TEMPLATES || USER_TEMPLATES=$DEFAULT_TEMPLATES
: ${USER_TEMPLATES:=$DEFAULT_TEMPLATES}
echo "Using template URL: $USER_TEMPLATES for installation."

docker stop ui 1> /dev/null 2>&1
docker rm ui 1> /dev/null 2>&1
docker pull lihaixin/ui:ce-2.19.5
docker run -d \
-p 9443:9443 \
-p 8000:8000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /var/portainer_data:/data \
-e TPORT=8000 \
-e COUNTRY=cn \
-e PASSWORD=${USER_PASSWD} \
-e TEMPLATES=${USER_TEMPLATES} \
-e NO=9999210012301280103 \
--name ui \
--restart=always \
lihaixin/ui:ce-2.19.5
echo "Portainer has been successfully installed, visit: https://${WANIP}:9443 Username: admin Password: ${USER_PASSWD}"
}
install_portainer
