#!/bin/bash
if [ -d /sys/class/net/eth0 ] && [ ! -d /sys/class/net/eth1 ]; then
    # 首次运行，后续不运行
    if [ ! -f "/etc/mnt/data/wanip" ]; then
      echo "wanip 文件不存在，正在创建..." > /etc/mnt/data/wanip
    else
      exit 0
    fi
    echo "条件满足：eth0 存在，eth1 不存在。"
    # 1. 删除lan1上的静态IP
    ip addr del 192.168.9.1/24 dev lan1 2>/dev/null
    ip addr del 192.168.1.1/24 dev lan1 2>/dev/null
    
    
    # 2. 用udhcpc后台获取IP
    udhcpc -i lan1 -p /var/run/udhcpc.lan1.pid -s /usr/ikuai/script/utils/udhcpc.sh &
    sleep 5  # 等待几秒让udhcpc分配到IP
    
    # 3. 获取lan1当前IP地址和网关
    
    ip_info=$(ip -4 addr show lan1 | awk '/inet / {print $2; exit}')
    gateway=$(ip route show dev lan1 | awk '/default/ {print $3; exit}')
    
    echo "lan1分配到的IP信息:"
    echo "IP地址和掩码: $ip_info"
    echo "网关: $gateway"
    
    # 4. 杀掉 udhcpc 进程
    pidfile="/var/run/udhcpc.lan1.pid"
    if [ -f "$pidfile" ]; then
        kill $(cat $pidfile)
        rm -f $pidfile
    fi
    
    # 6. 解绑LAN1网卡
    /bin/bash /etc/ikcommon /usr/ikuai/script/lan.sh del_band id=1
    brctl show
    
    # 7. 把获取到的IP和掩码、网关绑定到eth0
    if [ -n "$ip_info" ]; then
        ip addr add $ip_info dev eth0
        echo "已绑定IP $ip_info 到eth0"
    fi
    if [ -n "$gateway" ]; then
        ip route add default via $gateway dev eth0
        echo "已设置eth0网关: $gateway"
    fi
    
    # 8. 输出eth0当前IP和网关
    echo "eth0当前地址信息："
    ip addr show eth0
    echo "eth0路由信息："
    ip route show dev eth0
    
else
    echo "爱快有多张网卡eth0"
fi

    
