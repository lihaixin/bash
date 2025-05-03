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
main_menu() {
    clear
    log_message INFO "Displaying the main menu..."
    echo "##################################################################################"
    echo "#   Welcome to https://bash.15099.net Script Management System                   "
    echo "#   This program only supports debian | ubuntu | armbian | alpine                "
    echo "#   Is the host a virtual platform: $VIRTUAL_PLATFORM  System: $OS               "
    echo "#   Host memory size (MB): $MEM_TOTAL Disk size: $DISK_TOTAL                     "
    echo "#   Host IP address: $WANIP        IP country: $COUNTRY                          "
    echo "##################################################################################"
    echo "Please select an option:"
    echo "1) Online system replacement | Change Linux version, one-click install OS on physical machine"
    echo "2) Linux initialization | Upgrade, repo, timezone, time, hostname, etc."
    echo "3) Docker environment initialization | Version, proxy, log settings, etc."
    echo "4) Install Portainer Chinese graphical interface"
    echo "5) Host bench stress test | Disk, network speed test"
    echo "6) Host unixbench stress test | CPU, memory test"
    echo "0) Return to the previous menu"

    read -p "Enter option: " -r choice
    case $choice in
        1)
            run_script1
            ;;
        2)
            run_script2
            ;;
        3)
            run_script3
            ;;
        4)
            run_script4
            ;;
        5)
            run_script5
            ;;
        6)
            run_script6
            ;;
        0)
            log_message INFO "Exiting the program..."
            exit 0 
            ;;
        *)
            log_message WARNING "Invalid option selected, returning to main menu."
            sleep 2
            main_menu
            ;;
    esac
}

# 脚本1：在线系统替换
run_script1() {
    log_message INFO "Running online script 1... Online system replacement"
    curl -sL https://bash.15099.net/linux/os.sh > /tmp/os.sh
    if [ $? -eq 0 ]; then
        bash /tmp/os.sh
        rm -rf /tmp/os.sh
        log_message SUCCESS "Script 1 execution completed."
    else
        log_message ERROR "Failed to download or execute script 1."
    fi
    read -p "Press Enter to continue..."
    main_menu
}

# 脚本2：Linux 初始化
run_script2() {
    log_message INFO "Running online script 2... Linux initialization"
    curl -sL https://bash.15099.net/linux/init.sh > /tmp/init.sh
    if [ $? -eq 0 ]; then
        bash /tmp/init.sh
        rm -rf /tmp/init.sh
        log_message SUCCESS "Script 2 execution completed."
    else
        log_message ERROR "Failed to download or execute script 2."
    fi
    read -p "Press Enter to continue..."
    main_menu
}

# 脚本3：Docker 环境初始化
run_script3() {
    log_message INFO "Running online script 3... Docker environment initialization"
    curl -sL https://bash.15099.net/linux/docker.sh > /tmp/docker.sh
    if [ $? -eq 0 ]; then
        bash /tmp/docker.sh
        rm -rf /tmp/docker.sh
        log_message SUCCESS "Script 3 execution completed."
    else
        log_message ERROR "Failed to download or execute script 3."
    fi
    read -p "Press Enter to continue..."
    main_menu
}

# 脚本4：安装 Portainer 图形界面
run_script4() {
    log_message INFO "Running online script 4... Install Portainer Chinese graphical interface"
    curl -sL https://bash.15099.net/linux/portainer.sh > /tmp/portainer.sh
    if [ $? -eq 0 ]; then
        bash /tmp/portainer.sh
        rm -rf /tmp/portainer.sh
        log_message SUCCESS "Script 4 execution completed."
    else
        log_message ERROR "Failed to download or execute script 4."
    fi
    read -p "Press Enter to continue..."
    main_menu
}

# 脚本5：主机压力测试
run_script5() {
    log_message INFO "Running online script 5... Host bench stress test"
    curl -sL https://bash.15099.net/linux/bench.sh > /tmp/bench.sh
    if [ $? -eq 0 ]; then
        bash /tmp/bench.sh
        rm -rf /tmp/bench.sh
        log_message SUCCESS "Script 5 execution completed."
    else
        log_message ERROR "Failed to download or execute script 5."
    fi
    read -p "Press Enter to continue..."
    main_menu
}

# 脚本6：主机 Unixbench 压力测试
run_script6() {
    log_message INFO "Running online script 6... Host unixbench stress test"
    curl -sL https://bash.15099.net/linux/unixbench.sh > /tmp/unixbench.sh
    if [ $? -eq 0 ]; then
        bash /tmp/unixbench.sh
        rm -rf /tmp/unixbench.sh
        log_message SUCCESS "Script 6 execution completed."
    else
        log_message ERROR "Failed to download or execute script 6."
    fi
    read -p "Press Enter to continue..."
    main_menu
}

# 主程序启动
clear
main_menu
