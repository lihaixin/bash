#!/bin/bash
# curl -sSL https://tinyurl.com/proxmoxdocker | bash -x

## 换成国内源
cat >/etc/apt/sources.list << TEMPEOF
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib
TEMPEOF

## 升级系统到最新版
apt update -y && apt upgrade -y && apt install -y curl 

## 安装docker-ce最新社区版
curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian \
   $(lsb_release -cs) \
   stable"

apt-get update && apt-get install -y docker-ce

## 下载docker两个超实用的工具

wget -O /usr/local/bin/ctop https://ghproxy.com/https://github.com/bcicen/ctop/releases/download/0.7.6/ctop-0.7.6-linux-amd64 
chmod +x /usr/local/bin/ctop

wget -O /usr/local/bin/docker-compose "https://ghproxy.com/https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-$(uname -s)-$(uname -m)" 
chmod +x /usr/local/bin/docker-compose

## 开启使用第三方加速
mkdir -p /etc/docker 
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://hub.testsanjin.xyz"]
}
EOF

## 下载远程访问证书
cd /root && mkdir .docker
cd .docker
wget https://ghproxy.com/https://raw.githubusercontent.com/lihaixin/portainer/master/ca.pem
wget https://ghproxy.com/https://raw.githubusercontent.com/lihaixin/portainer/master/server.pem
wget https://ghproxy.com/https://raw.githubusercontent.com/lihaixin/portainer/master/server-key.pem
cd

## 调整docker tls端口监听
sed -i s'/containerd.sock/containerd.sock -H 0.0.0.0:2376 --tls --tlsverify --tlscacert=\/root\/.docker\/ca.pem --tlscert=\/root\/.docker\/server.pem --tlskey=\/root\/.docker\/server-key.pem/g' /lib/systemd/system/docker.service

##重启docker
systemctl daemon-reload
systemctl restart docker


