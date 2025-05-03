#!/bin/bash

# 函数：安装 Portainer 图形界面
install_portainer() {
    log_message INFO "Starting installation of VLAN network or custom bridge network..."
    log_message INFO "Choose the type of network you want to create:"
    echo "1) Physical LAN adapter (macvlan)"
    echo "2) Wireless LAN adapter (ipvlan)"
    echo "3) Cloudhost LAN network (bridge)"
    DEFAULT_VALUE="1"
    read_with_message "Enter your choice (1/2/3): " network_choice || network_choice=$DEFAULT_VALUE
    : ${network_choice:=$DEFAULT_VALUE}
    case $network_choice in
        1)
            log_message INFO "Creating macvlan network..."
            NETWORK_NAME=vlan
            : ${VNAME:=$(ip route | grep "default via" | awk '{print $5}')}
            # 检查网络是否已存在
            EXISTING_NETWORK=$(docker network ls --format "{{.Name}}" | grep -w "^$NETWORK_NAME$")
            if [ -z "$EXISTING_NETWORK" ]; then
                docker network create \
                  -d macvlan \
                  --subnet=172.19.0.0/24 \
                  --gateway=172.19.0.$(( (RANDOM % 53) + 201 )) \
                  -o macvlan_mode=bridge \
                  -o parent=$VNAME \
                  "$NETWORK_NAME" > /dev/null 2>&1
                log_message SUCCESS "macvlan network $NETWORK_NAME has been successfully created."
            else
                log_message WARNING "macvlan network $NETWORK_NAME already exists. Skipping creation."
            fi
            ;;
        2)
            log_message INFO "Creating ipvlan network..."
            NETWORK_NAME=vlan
            : ${VNAME:=$(ip route | grep "default via" | awk '{print $5}')}
            EXISTING_NETWORK=$(docker network ls --format "{{.Name}}" | grep -w "^$NETWORK_NAME$")
            if [ -z "$EXISTING_NETWORK" ]; then
                docker network create \
                  -d ipvlan \
                  --subnet=172.19.0.0/24 \
                  --gateway=172.19.0.$(( (RANDOM % 53) + 201 )) \
                  -o macvlan_mode=bridge \
                  -o parent=$VNAME \
                  "$NETWORK_NAME" > /dev/null 2>&1
                log_message SUCCESS "ipvlan network $NETWORK_NAME has been successfully created."
            else
                log_message WARNING "ipvlan network $NETWORK_NAME already exists. Skipping creation."
            fi
            ;;
        3)
            log_message INFO "Creating bridge network..."
            NETWORK_NAME=vlan
            EXISTING_NETWORK=$(docker network ls --format "{{.Name}}" | grep -w "^$NETWORK_NAME$")
            if [ -z "$EXISTING_NETWORK" ]; then
                docker network create -d bridge \
                  --subnet=172.19.0.0/24 \
                  --gateway=172.19.0.$(( (RANDOM % 53) + 201 )) \
                  "$NETWORK_NAME" > /dev/null 2>&1
                log_message SUCCESS "Bridge network $NETWORK_NAME has been successfully created."
            else
                log_message WARNING "Bridge network $NETWORK_NAME already exists. Skipping creation."
            fi
            ;;
        *)
            log_message ERROR "Invalid choice. Exiting script."
            exit 1
            ;;
    esac

    log_message INFO "Starting installation of toolbox container..."
    docker stop toolbox > /dev/null 2>&1
    docker rm toolbox > /dev/null 2>&1
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

    log_message INFO "Starting installation of Portainer graphical interface..."
    DEFAULT_PASSWD="@china1234567"
    prompt="Please enter admin password (press Enter to use default password $DEFAULT_PASSWD): "
    USER_PASSWD=""
    while true; do
        read -t 40 -p "$prompt" USER_PASSWD
        if [ -z "$USER_PASSWD" ]; then
            USER_PASSWD=$DEFAULT_PASSWD
            log_message INFO "Using default password: $DEFAULT_PASSWD for installation."
            break
        elif [ ${#USER_PASSWD} -ge 12 ]; then
            log_message INFO "Using password: $USER_PASSWD for installation."
            break
        else
            log_message WARNING "Password is less than 12 characters. Please re-enter."
        fi
    done

    DEFAULT_TEMPLATES="https://dockerfile.15099.net/index.json"
    prompt="Please enter your custom template URL. If no input within 60 seconds, the default value ($DEFAULT_TEMPLATES) will be used: "
    read_with_message "$prompt" USER_TEMPLATES || USER_TEMPLATES=$DEFAULT_TEMPLATES
    : ${USER_TEMPLATES:=$DEFAULT_TEMPLATES}
    log_message INFO "Using template URL: $USER_TEMPLATES for installation."

    # 检查 Docker 版本
    DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+')
    VERSION_CHECK=$(echo -e "$DOCKER_VERSION\n26.0.0" | sort -V | head -n 1)

    if [ "$VERSION_CHECK" = "26.0.0" ]; then
        IMAGE="lihaixin/ui:ce-2.21.5"
    else
        IMAGE="lihaixin/ui:ce-2.19.5"
    fi

    docker stop ui > /dev/null 2>&1
    docker rm ui > /dev/null 2>&1
    docker pull $IMAGE
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

    log_message SUCCESS "Portainer has been successfully installed. Visit: https://${WANIP}:9443 Username: admin Password: ${USER_PASSWD}"
}

# 函数：安装 Portainer Agent
install_portainer_agent() {
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
    log_message SUCCESS "Portainer agent has been successfully installed. Visit: ADD https://${WANIP}:9001 from Portainer UI."
}

# 主程序
log_message INFO "Preparing to install Portainer graphical interface..."
DEFAULT_VALUE="N"
prompt="Enter content (Y/N). Default value will be used if no input within 60 seconds ($DEFAULT_VALUE): "
read_with_message "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}
if [ "$USER_INPUT" = "Y" ]; then
    install_portainer
fi

log_message INFO "Preparing to install Portainer Agent..."
DEFAULT_VALUE="N"
prompt="Enter content (Y/N). Default value will be used if no input within 60 seconds ($DEFAULT_VALUE): "
read_with_message "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}
if [ "$USER_INPUT" = "Y" ]; then
    install_portainer_agent
fi
