#!/bin/bash
# proxmox7 上lxc上安装docker web管理界面 portainer
# curl -sSL https://15099.net/proxmox.portainer | bash -x
# wget -qO - https://15099.net/proxmox.portainer | bash -x

## 创建存储数据卷
docker volume create portainer_data

## 创建容器

docker stop portainer2 && docker rm portainer2

docker run -d -p 8000:8000 -p 9443:9443 -p 9000:9000 --name portainer2 \
    --restart=always \
    --label owner=portainer \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:2.13.0-alpine \
    -l owner=portainer \
    --templates https://git.io/portainer \
    --logo https://git.io/docker.logo

2.14.0-alpine
## 添加自动更新
docker run -d \
    --name watchtower \
    --restart always \
    -e TZ=Asia/Shanghai \
    --label owner=portainer \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --cleanup \
    -s "0 0 1 * * *" \
    portainer
