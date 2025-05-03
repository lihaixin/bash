#!/bin/bash
export TERM=xterm-256color

# 定义颜色
RED='\033[0;31m'    # 用于表示错误或警告信息，比如重要错误或无效输入
GREEN='\033[0;32m'  # 用于表示成功或正面反馈，比如操作成功或结果输出
YELLOW='\033[0;33m' # 用于警告或提醒信息，比如非关键性问题或需要注意的提示
BLUE='\033[0;34m'   # 用于一般信息或标题，比如大标题或任务状态
CYAN='\033[0;36m'   # 用于强调辅助信息，比如时间戳或次要但有意义的数据
NC='\033[0m'        # 重置颜色

# 定义日志文件
LOG_FILE=${LOG_FILE:-"$HOME/system_info.log"}

# 创建日志文件并设置权限（如果需要）
touch "$LOG_FILE" && chmod 644 "$LOG_FILE"

# 为日志输出添加时间戳和颜色
log_with_timestamp() {
    while IFS= read -r line; do
        # 根据日志内容判断颜色
        if [[ "$line" == *"Error"* ]]; then
            # 如果日志包含 "Error"，使用红色
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}$line${NC}"
        elif [[ "$line" == *"Success"* || "$line" == *"Completed"* ]]; then
            # 如果日志包含 "Success" 或 "Completed"，使用绿色
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}$line${NC}"
        elif [[ "$line" == *"Warning"* || "$line" == *"Notice"* ]]; then
            # 如果日志包含 "Warning" 或 "Notice"，使用黄色
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}$line${NC}"
        else
            # 默认使用普通颜色
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${NC}$line"
        fi
    done
}

# 重定向标准输出和标准错误到日志文件，同时显示在终端
exec > >(log_with_timestamp | tee -a "$LOG_FILE") 2>&1

get_system_info () {
    echo -e "${BLUE}Getting system information...${NC}"

    # 获取公网 IP 地址
    export WANIP=""
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://ipinfo.io/ip)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://api.ipify.org)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://ifconfig.co/ip)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s icanhazip.com)
    [[ -z $WANIP ]] && WANIP=$(curl --max-time 5 -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
    [[ -z $WANIP ]] && echo -e "${RED}Error: Container network is not working!${NC}" && exit
    echo -e "${GREEN}IP Address:${NC} $WANIP"

    # 获取 IP 所在国家
    export COUNTRY=""
    COUNTRY=$(curl --max-time 5 ipinfo.io/country 2>/dev/null || curl --max-time 5 https://ipapi.co/country 2>/dev/null)
    COUNTRY=$(echo "$COUNTRY" | tr '[:upper:]' '[:lower:]')
    echo -e "${GREEN}IP Country:${NC} $COUNTRY"

    # 获取总内存大小
    export MEM_TOTAL=""
    MEM_INFO=$(free -m)
    MEM_TOTAL=$(echo "$MEM_INFO" | grep Mem | awk '{print $2}')
    echo -e "${GREEN}Memory Size (MB):${NC} $MEM_TOTAL"

    # 获取总磁盘大小
    export DISK_TOTAL=""
    DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    echo -e "${GREEN}Disk Size:${NC} $DISK_TOTAL"

    # 检测是否为虚拟机
    export VIRTUAL_PLATFORM=""
    if [ -f "/sys/class/dmi/id/product_name" ]; then
        VIRTUAL_PLATFORM=$(cat /sys/class/dmi/id/product_name)
        VIRTUAL_PLATFORM="Yes, $VIRTUAL_PLATFORM"
        echo -e "${GREEN}Virtual Platform:${NC} $VIRTUAL_PLATFORM"
    else
        VIRTUAL_PLATFORM="No, Physical machine"
        echo -e "${GREEN}Virtual Platform:${NC} $VIRTUAL_PLATFORM"
    fi

    # 检测系统类型
    source /etc/os-release
    export OS=""
    if grep -q "Armbian" /etc/*release*; then
        echo -e "${BLUE}Current system is Armbian${NC}"
        OS=armbian
    elif [[ $ID == "debian" ]]; then
        echo -e "${BLUE}Current system is Debian${NC}"
        OS=debian
    elif [[ $ID == "ubuntu" ]]; then
        echo -e "${BLUE}Current system is Ubuntu${NC}"
        OS=ubuntu
    elif [[ $ID == "alpine" ]]; then
        echo -e "${BLUE}Current system is Alpine${NC}"
        OS=alpine
    else
        echo -e "${RED}Error: Unable to directly identify the system type, this script does not support it, PLEASE reaply OS to debian use this bash${NC}"
        OS=other
    fi

    # 检查用户是否为 root
    user="$(id -un 2>/dev/null || true)"
    if [ "$user" != 'root' ]; then
        echo -e "${RED}Error: This script only supports running as root user, exiting${NC}"
        exit 1
    fi
}

# 主程序启动
get_system_info
curl -sL https://bash.15099.net/linux/index.sh > /tmp/index.sh
sleep 2
bash /tmp/index.sh
