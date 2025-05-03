#!/bin/bash
# 从 URL 加载 utils.sh
source /dev/stdin <<< "$(wget -qO- https://bash.15099.net/linux/utils.sh)"

get_system_info () {
    log_message INFO "Getting system information..."

    # 获取公网 IP 地址
    export WANIP=""
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://ipinfo.io/ip)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://api.ipify.org)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://ifconfig.co/ip)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://api.ipify.org)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
    if [[ -z $WANIP ]]; then
        log_message ERROR "Container network is not working!"
        exit 1
    fi
    log_message SUCCESS "IP Address: $WANIP"

    # 获取 IP 所在国家
    export COUNTRY=""
    COUNTRY=$(curl --max-time 5 ipinfo.io/country 2>/dev/null || curl --max-time 5 https://ipapi.co/country 2>/dev/null)
    COUNTRY=$(echo "$COUNTRY" | tr '[:upper:]' '[:lower:]')
    log_message SUCCESS "IP Country: $COUNTRY"

    # 获取总内存大小
    export MEM_TOTAL=""
    MEM_INFO=$(free -m)
    MEM_TOTAL=$(echo "$MEM_INFO" | grep Mem | awk '{print $2}')
    log_message SUCCESS "Memory Size (MB): $MEM_TOTAL"

    # 获取总磁盘大小
    export DISK_TOTAL=""
    DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    log_message SUCCESS "Disk Size: $DISK_TOTAL"

    # 检测是否为虚拟机
    export VIRTUAL_PLATFORM=""
    if [ -f "/sys/class/dmi/id/product_name" ]; then
        VIRTUAL_PLATFORM=$(cat /sys/class/dmi/id/product_name)
        VIRTUAL_PLATFORM="Yes, $VIRTUAL_PLATFORM"
        log_message SUCCESS "Virtual Platform: $VIRTUAL_PLATFORM"
    else
        VIRTUAL_PLATFORM="No, Physical machine"
        log_message SUCCESS "Virtual Platform: $VIRTUAL_PLATFORM"
    fi

    # 检测系统类型
    source /etc/os-release
    export OS=""
    if grep -q "Armbian" /etc/*release*; then
        log_message INFO "Current system is Armbian"
        OS=armbian
    elif [[ $ID == "debian" ]]; then
        log_message INFO "Current system is Debian"
        OS=debian
    elif [[ $ID == "ubuntu" ]]; then
        log_message INFO "Current system is Ubuntu"
        OS=ubuntu
    elif [[ $ID == "alpine" ]]; then
        log_message INFO "Current system is Alpine"
        OS=alpine
    else
        log_message ERROR "Unable to directly identify the system type. This script does not support it. Please reapply OS to Debian."
        OS=other
    fi

    # 检查用户是否为 root
    user="$(id -un 2>/dev/null || true)"
    if [ "$user" != 'root' ]; then
        log_message ERROR "This script only supports running as root user. Exiting..."
        exit 1
    fi
}

# 主程序启动
get_system_info
log_message INFO "Downloading and executing the next script..."
curl -sL https://bash.15099.net/linux/index.sh > /tmp/index.sh
if [ $? -eq 0 ]; then
    log_message SUCCESS "Successfully downloaded the script. Executing now..."
    sleep 2
    bash /tmp/index.sh
else
    log_message ERROR "Failed to download the script. Exiting..."
    exit 1
fi
