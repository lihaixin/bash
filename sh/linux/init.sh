#!/bin/bash
echo "准备初始化linux"

#######################################################chang_repo_update########################################################################################
chang_repo() {
echo ""
echo "调整仓库信息、系统升级、安装基本包"
DEFAULT_VALUE="Y"
prompt="请输入内容(Y/N)，10秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 10 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}

if [ "$USER_INPUT" = "Y" ] &&[ "$COUNTRY" = "cn" ]; then
    echo "现在调整仓库信息、系统升级、安装基本包"
    case $OS in
        debian)
            echo "执行针对Debian的操作..."
            # https://mirrors.tuna.tsinghua.edu.cn/help/debian/
            sed -i.bak 's#http://deb.debian.org#https://mirrors.tuna.tsinghua.edu.cn/debian#g' /etc/apt/sources.list
            sed -i 's#http://security.debian.org#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate xz-utils -y
            ;;
        ubuntu)
            echo "执行针对Ubuntu的操作..."
            sed -i.bak 's#http://archive.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list.d/sources.list
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate xz-utils -y
            ;;
        armbian)
            echo "执行针对Armbian的操作..."
            #systemctl enable armbian-resize-filesystem
            #systemctl start armbian-resize-filesystem
            sed -i.bak 's#http://apt.armbian.com#https://mirrors.tuna.tsinghua.edu.cn/armbian#g' /etc/apt/sources.list.d/armbian.list
            sed -i 's#http://archive.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate ntp xz-utils -y
            systemctl disable --now ssh.socket
            systemctl enable --now ssh.service
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

chang_repo
#######################################################chang_dns_time########################################################################################
chang_dns_time() {
echo ""
echo "调整系统DNS和时区和时间"
DEFAULT_VALUE="Y"
prompt="请输入内容(Y/N)，10秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 10 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}
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
chang_dns_time
#######################################################chang_hostname########################################################################################
chang_hostname() {
echo ""
echo "调整系统主机名"
DEFAULT_VALUE="qq-hk20-000-gost"
prompt="请输入内容(厂家-国别+编号-用户编号-用途 | qq-hk20-000-gost)，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}
HNAME=$USER_INPUT
echo $HNAME > /etc/hostname
hostname $HNAME
}
chang_hostname
#######################################################chang_ssh########################################################################################
chang_ssh() {
echo ""
echo "调整系统SSH配置信息"
DEFAULT_PASSWD="!passWord"
prompt="请输入root密码)，10秒内无输入将采用默认值( $DEFAULT_PASSWD ): "
# 使用read的-t选项及命令替换特性
read -t 10 -p "$prompt" PASSWD_INPUT || PASSWD_INPUT=$DEFAULT_PASSWD
: ${PASSWD_INPUT:=$DEFAULT_PASSWD}
echo -e "$PASSWD_INPUT\n$PASSWD_INPUT" | (passwd root) 

echo "关闭X11转发和修改端口"
sed -i s'/^X11Forwarding yes$/#X11Forwarding yes/' /etc/ssh/sshd_config 
sed -i s'/^#Port 22$/Port 32123/' /etc/ssh/sshd_config 
sed -i s'/^Port 22$/Port 32123/' /etc/ssh/sshd_config 
sed -i s'/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 
sed -i s'/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart
echo "成功调整SSH端口为32123，密码为：$PASSWD_INPUT 开启主机密码登录"
}
chang_ssh

#######################################################chang_wireguard########################################################################################
chang_wireguard() {
echo ""
echo "调整仓库安装Wireguard内核支持"
DEFAULT_VALUE="N"
prompt="请输入内容(Y/N)，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}

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
chang_wireguard
#######################################################chang_sysctl########################################################################################
chang_sysctl() {
echo ""
echo "调整系统sysctl信息"
cat > /etc/sysctl.conf << TEMPEOF
##提高整个系统的文件限制
fs.file-max = 35525
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 32400
##调整内核打开数
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_reuse = 1
##net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 40000 65000
net.ipv4.tcp_max_syn_backlog = 8192
#net.ipv4.tcp_max_tw_buckets = 5000
#net.netfilter.nf_conntrack_max=1048576
#net.nf_conntrack_max=1048576
##开启TCP Fast Open
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
##开启bbr
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
##虚拟内存优化
vm.swappiness=10
##关闭IPV6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
TEMPEOF
sysctl -p
echo "成功调整SSH端口为32123，密码为：$PASSWD_INPUT 开启主机密码登录"
}
chang_sysctl
