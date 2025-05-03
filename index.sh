#!/bin/bash
export TERM=xterm-256color
# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 定义日志文件
LOG_FILE=${LOG_FILE:-"$HOME/system_info.log"}

# 创建日志文件并设置权限（如果需要）
touch "$LOG_FILE" && chmod 644 "$LOG_FILE"

# 重定向标准输出和标准错误到日志文件，同时显示在终端
exec > >(tee -a "$LOG_FILE") 2>&1

# 为日志添加时间戳
log_with_timestamp() {
    while IFS= read -r line; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
    done
}

# 通过管道给日志输出添加时间戳
exec > >(log_with_timestamp | tee -a "$LOG_FILE") 2>&1

get_system_info () {
    echo "Getting system information..."

    # Get public IP address
    export WANIP=""
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://ipinfo.io/ip)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://api.ipify.org)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://ifconfig.co/ip)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s icanhazip.com)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
    [[ -z $WANIP ]] && printecho 3 "Container network is not working!" && exit
    echo "IP Address: $WANIP"

    # Get IP country, using ipinfo.io and ipapi.co as examples, ensure compliance with their terms
    export COUNTRY=""
    COUNTRY=$(curl --max-time 5 ipinfo.io/country 2>/dev/null || curl --max-time 5 https://ipapi.co/country 2>/dev/null)
    COUNTRY=$(echo "$COUNTRY" | tr '[:upper:]' '[:lower:]')
    echo "IP Country: $COUNTRY"

    # Get total memory size
    export MEM_TOTAL=""
    MEM_INFO=$(free -m)
    MEM_TOTAL=$(echo "$MEM_INFO" | grep Mem | awk '{print $2}')
    echo "Memory Size (MB): $MEM_TOTAL"

    # Get total disk size, using root directory as an example
    export DISK_TOTAL=""
    DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    echo "Disk Size: $DISK_TOTAL"

    # Detect if it is a virtual machine, simplified to check for common virtualization platform identification files
    export VIRTUAL_PLATFORM=""
    if [ -f "/sys/class/dmi/id/product_name" ]; then
        VIRTUAL_PLATFORM=$(cat /sys/class/dmi/id/product_name)
        VIRTUAL_PLATFORM="Yes, $VIRTUAL_PLATFORM"
        echo "Virtual Platform: $VIRTUAL_PLATFORM"
    else
        VIRTUAL_PLATFORM="No, Physical machine"
        echo "Virtual Platform: $VIRTUAL_PLATFORM"
    fi

    # Detect the system
    source /etc/os-release
    export OS=""
    if grep -q "Armbian" /etc/*release*; then
        echo "Current system is Armbian"
        OS=armbian
    elif [[ $ID == "debian" ]]; then
        echo "Current system is Debian"
        OS=debian
    elif [[ $ID == "ubuntu" ]]; then
        echo "Current system is Ubuntu"
        OS=ubuntu
    elif [[ $ID == "alpine" ]]; then
        echo "Current system is Alpine"
        OS=alpine
    else
        echo "Error: Unable to directly identify the system type, this script does not support it, PLEASE reaply OS to debian use this bash"
        OS=other
    fi

    # Check user
    user="$(id -un 2>/dev/null || true)"
    if [ "$user" != 'root' ]; then
        echo "Error: This script only supports running as root user, exiting"
        exit 1
    fi
}

# Main program start
get_system_info
curl -sL https://bash.15099.net/linux/index.sh > /tmp/index.sh
sleep 2
bash /tmp/index.sh
