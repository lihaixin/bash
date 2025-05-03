#!/bin/bash
export TERM=xterm-256color

# 定义颜色
RED='\033[0;31m'    # 错误或警告信息
GREEN='\033[0;32m'  # 成功信息
YELLOW='\033[0;33m' # 警告或提示信息
BLUE='\033[0;34m'   # 一般信息
CYAN='\033[0;36m'   # 时间戳或强调信息
NC='\033[0m'        # 重置颜色

# 定义日志文件
LOG_FILE=${LOG_FILE:-"/tmp/system_info.log"}

# 创建日志文件并设置权限（如果需要）
touch "$LOG_FILE" && chmod 644 "$LOG_FILE"

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

# 重定向标准输出和标准错误到日志文件，同时显示在终端
exec > >(tee -a "$LOG_FILE") 2>&1

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
