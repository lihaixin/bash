#!/bin/bash
# 函数：安装 Docker
# 提供用户选择，并根据系统和国家安装 Docker
install_docker() {
    log_message INFO "Preparing to install Docker CE..."
    
    # 设置默认值和提示信息
    DEFAULT_VALUE="Y"
    prompt="Please enter (Y/N) to confirm if you want to install Docker CE now, the default value ($DEFAULT_VALUE) will be used if no input is provided within 20 seconds: "

    # 等待用户输入
    read -t 10 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
    : ${USER_INPUT:=$DEFAULT_VALUE}

    # 用户选择安装 Docker 并判断国家
    if [ "$USER_INPUT" = "Y" ] && [ "$COUNTRY" = "cn" ]; then
        log_message INFO "Now installing Docker CE using Aliyun mirror..."
        case $OS in
            debian | ubuntu | armbian )
                apt install docker.io -y
                ;;
            alpine )
                apk add docker docker-cli-compose
                ;;
            *)
                log_message WARNING "Unknown system type: $OS"
                ;;
        esac 

        log_message SUCCESS "Docker installed successfully. You can check the version using 'docker info'."
        mkdir -p /etc/docker 
        cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://docker.1panel.live", "https://docker.ketches.cn", "https://hub.15099.net"],
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "20m",
    "max-file": "3"
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
                log_message WARNING "Unknown system type: $OS"
                ;;
        esac
    
    # 用户选择安装 Docker，非中国地区
    elif [ "$USER_INPUT" = "Y" ] && [ "$COUNTRY" != "cn" ]; then
        log_message INFO "Now installing Docker CE..."
        case $OS in
            debian | ubuntu | armbian )
                apt install docker.io -y
                ;;
            alpine )
                apk add docker docker-cli-compose
                ;;
            *)
                log_message WARNING "Unknown system type: $OS"
                ;;
        esac 

        log_message SUCCESS "Docker installed successfully. You can check the version using 'docker info'."
        mkdir -p /etc/docker 
        cat <<EOF > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "live-restore": true,
  "log-opts": {
    "max-size": "20m",
    "max-file": "3"
  },
  "dns": [
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
                log_message WARNING "Unknown system type: $OS"
                ;;
        esac

    # 用户取消安装
    else
        log_message WARNING "Docker CE installation canceled."
    fi
}

# 主程序启动
install_docker
