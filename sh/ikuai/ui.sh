#!/bin/bash
# 赋值ui类型 253 为ui 252 为ui agent  251 为ui edge agent, 其他值，例如0 不运行docker run，这样打包程序小
docker_val=251
ADMIN_PASS=@china1234567
UI_NO=0000210012301280114

# 如需修改 edge 相关参数，直接改下面这两个变量即可
EDGE_ID="ad78bdf1-7df4-43c6-baf8-f55eb9085b4f"
EDGE_KEY="aHR0cHM6Ly91aS4xNTA5OS5uZXQ6OTQ0M3x1aS4xNTA5OS5uZXQ6ODAwMnw0TmhQM3dpbDhDSG5BS2M5ejIvQ1J3RkJISVhhdS80ZWZ4aW1Xc1pYQTV3PXw1NTA"

# 检查名为 vlan 的网络是否已存在
if ! docker network ls --format '{{.Name}}' | grep -wq vlan; then
  echo "vlan 网络不存在，正在创建..."
  docker network create -d bridge \
    --subnet=172.19.0.0/24 \
    --gateway=172.19.0.254 \
    vlan
else
  echo "vlan 网络已存在，无需创建。"
fi

# 创建portainer_data卷
if ! docker volume ls --format '{{.Name}}' | grep -wq "^portainer_data$"; then
    echo "portainer_data 不存在，正在创建..."
    docker volume create portainer_data
else
    echo "portainer_data 已存在，无需创建。"
fi

# 获取 Docker_Volumes 路径 (只为252和251准备)
if [[ "$docker_val" == "252" || "$docker_val" == "251" ]]; then
    Docker_Volumes=$(docker volume inspect portainer_data --format '{{.Mountpoint}}' 2>/dev/null | sed 's#/portainer_data/_data$##')
    [ -z "$Docker_Volumes" ] && Docker_Volumes="/var/lib/docker/volumes"
fi

# 先停止并删除同名容器，防止冲突
docker stop $(docker ps -q)
docker rm -f ui 2>/dev/null || true

if [ "$docker_val" == "253" ]; then
    # 检查是否有ikuaiui镜像
    if ! docker image ls --format '{{.Repository}}' | grep -wq "^ikuaiui$"; then
      echo "本地没有ikuaiui镜像，开始拉取..."
      docker pull lihaixin/ui:ce-2.19.5 || { echo "拉取失败"; exit 1; }
      docker tag lihaixin/ui:ce-2.19.5 ikuaiui
      docker rmi lihaixin/ui:ce-2.19.5
      echo "已拉取并重命名为ikuaiui"
    else
      echo "本地已存在ikuaiui镜像，无需拉取。"
    fi
    # 检查名为 ui 的容器是否存在
    if docker ps -a --format '{{.Names}}' | grep -wq ui; then
        echo "ui 容器已存在，尝试启动..."
        docker start ui
    else
        echo "ui 容器不存在，创建并启动..."
        docker run -d \
            --net=host \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v portainer_data:/data \
            -v portainer_data_conf:/usr/sbin/conf \
            -e TPORT=8002 \
            -e COUNTRY=cn \
            -e PASSWORD="${ADMIN_PASS}" \
            -e TEMPLATES=https://dockerfile.15099.net/index.json \
            -e NO=${UI_NO} \
            --name ui \
            ikuaiui
    fi
elif [ "$docker_val" == "252" ]; then
    # 检查是否有ikuaiuia镜像
    if ! docker image ls --format '{{.Repository}}' | grep -wq "^ikuaiuia$"; then
      echo "本地没有ikuaiuia镜像，开始拉取..."
      docker pull lihaixin/ui:agent-2.21.5 || { echo "拉取失败"; exit 1; }
      docker tag lihaixin/ui:agent-2.21.5 ikuaiuia
      docker rmi lihaixin/ui:agent-2.21.5
      echo "已拉取并重命名为ikuaiuia"
    else
      echo "本地已存在ikuaiuia镜像，无需拉取。"
    fi
    # 检查名为 ui 的容器是否存在
    if docker ps -a --format '{{.Names}}' | grep -wq ui; then
        echo "ui 容器已存在，尝试启动..."
        docker start ui
    else
        echo "ui 容器不存在，创建并启动..."
        docker run -d \
          --net=host \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v ${Docker_Volumes}:/var/lib/docker/volumes \
          -v /:/host \
          --name ui \
          ikuaiuia
    fi

elif [ "$docker_val" == "251" ]; then
    # 检查是否有ikuaiuia镜像
    if ! docker image ls --format '{{.Repository}}' | grep -wq "^ikuaiuia$"; then
      echo "本地没有ikuaiuia镜像，开始拉取..."
      docker pull lihaixin/ui:agent-2.21.5 || { echo "拉取失败"; exit 1; }
      docker tag lihaixin/ui:agent-2.21.5 ikuaiuia
      docker rmi lihaixin/ui:agent-2.21.5
      echo "已拉取并重命名为ikuaiuia"
    else
      echo "本地已存在ikuaiuia镜像，无需拉取。"
    fi
    # 检查名为 ui 的容器是否存在
    if docker ps -a --format '{{.Names}}' | grep -wq ui; then
        echo "ui 容器已存在，尝试启动..."
        docker start ui
    else
        echo "ui 容器不存在，创建并启动..."
        docker run -d \
          --net=host \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v ${Docker_Volumes}:/var/lib/docker/volumes \
          -v /:/host \
          -v portainer_data:/data \
          -e EDGE=1 \
          -e EDGE_ID="${EDGE_ID}" \
          -e EDGE_KEY="${EDGE_KEY}" \
          -e EDGE_INSECURE_POLL=1 \
          --name ui \
          ikuaiuia
    fi
else
    echo "/etc/mnt/docker 文件内容不是 253、252、251，未执行任何 docker run"
    exit 1
fi
