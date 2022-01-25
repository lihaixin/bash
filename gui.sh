#!/bin/bash

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
apt install remmina remmina-plugin-vnc remmina-plugin-rdp chromium-l10n chromium telegram-desktop firfox 
