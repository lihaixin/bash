#!/bin/bash
echo "准备初始化linux"

#######################################################chang_repo_update########################################################################################
chang_repo() {
echo "调整仓库信息、系统升级、安装基本包"
DEFAULT_VALUE="Y"
prompt="请输入内容(Y/N)，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}"

if [ "$USER_INPUT" = "Y" ] &&[ "$COUNTRY" = "cn" ]; then
    echo "现在调整仓库信息、系统升级、安装基本包"
    case $OS in
        debian)
            echo "执行针对Debian的操作..."
            sed -i.bak 's#http://deb.debian.org#https://mirrors.tuna.tsinghua.edu.cn/debian#g' /etc/apt/sources.list
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate -y
            ;;
        ubuntu)
            echo "执行针对Ubuntu的操作..."
            sed -i.bak 's#http://archive.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list.d/sources.list
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate -y
            ;;
        armbian)
            echo "执行针对Armbian的操作..."
            sed -i.bak 's#http://apt.armbian.com#https://mirrors.tuna.tsinghua.edu.cn/armbian#g' /etc/apt/sources.list.d/armbian.list
            sed -i.bak 's#http://archive.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate -y
            ;;
        *)
            echo "未知的系统类型: $OS"
            ;;
    esac
else
    echo "不调正仓库，直接升级,安装基本包"
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


#######################################################chang_dns_time########################################################################################
chang_dns_time() {
echo "调整系统DNS和时区和时间"
DEFAULT_VALUE="Y"
prompt="请输入内容(Y/N)，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}"
if [ "$USER_INPUT" = "Y" ] &&[ "$COUNTRY" = "cn" ]; then
    echo "现在调整DNS为国内DNS解析"
    #国内DNS
    rm -rf /etc/resolv.conf 
    cat > /etc/resolv.conf << EOF 
    nameserver 223.5.5.5 
    nameserver 114.114.114.114
    EOF
    cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
    ntpdate cn.pool.ntp.org
else
    echo "现在调整DNS为国外DNS解析和时区"
    #国外DNS
    rm -rf /etc/resolv.conf 
    cat > /etc/resolv.conf << EOF 
    nameserver 8.8.8.8 
    nameserver 1.1.1.1
    EOF
    fi
    cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
    ntpdate cn.pool.ntp.org
}

#######################################################chang_hostname########################################################################################
chang_hostname() {
echo "调整系统主机名"
DEFAULT_VALUE="qq_hk20_000_gost"
prompt="请输入内容(厂家_国别+编号_用户编号_用途 | qq_hk20_000_gost)，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}"
HNAME=$USER_INPUT
echo $HNAME > /etc/hostname
hostname $HNAME
}

#######################################################chang_ssh########################################################################################
chang_ssh() {
echo "调整系统SSH配置信息"
DEFAULT_VALUE="!passWord"
prompt="请输入root密码)，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}"
echo -e "$USER_INPUT\n$USER_INPUT" | (passwd root) 

echo "关闭X11转发和修改端口"
sed -i s'/^X11Forwarding yes$/#X11Forwarding yes/' /etc/ssh/sshd_config 
sed -i s'/^#Port 22$/Port 32123/' /etc/ssh/sshd_config 
sed -i s'/^Port 22$/Port 32123/' /etc/ssh/sshd_config 
sed -i s'/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 
sed -i s'/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart
echo "成功调整SSH端口为32123，密码为：$USER_INPUT 开启主机密码登录"
}


#######################################################chang_wireguard########################################################################################
chang_wireguard() {
echo "调整仓库安装Wireguard内核支持"
DEFAULT_VALUE="Y"
prompt="请输入内容(Y/N)，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}"

if [ "$USER_INPUT" = "Y" ] &&[ "$COUNTRY" = "cn" ]; then
    echo "现在调整仓库信息、系统升级、安装基本包"
    case $OS in
        debian)
            echo "执行针对Debian的操作..."
            echo 'deb http://mirrors.aliyun.com/debian buster-backports main' | tee /etc/apt/sources.list.d/buster-backports.list
            apt update -y
            apt install linux-headers-$(uname -r) -y
            apt install wireguard -y
            modprobe wireguard && lsmod | grep wireguard
            ;;
        ubuntu)
            echo "执行针对Ubuntu的操作..."
            ;;
        armbian)
            echo "执行针对Armbian的操作..."
            ;;
        *)
            echo "未知的系统类型: $OS"
            ;;
    esac
else
    echo "不调正仓库，直接升级,安装基本包"
    case $OS in
        debian)
            echo "执行针对Debian的操作..."
            echo 'deb http://ftp.debian.org/debian buster-backports main' | tee /etc/apt/sources.list.d/buster-backports.list
            apt update -y
            apt install linux-headers-$(uname -r) -y
            apt install wireguard -y
            modprobe wireguard && lsmod | grep wireguard
            ;;
        ubuntu)
            echo "执行针对Ubuntu的操作..."
            ;;
        armbian)
            echo "执行针对Armbian的操作..."
            ;;
        *)
            echo "未知的系统类型: $OS"
            ;;
    esac
fi
}
