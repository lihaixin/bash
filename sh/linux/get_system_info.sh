 echo "获取系统信息中..."

    # 获取公网IP地址
    export WANIP=""
    [[ -z $WANIP ]] &&WANIP=$(curl --max-time 5 -s https://ipinfo.io/ip)
    [[ -z $WANIP ]] &&WANIP=$(curl --max-time 5 -s https://api.ipify.org)
    [[ -z $WANIP ]] &&WANIP=$(curl --max-time 5 -s https://ifconfig.co/ip)
    [[ -z $WANIP ]] &&WANIP=$(curl --max-time 5 -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
    [[ -z $WANIP ]] &&WANIP=$(curl --max-time 5 -s icanhazip.com)
    [[ -z $WANIP ]] &&WANIP=$(curl --max-time 5 -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
    [[ -z $WANIP ]] &&printecho 3 "Container network is not working!" &&exit
    echo "IP地址: $WANIP"

    # 获取IP所属国家，这里使用ipinfo.io和ipapi.co作为示例，需确保符合使用条款
    export COUNTRY=""
    COUNTRY=$(curl --max-time 5 ipinfo.io/country  2>/dev/null || curl --max-time 5 https://ipapi.co/country 2>/dev/null)
    COUNTRY=`echo $COUNTRY | tr A-Z a-z`
    echo "IP所属国家: $COUNTRY"

    # 获取内存大小
    export MEM_INFO=""
    MEM_INFO=$(free -m)
    MEM_TOTAL=$(echo "$MEM_INFO" | grep Mem | awk '{print $2}')
    echo "内存大小(MB): $MEM_TOTAL"

    # 获取磁盘总大小，这里以根目录为例
    export DISK_TOTAL=""
    DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    echo "磁盘大小: $DISK_TOTAL"

    # 检测是否为虚拟机，此处简化处理，仅检测常见的虚拟化平台标识文件
    export VIRTUAL_PLATFORM=""
    if [ -f "/sys/class/dmi/id/product_name" ]; then
        VIRTUAL_PLATFORM=$(cat /sys/class/dmi/id/product_name)
        VIRTUAL_PLATFORM="是 $VIRTUAL_PLATFORM " 
        echo "虚拟平台: $VIRTUAL_PLATFORM " 
    else
        VIRTUAL_PLATFORM="否 物理机"
        echo "虚拟平台: $VIRTUAL_PLATFORM "
    fi
    
    echo "脚本1执行完毕，按回车键继续。"
    read
    main_menu
