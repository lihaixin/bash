#!/bin/bash
# proxmox7初始化WIFI桥接
# curl -sSL https://tinyurl.com/proxmoxwifi | bash -x

apt install wpasupplicant parprouted iw net-tools wireless-tools iperf3
wpa_passphrase $1 $2 > /etc/wpa_supplicant/wpa_supplicant.conf

echo 'auto lo
iface lo inet loopback
#iface ens18 inet manual

#auto vmbr0
#iface vmbr0 inet static
#        address 192.168.2.107/24
#        gateway 192.168.2.254
#        bridge-ports ens18
#        bridge-stp off
#        bridge-fd 0

#add wifi interface for intel
allow-hotplug wlxc8e7d8cbf183
auto wlxc8e7d8cbf183
ifacewlxc8e7d8cbf183 inet static
        address 192.168.2.107/24
        gateway 192.168.2.254
        post-up wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlxc8e7d8cbf183
        post-up /usr/sbin/parprouted vmbr0 wlxc8e7d8cbf183
        post-down /usr/bin/killall /usr/sbin/parprouted
# wifi connet
auto vmbr0
iface vmbr0 inet static
      bridge_ports none
      address 192.168.2.107/24
# wifi bridge' > /etc/network/interfaces

echo 'auto lo
iface lo inet loopback

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
