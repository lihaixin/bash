#!/bin/bash
# 主菜单函数
# 提供用户操作选项
main_menu() {
    clear
    log_message INFO "Displaying the main menu..."
    log_message INFO "##################################################################################"
    log_message INFO "#   Welcome to https://bash.15099.net Script Management System                   "
    log_message INFO "#   This program only supports debian | ubuntu | armbian | alpine                "
    log_message INFO "#   Is the host a virtual platform: $VIRTUAL_PLATFORM  System: $OS               "
    log_message INFO "#   Host memory size (MB): $MEM_TOTAL Disk size: $DISK_TOTAL                     "
    log_message INFO "#   Host IP address: $WANIP        IP country: $COUNTRY                          "
    log_message INFO "##################################################################################"
    log_message INFO "Please select an option:"
    log_message INFO "1) Online system replacement | Change Linux version, one-click install OS on physical machine"
    log_message INFO "2) Linux initialization | Upgrade, repo, timezone, time, hostname, etc."
    log_message INFO "3) Docker environment initialization | Version, proxy, log settings, etc."
    log_message INFO "4) Install Portainer Chinese graphical interface"
    log_message INFO "5) Host bench stress test | Disk, network speed test"
    log_message INFO "6) Host unixbench stress test | CPU, memory test"
    log_message INFO "0) Exit the bash"

    read_with_message "Enter option: " choice
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
    # read -p "Press Enter to continue..."
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
    # read -p "Press Enter to continue..."
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
    # read -p "Press Enter to continue..."
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
    # read -p "Press Enter to continue..."
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
    # read -p "Press Enter to continue..."
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
    # read -p "Press Enter to continue..."
    main_menu
}

# 主程序启动
clear
main_menu
