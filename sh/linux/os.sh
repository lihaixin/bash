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

# 主菜单函数
# 提供用户操作选项
sub1_main_menu() {
    clear
    log_message INFO "Displaying the OS management menu..."
    log_message INFO "################################################################"
    log_message INFO "#   Welcome to https://bash.15099.net OS Management System      "
    log_message INFO "#   Is the host a virtual platform: $VIRTUAL_PLATFORM            "
    log_message INFO "#   Host memory size (MB): $MEM_TOTAL Disk size: $DISK_TOTAL     "
    log_message INFO "#   Host IP address: $WANIP        IP country: $COUNTRY          "
    log_message INFO "################################################################"
    log_message INFO "Please select an operation:"
    log_message INFO "1) Replace Linux with pure Debian 12"
    log_message INFO "2) One-click install iKuai system"
    log_message INFO "3) One-click install Armbian on physical machine"
    log_message INFO "4) One-click install Feiniu NAS on physical machine"
    log_message INFO "0) Return to previous menu"

    read -p "Enter choice: " choice
    case $choice in
        1) sub1_run_script1 ;;
        2) sub1_run_script2 ;;
        3) sub1_run_script3 ;;
        4) sub1_run_script4 ;;
        0) log_message INFO "Returning to the previous menu..."; exit 0 ;;
        *) log_message WARNING "Invalid option, returning to main menu."; sleep 2; sub1_main_menu ;;
    esac
}

# 脚本1：替换为纯净的 Debian 12
sub1_run_script1() {
    log_message INFO "Running script to replace Linux with pure Debian 12..."
    curl -sL https://bash.15099.net/linux/online_install_linux.sh > /tmp/online_install_linux.sh
    if [ $? -eq 0 ]; then
        bash /tmp/online_install_linux.sh
        rm -rf /tmp/online_install_linux.sh
        log_message SUCCESS "Replacing Linux with pure Debian 12 completed."
    else
        log_message ERROR "Failed to download or execute the script for Debian 12 replacement."
    fi
    read -p "Press Enter to continue..."
    sub1_main_menu
}

# 脚本2：安装 iKuai 系统
sub1_run_script2() {
    log_message INFO "Running script to install iKuai system..."
    curl -sL https://bash.15099.net/linux/online_install_ikuai.sh > /tmp/online_install_ikuai.sh
    if [ $? -eq 0 ]; then
        bash /tmp/online_install_ikuai.sh
        rm -rf /tmp/online_install_ikuai.sh
        log_message SUCCESS "Installing iKuai system completed."
    else
        log_message ERROR "Failed to download or execute the script for iKuai installation."
    fi
    read -p "Press Enter to continue..."
    sub1_main_menu
}

# 脚本3：在实体机上安装 Armbian
sub1_run_script3() {
    log_message INFO "Running script to install Armbian on physical machine..."
    curl -sL https://bash.15099.net/linux/online_install_armbian.sh > /tmp/online_install_armbian.sh
    if [ $? -eq 0 ]; then
        bash /tmp/online_install_armbian.sh
        rm -rf /tmp/online_install_armbian.sh
        log_message SUCCESS "Installing Armbian on physical machine completed."
    else
        log_message ERROR "Failed to download or execute the script for Armbian installation."
    fi
    read -p "Press Enter to continue..."
    sub1_main_menu
}

# 脚本4：在实体机上安装 Feiniu NAS
sub1_run_script4() {
    log_message INFO "Running script to install Feiniu NAS on physical machine..."
    curl -sL https://gh.15099.net/https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh > /tmp/online_install_fnos.sh
    if [ $? -eq 0 ]; then
        bash /tmp/online_install_fnos.sh fnos
        rm -rf /tmp/online_install_fnos.sh
        log_message SUCCESS "Installing Feiniu NAS on physical machine completed."
    else
        log_message ERROR "Failed to download or execute the script for Feiniu NAS installation."
    fi
    read -p "Press Enter to continue..."
    sub1_main_menu
}

# 主程序循环
clear
while true; do
    sub1_main_menu
done
