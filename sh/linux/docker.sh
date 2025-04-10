#!/bin/bash
echo "Preparing to initialize Docker..."

#######################################################install_docker########################################################################################
install_docker() {
echo "Preparing to install Docker CE"
# debian10/11 ver: 20.10 docker.io
# armbian 24.5 ver: 20.10 docker.io
# alpine 3.16 ver: 20.10.20 docker
DEFAULT_VALUE="Y"
prompt="Please enter (Y/N) to confirm if you want to install Docker CE now, the default value ($DEFAULT_VALUE) will be used if no input is provided within 20 seconds: "
# Use the -t option of read and command substitution
read -t 10 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}

if [ "$USER_INPUT" = "Y" ] && [ "$COUNTRY" = "cn" ]; then
    echo "Now installing Docker CE using Aliyun mirror"
    # curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun --version 24.0.9
    # curl -fsSL https://bash.15099.net/linux/online_install_docker.sh | bash -s docker --mirror Aliyun --version 24.0.9
    # curl -fsSL https://bash.15099.net/linux/online_install_docker.sh > /tmp/online_install_docker.sh
    # bash /tmp/online_install_docker.sh --mirror Aliyun --version 26.0.0
    # rm -rf /tmp/online_install_docker.sh
    case $OS in
        debian | ubuntu | armbian )
                apt install docker.io -y
                ;;
        alpine )
                apk add docker docker-cli-compose
                ;;
        *)
                echo "Unknown system type: $OS"
                ;;
    esac 
    echo "Docker installed successfully, you can check the version using docker info"
    mkdir -p /etc/docker 
cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://docker.1panel.live","https://docker.ketches.cn","https://hub.15099.net"],
  "live-restore":true,
  "log-driver": "json-file", 
  "log-opts": { 
  "max-size": "20m", "max-file": "3" 
  }
}
EOF

mkdir -p /etc/systemd/system/docker.service.d/
cat <<EOF > /etc/systemd/system/docker.service.d/clear_mount_propagation_flags.conf
[Service]
MountFlags=shared
EOF
    case $OS in
        debian | ubuntu | armbian )
                systemctl daemon-reload
                systemctl restart docker
                ;;
        alpine )
                rc-update add docker
                service docker start
                ;;
        *)
                echo "Unknown system type: $OS"
                ;;
    esac   
    
elif [ "$USER_INPUT" = "Y" ] && [ "$COUNTRY" != "cn" ]; then
    echo "Now installing Docker CE"
    # curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun --version 24.0.9
    # curl -fsSL https://bash.15099.net/linux/online_install_docker.sh | bash -s docker --mirror Aliyun --version 24.0.9
    # curl -fsSL https://bash.15099.net/linux/online_install_docker.sh > /tmp/online_install_docker.sh
    # bash /tmp/online_install_docker.sh --mirror Aliyun --version 26.0.0
    # rm -rf /tmp/online_install_docker.sh
    case $OS in
        debian | ubuntu | armbian )
                apt install docker.io -y
                ;;
        alpine )
                apk add docker docker-cli-compose
                ;;
        *)
                echo "Unknown system type: $OS"
                ;;
    esac 
    
    echo "Docker installed successfully, you can check the version using docker info"
    mkdir -p /etc/docker 
cat <<EOF > /etc/docker/daemon.json
{
      "log-driver": "json-file",
      "live-restore":true,
      "log-opts": { 
      "max-size": "20m", "max-file": "3" 
      },
      "dns" : [
        "8.8.8.8"
      ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d/
cat <<EOF > /etc/systemd/system/docker.service.d/clear_mount_propagation_flags.conf
[Service]
MountFlags=shared
EOF
    case $OS in
        debian | ubuntu | armbian )
                systemctl daemon-reload
                systemctl restart docker
                ;;
        alpine )
                rc-update add docker
                service docker start
                ;;
        *)
                echo "Unknown system type: $OS"
                ;;
    esac        
else
    echo "Docker CE installation canceled"
fi
}
install_docker
