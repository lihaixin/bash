#!/bin/bash
echo "准备安装Portainer 图像界面..."

#######################################################install_portainer########################################################################################
install_portainer() {
echo "开始安装toolbox容器"
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
prompt="请输入admin密码，长度不低于12位，20秒内无输入将采用默认值( $DEFAULT_PASSWD ): "
read -t 20 -p "$prompt" USER_PASSWD || USER_PASSWD=$DEFAULT_PASSWD
: ${USER_PASSWD:=$DEFAULT_PASSWD}

DEFAULT_TEMPLATES="https://dockerfile.15099.net/index.json"
prompt="请输入你自动的模板地址，40秒内无输入将采用默认值( $DEFAULT_TEMPLATES ): "
read -t 40 -p "$prompt" USER_TEMPLATES || USER_TEMPLATES=$DEFAULT_TEMPLATES
: ${USER_TEMPLATES:=$DEFAULT_TEMPLATES}

docker stop ui 1> /dev/null 2>&1
docker rm ui 1> /dev/null 2>&1
docker pull lihaixin/portainer:ce-2.19.5
docker run -d \
-p 9443:9443 \
-p 8000:8000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v portainer_data:/data \
-e TPORT=8000 \
-e COUNTRY=cn \
-e PASSWORD=${USER_INPUT} \
-e TEMPLATES=${USER_TEMPLATES} \
--name ui \
--restart=always \
lihaixin/portainer:ce-2.19.5
echo "Portainer成功安装，访问：https://${WANIP}:9443 账号：admin 密码：${USER_PASSWD} "
}
install_portainer
