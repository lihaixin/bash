#!/bin/bash
# curl -sSL https://15099.net/proxmox.docker | bash -x
# wget -qO - https://15099.net/proxmox.docker | bash -x
# wget -qO - https://15099.net/cn/proxmox.docker | bash -x

## 换成国内源
cat >/etc/apt/sources.list << TEMPEOF
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib
TEMPEOF

## 升级系统到最新版
apt update -y && apt upgrade -y 
apt-get -y install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg \
     lsb-release

## 安装docker-ce最新社区版
curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  
apt-get update && apt-get install -y docker-ce

## 下载docker两个超实用的工具

wget -O /usr/local/bin/ctop https://ghproxy.com/https://github.com/bcicen/ctop/releases/download/0.7.6/ctop-0.7.6-linux-amd64 
chmod +x /usr/local/bin/ctop

wget -O /usr/local/bin/docker-compose "https://ghproxy.com/https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" 
chmod +x /usr/local/bin/docker-compose

## 开启使用第三方加速
mkdir -p /etc/docker 
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://hub.15099.net"],
  "log-driver": "json-file", 
  "log-opts": { 
  "max-size": "20m", "max-file": "3" 
  }
}
EOF

## 下载远程访问证书
cd /root && mkdir .docker
cd .docker
wget https://ghproxy.com/https://raw.githubusercontent.com/lihaixin/portainer/master/ca.pem
sleep 1
wget https://ghproxy.com/https://raw.githubusercontent.com/lihaixin/portainer/master/server.pem
sleep 1
wget https://ghproxy.com/https://raw.githubusercontent.com/lihaixin/portainer/master/server-key.pem
sleep 1
cd

## 调整docker tls端口监听
sed -i s'/containerd.sock/containerd.sock -H 0.0.0.0:2376 --tls --tlsverify --tlscacert=\/root\/.docker\/ca.pem --tlscert=\/root\/.docker\/server.pem --tlskey=\/root\/.docker\/server-key.pem/g' /lib/systemd/system/docker.service


##重启docker
systemctl daemon-reload
systemctl restart docker

