#!/bin/bash
# proxmox7 上lxc上安装docker web管理界面 portainer
# curl -sSL https://15099.net/proxmox.portainer | bash -x
# wget -qO - https://tinyurl.com/proxmox.portainer | bash -x

## 创建存储数据卷
docker volume create portainer_data

## 创建容器

docker run -d -p 8000:8000 -p 9443:9443 -p 9000:9000 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce \
    -l owner=portainer \
    --templates https://raw.githubusercontent.com/lihaixin/dockerfile/master/templates-2.0.json \
    --logo https://raw.githubusercontent.com/lihaixin/portainer/master/docker.png


## 添加自动更新
docker run -d \
    --name watchtower \
    --restart always \
    -e TZ=Asia/Shanghai \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --cleanup \
    -s "0 0 1 * * *" \
    portainer
