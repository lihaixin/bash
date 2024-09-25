#!/bin/bash
echo "准备安装Portainer 图像界面..."

#######################################################install_portainer########################################################################################
install_portainer() {
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
prompt="请输入admin密码，长度不低于12位，20秒内无输入或密码长度不足将重新提示，默认值( $DEFAULT_PASSWD ): "
USER_PASSWD=""
while [[ ${#USER_PASSWD} -lt 12 ]]; do
    read -t 20 -p "$prompt" USER_PASSWD
    if [[ -z $USER_PASSWD ]]; then
        USER_PASSWD=$DEFAULT_PASSWD
        echo "未输入密码，将采用默认密码: $DEFAULT_PASSWD"
        break
    elif [[ ${#USER_PASSWD} -lt 12 ]]; then
        echo "密码长度不足12位，请重新输入。"
    fi
done
echo "将使用密码: $USER_PASSWD 进行安装。"

DEFAULT_TEMPLATES="https://dockerfile.15099.net/index.json"
prompt="请输入你自动的模板地址，40秒内无输入将采用默认值( $DEFAULT_TEMPLATES ): "
read -t 40 -p "$prompt" USER_TEMPLATES || USER_TEMPLATES=$DEFAULT_TEMPLATES
: ${USER_TEMPLATES:=$DEFAULT_TEMPLATES}
echo "将使用模板地址: $USER_TEMPLATES 进行安装。"

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
