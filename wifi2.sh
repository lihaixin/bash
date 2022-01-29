#!/bin/bash
# proxmox7初始化WIFI桥接
# curl -sSL https://tinyurl.com/proxmoxwifi | bash -x

# 根据自己的网络修改下面变量
WIFI_ESSID=406_2.4G
WIFI_PASSWD=*
WIFI_INTERFACE=wlxc8e7d8cbf183
IPADDRESS=192.168.2.107/24
DHCPSERVER=192.168.2.254
GATEWAY=192.168.2.254

# 启用内核转发
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# 安装无线链接需要的包
apt install wpasupplicant  iw net-tools wireless-tools iperf3 

apt install parprouted

DEBIAN_FRONTEND=noninteractive apt install isc-dhcp-relay

##------------------------------------------------------------------------------------------------
# 第二种方式
echo 'auto lo
iface lo inet loopback
# 使用NetworkManager管理wifi链接和使用networking管理wifi
#iface ens18 inet manual
#auto vmbr0
#iface vmbr0 inet static
#        address 192.168.2.107/24
#        gateway 192.168.2.254
#        bridge-ports ens18
#        bridge-stp off
#        bridge-fd 0
auto vmbr0
iface vmbr0 inet static
      bridge_ports none
      address $IPADDRESS
      post-up /usr/sbin/parprouted vmbr0 $WIFI_INTERFACE
      post-up /usr/sbin/dhcrelay -q $DHCPSERVER
      post-down /usr/bin/killall /usr/sbin/parprouted
      post-down /usr/bin/killall /usr/sbin/dhcrelay
 wifi bridge' > /etc/network/interfaces

echo '#!/bin/sh
systemctl restart networking' >/etc/network/if-up.d/networking.sh

chmod +x /etc/network/if-up.d/networking.sh




