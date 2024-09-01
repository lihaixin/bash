#!/bin/bash
echo "准备安装Portainer 图像界面..."

#######################################################install_portainer########################################################################################
install_portainer() {
echo "开始安装Portainer 图像界面"
DEFAULT_VALUE="@china1234567"
prompt="请输入admin密码，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}"
docker stop ui
docker rm ui
docker pull lihaixin/portainer:ce-2.19.5
docker run -d \
-p 9443:9443 \
-p 8000:8000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v portainer_data:/data \
-e TPORT=8000 \
-e COUNTRY=cn \
-e PASSWORD="$USER_INPUT" \
--name ui \
--restart=always \
lihaixin/portainer:ce-2.19.5
}
install_portainer
