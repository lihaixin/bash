#!/bin/bash
# curl -sSL https://15099.net/proxmox.gui | bash -x

## 安装基本包
apt install -y sudo net-tools neofetch


##添加普通用户,平常使用普通用户登陆
useradd -m pve
usermod -s /bin/bash pve
echo -e "pve\npve" | (passwd pve)
chmod u+w /etc/sudoers
echo "pve ALL=(ALL:ALL) ALL" >>/etc/sudoers
chmod u-w /etc/sudoers

##安装桌面环境
# apt -y install task-xfce-desktop task-cinnamon-desktop task-chinese-s task-chinese-s-desktop task-laptop locales-all
# apt-config dump | grep -we Recommends -e Suggests
# 默认安装推荐包，不安装建议建议包，迷你安装ba推荐包也不安装
# APT::Install-Recommends "1"; --no-install-recommends
# APT::Install-Suggests "0";
# task-xfce-desktop task-cinnamon-desktop task-laptop
# apt -y install --no-install-recommends task-cinnamon-desktop cinnamon-l10n
# 使用完整的桌面环境，网卡可以自动开机联网
# apt -y install task-cinnamon-desktop
apt -y install task-gnome-desktop
# 
apt-get -y install task-chinese-s task-chinese-s-desktop


##安装远程桌面
#apt -y update
#apt -y install xrdp
#adduser xrdp ssl-cert
#systemctl enable xrdp
#systemctl start xrdp
#systemctl status xrdp


##安装常用工具
# chromium-l10n chromium
# apt install -y remmina remmina-plugin-vnc remmina-plugin-rdp telegram-desktop firefox-esr firefox-esr-l10n-zh-cn

##安装多媒体工具
# redshift-gtk 
# apt -y install gcolor3 obs-studio kdenlive audacity shotcut

##安装所有的时区信息
apt -y install locales-all
localectl set-locale LANG=zh_CN.UTF-8
cat <<EOF >/etc/default/locale
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN.UTF-8"
LC_NUMERIC="zh_CN.UTF-8"
LC_TIME="zh_CN.UTF-8"
LC_MONETARY="zh_CN.UTF-8"
LC_PAPER="zh_CN.UTF-8"
LC_NAME="zh_CN.UTF-8"
LC_ADDRESS="zh_CN.UTF-8"
LC_TELEPHONE="zh_CN.UTF-8"
LC_MEASUREMENT="zh_CN.UTF-8"
LC_IDENTIFICATION="zh_CN.UTF-8"
EOF

##设置默认启动图像界面
systemctl set-default graphical.target 
systemctl get-default

##重启
reboot

