#!/bin/bash

# 定义颜色
RED='\033[0;31m'    # 错误或警告信息
GREEN='\033[0;32m'  # 成功信息
YELLOW='\033[0;33m' # 警告或提示信息
BLUE='\033[0;34m'   # 一般信息
CYAN='\033[0;36m'   # 时间戳或强调信息
NC='\033[0m'        # 重置颜色

# 日志输出函数（带时间戳和类别）
log_message() {
    local type=$1    # 日志类别：INFO, SUCCESS, WARNING, ERROR
    local message=$2 # 日志内容

    case $type in
        INFO)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${BLUE}[INFO]${NC} $message"
            ;;
        SUCCESS)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}[SUCCESS]${NC} $message"
            ;;
        WARNING)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}[WARNING]${NC} $message"
            ;;
        ERROR)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}[ERROR]${NC} $message"
            ;;
        *)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${NC}$message"
            ;;
    esac
}

log_message INFO "Preparing to initialize Linux..."

# 函数：变更软件源并更新系统
chang_repo() {
    log_message INFO "Adjusting repository information, upgrading the system, and installing basic packages..."

    DEFAULT_VALUE="Y"
    prompt="Enter content (Y/N), default value will be used if no input within 10 seconds ($DEFAULT_VALUE): "
    read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
    : ${USER_INPUT:=$DEFAULT_VALUE}

    if [ "$USER_INPUT" = "Y" ] && [ "$COUNTRY" = "cn" ]; then
        log_message INFO "Now adjusting repository for domestic mirrors..."
        case $OS in
            debian)
                log_message INFO "Executing operations for Debian..."
                sed -i.bak 's#http://deb.debian.org#https://mirrors.tuna.tsinghua.edu.cn/debian#g' /etc/apt/sources.list
                sed -i 's#http://security.debian.org#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
                apt update -y && apt upgrade -y
                apt-get install net-tools wget ntpdate xz-utils -y
                ;;
            ubuntu)
                log_message INFO "Executing operations for Ubuntu..."
                sed -i.bak 's#http://archive.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
                apt update -y && apt upgrade -y
                apt-get install net-tools wget ntpdate xz-utils -y
                ;;
            armbian)
                log_message INFO "Executing operations for Armbian..."
                sed -i.bak 's#http://apt.armbian.com#https://mirrors.tuna.tsinghua.edu.cn/armbian#g' /etc/apt/sources.list.d/armbian.list
                sed -i 's#http://archive.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
                apt update -y && apt upgrade -y
                apt-get install net-tools wget ntpdate ntp xz-utils -y
                systemctl disable --now ssh.socket
                systemctl enable --now ssh.service
                ;;
            alpine)
                log_message INFO "Executing operations for Alpine..."
                modprobe tun
                echo "tun" >>/etc/modules
                lsmod | grep tun
                sed -i s'/# http/http/g' /etc/apk/repositories
                apk upgrade --no-cache --available
                apk add qemu-guest-agent tzdata
                rc-update add qemu-guest-agent
                rc-status -a
                ;;
            *)
                log_message WARNING "Unknown system type: $OS"
                ;;
        esac
    else
        log_message INFO "Skipping repository adjustment, directly upgrading the system..."
        case $OS in
            debian | ubuntu | armbian)
                log_message INFO "Executing operations for $OS..."
                apt update -y && apt upgrade -y
                apt-get install net-tools wget ntpdate ntp xz-utils -y
                ;;
            alpine)
                log_message INFO "Executing operations for Alpine..."
                modprobe tun
                echo "tun" >>/etc/modules
                lsmod | grep tun
                sed -i s'/# http/http/g' /etc/apk/repositories
                apk upgrade --no-cache --available
                apk add qemu-guest-agent tzdata
                rc-update add qemu-guest-agent
                rc-status -a
                ;;
            *)
                log_message WARNING "Unknown system type: $OS"
                ;;
        esac
    fi
}

# 函数：调整系统 DNS 和时区
chang_dns_time() {
    log_message INFO "Adjusting system DNS and timezone..."

    DEFAULT_VALUE="Y"
    prompt="Enter content (Y/N), default value will be used if no input within 10 seconds ($DEFAULT_VALUE): "
    read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
    : ${USER_INPUT:=$DEFAULT_VALUE}

    if [ "$USER_INPUT" = "Y" ] && [ "$COUNTRY" = "cn" ]; then
        log_message INFO "Setting DNS to domestic servers..."
        rm -rf /etc/resolv.conf
        cat > /etc/resolv.conf << EOF
nameserver 223.5.5.5
nameserver 114.114.114.114
EOF
    else
        log_message INFO "Setting DNS to international servers..."
        rm -rf /etc/resolv.conf
        cat > /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
    fi
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

# 调用函数
chang_repo
chang_dns_time
log_message SUCCESS "Linux initialization completed."
