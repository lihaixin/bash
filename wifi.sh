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

#启用内核转发
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

#安装无线链接需要的包
apt install wpasupplicant parprouted iw net-tools wireless-tools iperf3 isc-dhcp-relay
wpa_passphrase $WIFI_ESSID $WIFI_PASSWD > /etc/wpa_supplicant/wpa_supplicant.conf

#
echo 'auto lo
iface lo inet loopback
# 使用networking服务管理wifi静态链接和wifi桥接
#iface ens18 inet manual

#auto vmbr0
#iface vmbr0 inet static
#        address 192.168.2.107/24
#        gateway 192.168.2.254
#        bridge-ports ens18
#        bridge-stp off
#        bridge-fd 0

#add wifi interface for intel
allow-hotplug $WIFI_INTERFACE
auto $WIFI_INTERFACE
ifacewlxc8e7d8cbf183 inet static
        address $IPADDRESS
        gateway $GATEWAY
        post-up wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i $WIFI_INTERFACE
        post-up /usr/sbin/parprouted vmbr0 $WIFI_INTERFACE
        post-up /usr/sbin/dhcrelay -q $DHCPSERVER
        post-down /usr/bin/killall /usr/sbin/parprouted
        post-down /usr/bin/killall /usr/sbin/dhcrelay
# wifi connet
auto vmbr0
iface vmbr0 inet static
      bridge_ports none
      address $IPADDRESS
# wifi bridge' > /etc/network/interfaces

##关闭NetworkManager
systemctl disable NetworkManager
## 关闭dhcp中继
/lib/systemd/systemd-sysv-install disable isc-dhcp-relay

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
      address 192.168.2.107/24
      post-up /usr/sbin/parprouted vmbr0 wlxc8e7d8cbf183
      post-down /usr/bin/killall /usr/sbin/parprouted
# wifi bridge' > /etc/network/interfaces

/etc/network/if-up.d/ARP.sh
#!/bin/sh
if [ "$IFACE" = wlxc8e7d8cbf183 ]; then
        /usr/sbin/parprouted vmbr0 wlxc8e7d8cbf183
        exit 0
fi


/etc/network/if-down.d/ARP.sh
#!/bin/sh
if [ "$IFACE" = wlxc8e7d8cbf183 ]; then
        /usr/bin/killall /usr/sbin/parprouted
        exit 0
fi



