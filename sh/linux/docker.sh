#!/bin/bash
echo "准备初始化docker..."

#######################################################install_docker########################################################################################
install_docker() {
echo "准备安装doceker-ce"
# debian10/11 ver: 20.10 docker.io
# armbian 24.5 ver: 20.10 docker.io
DEFAULT_VALUE="Y"
prompt="请输入内容(Y/N)确定是否现在安装docker-ce，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 10 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}

if [ "$USER_INPUT" = "Y" ] &&[ "$COUNTRY" = "cn" ]; then
    echo "现在安装docker-ce 使用Aliyun镜像"
    # curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun --version 24.0.9
    # curl -fsSL https://bash.15099.net/linux/online_install_docker.sh | bash -s docker --mirror Aliyun --version 24.0.9
    # curl -fsSL https://bash.15099.net/linux/online_install_docker.sh > /tmp/online_install_docker.sh
    # bash /tmp/online_install_docker.sh --mirror Aliyun --version 26.0.0
    # rm -rf /tmp/online_install_docker.sh
    apt install docker.io -y
    echo "成功安装docker-ce,可使用docker info查看版本信息"
    mkdir -p /etc/docker 
cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://docker.1panel.live","https://docker.ketches.cn","https://hub.15099.net"],
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
    systemctl daemon-reload
    systemctl restart docker
else
    echo "现在安装docker-ce"
    # curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun --version 24.0.9
    # curl -fsSL https://bash.15099.net/linux/online_install_docker.sh | bash -s docker --mirror Aliyun --version 24.0.9
    # curl -fsSL https://bash.15099.net/linux/online_install_docker.sh > /tmp/online_install_docker.sh
    # bash /tmp/online_install_docker.sh --mirror Aliyun --version 26.0.0
    # rm -rf /tmp/online_install_docker.sh
    apt install docker.io -y
    echo "成功安装docker-ce,可使用docker info查看版本信息"
    mkdir -p /etc/docker 
cat <<EOF > /etc/docker/daemon.json
{
      "log-driver": "json-file", 
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
    systemctl daemon-reload
    systemctl restart docker
fi
}
install_docker
