#!/bin/bash
# https://tinyurl.com/proxmoxgui

## 安装基本包
apt install -y sudo net-tools neofetch

##添加普通用户
useradd -m pve
usermod -s /bin/bash pve
echo -e "pve\npve" | (passwd pve)
chmod u+w /etc/sudoers
echo "pve ALL=(ALL:ALL) ALL" >>/etc/sudoers
chmod u-w /etc/sudoers

##安装桌面环境
apt -y install task-xfce-desktop task-cinnamon-desktop task-chinese-s task-chinese-s-desktop task-laptop locales-all

##安装常用工具
apt -y install remmina remmina-plugin-vnc remmina-plugin-rdp chromium-l10n chromium telegram-desktop firfox 

##安装多媒体工具
apt -y install redshift gcolor3 obs-studio kdenlive audacity

##安装所有的时区信息
apt -y install locales-all
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




