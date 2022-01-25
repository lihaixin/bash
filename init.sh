#!/bin/sh
# proxmox7初始化设置

##调整仓库源
sed -i 's|deb|# deb|g' /etc/apt/sources.list.d/pve-enterprise.list

cat >/etc/apt/sources.list << TEMPEOF 
deb http://mirrors.ustc.edu.cn/debian bullseye main contrib
deb http://mirrors.ustc.edu.cn/debian bullseye-updates main contrib
deb https://mirrors.ustc.edu.cn/proxmox/debian bullseye pve-no-subscription
deb https://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib
TEMPEOF

cp /usr/share/perl5/PVE/APLInfo.pm /usr/share/perl5/PVE/APLInfo.pm_back
sed -i 's|http://download.proxmox.com|https://mirrors.ustc.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm

## 升级到最新
apt-get -y update && apt-get -y upgrade

##删除订阅提醒
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service

##调整内核参数
### 开启内核转发
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
# 开启物理内存剩余10%才开始调用虚拟内存
echo "vm.swappiness=10" >> /etc/sysctl.conf

###优先使用ipv4
sed -i s'/precedence ::ffff:0:0/96 100/#precedence ::ffff:0:0/96 100/g' /etc/gai.conf
#### 保存运行下面命令生效

sysctl -p

##调整内核启动加载参数
##sed -i s'/zfsroot/zfsroot consoleblank=300 intel_iommu=on iommu=pt/g' /etc/kernel/cmdline

## proxmox-boot-tool refresh

##调整模块加载 
echo vfio >> /etc/modules
echo vfio_iommu_type1 >> /etc/modules
echo vfio_pci >> /etc/modules
echo vfio_virqfd >> /etc/modules

##cpu频率调优
cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
echo "schedutil" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
exit 0
EOF

chmod +x /etc/rc.local
systemctl start rc-local

