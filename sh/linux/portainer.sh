#!/bin/bash

#######################################################install_portainer########################################################################################
install_portainer() {
echo "Starting installation of macvlan and custom bridge network"
echo "Choose the type of network you want to create:"
echo "1) Physical LAN adapter (macvlan)"
echo "2) Wireless LAN adapter (ipvlan)"
echo "3) Custom bridge network(bridge)"
read -p "Enter your choice (1/2/3): " network_choice

case $network_choice in
  1)
    echo "Creating macvlan network..."
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
        echo "Creating macvlan Network $NETWORK_NAME has been successfully created."
    else
        echo "Creating macvlan Network $NETWORK_NAME already exists, skipping creation."
    fi
    ;;
  2)
    echo "Creating ipvlan network..."
    NETWORK_NAME=vlan                                                  # Define network name
    : ${VNAME:=$(ip route | grep "default via" |awk '{ print $5}')}    # MAC VLAN parent device name
    # Check if the network already exists
    EXISTING_NETWORK=$(docker network ls --format "{{.Name}}" | grep -w "^$NETWORK_NAME$")
    
    if [ -z "$EXISTING_NETWORK" ]; then
        # If the network does not exist, create it
        docker network create \
          -d ipvlan \
          --subnet=172.19.0.0/24 \
          --gateway=172.19.0.$(( (RANDOM % 53) + 201 )) \
          -o macvlan_mode=bridge \
          -o parent=$VNAME \
          "$NETWORK_NAME" > /dev/null 2>&1
        echo "Creating ipvlan Network $NETWORK_NAME has been successfully created."
    else
        echo "Creating ipvlan Network $NETWORK_NAME already exists, skipping creation."
    fi
    ;;
  3)
    echo "Creating custom bridge network..."
    NETWORK_NAME=vlan                                                # Define network name
    # Check if the network already exists
    EXISTING_NETWORK=$(docker network ls --format "{{.Name}}" | grep -w "^$NETWORK_NAME$")
    if [ -z "$EXISTING_NETWORK" ]; then
        # If the network does not exist, create it
        docker network create -d bridge \
        --subnet=172.19.0.0/24 \
        --gateway=172.19.0.$(( (RANDOM % 53) + 201 )) \
        "$NETWORK_NAME" 1> /dev/null 2>&1
        echo "Custom Network bridge $NETWORK_NAME has been successfully created."
    else
        echo "Network $NETWORK_NAME already exists, skipping creation."
    fi
    ;;
  *)
    echo "Invalid choice. Exiting script."
    exit 1
    ;;
esac

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

# 检查 Docker 版本
DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+')
VERSION_CHECK=$(echo -e "$DOCKER_VERSION\n26.0.0" | sort -V | head -n 1)

if [ "$VERSION_CHECK" = "26.0.0" ]; then
    IMAGE="lihaixin/ui:ce-2.21.5"
else
    IMAGE="lihaixin/ui:ce-2.19.5"
fi
    
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
$IMAGE
echo "Portainer has been successfully installed, visit: https://${WANIP}:9443 Username: admin Password: ${USER_PASSWD}"
}

install_portainer_agent(){
# 检查 Docker 版本
DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+')
VERSION_CHECK=$(echo -e "$DOCKER_VERSION\n26.0.0" | sort -V | head -n 1)

if [ "$VERSION_CHECK" = "26.0.0" ]; then
    IMAGE="portainer/agent:2.21.5"
else
    IMAGE="portainer/agent:2.19.5"
fi

docker run -d \
  -p 9001:9001 \
  --name portainer_agent \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  -v /:/host \
  $IMAGE
echo "Portainer agent has been successfully installed, visit: ADD https://${WANIP}:9001 from portainer UI "
}

echo "Preparing to install Portainer graphical interface..."
DEFAULT_VALUE="N"
prompt="Enter content (Y/N), default value will be used if no input within 10 seconds ( $DEFAULT_VALUE ): "
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}
if [ "$USER_INPUT" = "Y" ]; then
install_portainer
fi

echo "Preparing to install Portainer Agent..."
DEFAULT_VALUE="N"
prompt="Enter content (Y/N), default value will be used if no input within 10 seconds ( $DEFAULT_VALUE ): "
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}
if [ "$USER_INPUT" = "Y" ]; then
install_portainer_agent
fi
