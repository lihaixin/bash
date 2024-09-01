#!/bin/bash
echo "准备在线安装Debian 11 纯系统"

DEFAULT_VALUE="password"
prompt="请输入安装后密码，10秒内无输入将采用默认值( $DEFAULT_VALUE ): "
read -t 10 -p "$prompt" PASSWORD || PASSWORD=$DEFAULT_VALUE
: ${PASSWORD:=$DEFAULT_VALUE}

if [ "$COUNTRY" == "cn" ]; then
  bash <(wget --no-check-certificate -qO- 'https://bash.15099.net/linux/netinstallos.sh') -d 11 -v 64 -p "$PASSWORD" --mirror 'http://mirrors.aliyun.com/debian/'
else
  bash <(wget --no-check-certificate -qO- 'https://bash.15099.net/linux/netinstallos.sh') -d 11 -v 64 -p "$PASSWORD"
fi
