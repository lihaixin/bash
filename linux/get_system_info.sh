 echo "获取系统信息中..."

    # 获取公网IP地址
    IP=$(curl -s https://api.ipify.org)
    echo "IP地址: $IP"

    # 获取IP所属国家，这里使用ip-api.com作为示例，需确保符合使用条款
    COUNTRY=$(curl -s http://ip-api.com/json/$IP | jq -r '.country')
    echo "IP所属国家: $COUNTRY"

    # 获取内存大小
    MEM_INFO=$(free -m)
    MEM_TOTAL=$(echo "$MEM_INFO" | grep Mem | awk '{print $2}')
    echo "内存大小(MB): $MEM_TOTAL"

    # 获取磁盘总大小，这里以根目录为例
    DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    echo "磁盘大小: $DISK_TOTAL"

    # 检测是否为虚拟机，此处简化处理，仅检测常见的虚拟化平台标识文件
    if [ -f "/sys/class/dmi/id/product_name" ]; then
        VIRTUAL_PLATFORM=$(cat /sys/class/dmi/id/product_name)
        echo "虚拟平台: 是 ($VIRTUAL_PLATFORM)"
    else
        echo "虚拟平台: 否"
    fi
    echo "脚本1执行完毕，按回车键继续。"
    read
    main_menu
