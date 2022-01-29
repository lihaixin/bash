#!/bin/bash
# proxmox7初始化WIFI桥接
# 使用NetworkManager管理wifi链接和使用networking管理wifi 桥接
# curl -sSL https://tinyurl.com/proxmoxwifi2 | bash -x

# 根据自己的网络修改下面变量

WIFI_INTERFACE=wlxc8e7d8cbf183
IPADDRESS=192.168.2.107/24
DHCPSERVER=192.168.2.254


# 启用内核转发
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# 安装无线链接需要的包
apt install -y wpasupplicant  iw net-tools wireless-tools iperf3 

apt install -y parprouted

DEBIAN_FRONTEND=noninteractive apt -y install isc-dhcp-relay
## 关闭dhcp中继
/lib/systemd/systemd-sysv-install disable isc-dhcp-relay
##------------------------------------------------------------------------------------------------
# 第二种方式
cat <<EOF >/etc/network/interfaces
auto lo
iface lo inet loopback

auto vmbr0
iface vmbr0 inet static
      bridge_ports none
      address $IPADDRESS

#wifi bridge

EOF

cat <<EOF >/etc/network/if-up.d/networking.sh
#!/bin/sh
/usr/sbin/parprouted vmbr0 $WIFI_INTERFACE
/usr/sbin/dhcrelay -q $DHCPSERVER
EOF

cat <<EOF >/etc/network/if-down.d/networking.sh
#!/bin/sh
/usr/bin/killall /usr/sbin/parprouted
/usr/bin/killall /usr/sbin/dhcrelay
EOF

chmod +x /etc/network/if-up.d/networking.sh
chmod +x /etc/network/if-down.d/networking.sh
