#!/bin/bash
echo "准备初始化linux"

#######################################################chang_repo########################################################################################
chang_repo() {
echo "调正仓库信息"
DEFAULT_VALUE="Y"
prompt="请输入内容(Y/N)，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}"

if [ "$USER_INPUT" = "Y" ] &&[ "$COUNTRY" = "cn" ];; then
    echo "现在调出仓库和升级"
    case $OS in
        debian)
            echo "执行针对Debian的操作..."
            ;;
        ubuntu)
            echo "执行针对Ubuntu的操作..."
            ;;
        armbian)
            echo "执行针对Armbian的操作..."
            sed -i.bak 's#http://apt.armbian.com#https://mirrors.tuna.tsinghua.edu.cn/armbian#g' /etc/apt/sources.list.d/armbian.list
            sed -i.bak 's#http://archive.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
            apt update -y && apt upgrade -y
            ;;
        *)
            echo "未知的系统类型: $OS"
            ;;
    esac
else
    echo "不调正仓库，直接升级"
    case $OS in
        debian)
            echo "执行针对Debian的操作..."
            apt update -y && apt upgrade -y
            ;;
        ubuntu)
            echo "执行针对Ubuntu的操作..."
            apt update -y && apt upgrade -y
            ;;
        armbian)
            echo "执行针对Armbian的操作..."
            apt update -y && apt upgrade -y
            ;;
        *)
            echo "未知的系统类型: $OS"
            ;;
    esac
fi
}
