#!/bin/bash
echo "准备安装Portainer 图像界面..."

#######################################################install_portainer########################################################################################
install_portainer() {
echo "开启安装macvlan和自定义桥接网络"

NETWORK_NAME=vlan                                                  # 定义网络名称
: ${VNAME:=$(ip route | grep "default via" |awk '{ print $5}')}    # MAC VLAN父设备名称
# 检查 网络是否已存在
EXISTING_NETWORK=$(docker network ls --format "{{.Name}}" | grep -w "^$NETWORK_NAME$")

if [ -z "$EXISTING_NETWORK" ]; then
    # 如果网络不存在，则创建网络
    docker network create \
      -d macvlan \
      --subnet=172.19.0.0/24 \
      --gateway=172.19.0.$(( (RANDOM % 53) + 201 )) \
      -o macvlan_mode=bridge \
      -o parent=$VNAME \
      "$NETWORK_NAME" > /dev/null 2>&1
      echo "网络 $NETWORK_NAME 已成功创建。"
else
    echo "网络 $NETWORK_NAME 已存在，跳过创建。"
fi

NETWORK_NAME=cbridge                                                 # 定义网络名称
# 检查 网络是否已存在
EXISTING_NETWORK=$(docker network ls --format "{{.Name}}" | grep -w "^$NETWORK_NAME$")
if [ -z "$EXISTING_NETWORK" ]; then
    # 如果网络不存在，则创建网络
    docker network create -d bridge \
    --subnet=172.20.0.0/24 \
    --gateway=172.20.0.$(( (RANDOM % 53) + 201 )) \
    cbridge 1> /dev/null 2>&1
    echo "网络 $NETWORK_NAME 已成功创建。"
else
    echo "网络 $NETWORK_NAME 已存在，跳过创建。"
fi


echo "开始安装toolbox容器"
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
echo "开始安装Portainer 图像界面"
DEFAULT_PASSWD="@china1234567"
prompt="请输入admin密码（直接回车使用默认值 $DEFAULT_PASSWD ）: "
USER_PASSWD=""
while true; do
    read -t 40 -p "$prompt" USER_PASSWD
    if [ -z "$USER_PASSWD" ]; then
        USER_PASSWD=$DEFAULT_PASSWD
        echo "将使用默认密码: $DEFAULT_PASSWD 进行安装。"
        break
    elif [ ${#USER_PASSWD} -ge 12 ]; then
        echo "将使用密码: $USER_PASSWD 进行安装。"
        break
    else
        echo "密码长度不足12位，请重新输入。"
    fi
done

DEFAULT_TEMPLATES="https://dockerfile.15099.net/index.json"
prompt="请输入你自定义的模板地址，60秒内无输入将采用默认值( $DEFAULT_TEMPLATES ): "
read -t 120 -p "$prompt" USER_TEMPLATES || USER_TEMPLATES=$DEFAULT_TEMPLATES
: ${USER_TEMPLATES:=$DEFAULT_TEMPLATES}
echo "将使用模板地址: $USER_TEMPLATES 进行安装。"

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
lihaixin/ui:ce-2.19.5
echo "Portainer成功安装，访问：https://${WANIP}:9443 账号：admin 密码：${USER_PASSWD} "
}
install_portainer
