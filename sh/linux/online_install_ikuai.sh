#!/bin/bash
echo "准备在线灌ikuai路由系统"
echo "当前主机内存大小(MB): $MEM_TOTAL"
if [ "$MEM_TOTAL" -lt 2024 ]; then
    echo "当前主机内存小于2G,爱快系统架构选择x32"
    wget https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x32_3.7.14_Build202408011011.iso -O /tmp/ikuai8.iso
else
    echo "当前主机内存大于2G，爱快系统架构选择x64"
    wget https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x64_3.7.14_Build202408011011.iso -O /tmp/ikuai8.iso
fi


echo "挂载磁盘"
mount -o loop /tmp/ikuai8.iso /mnt
echo "复制文件到根目录"
cp -rpf /mnt/boot /

echo "准备重启，然后在腾讯云&阿里云的等云主机操作页面打开VNC界面"
DEFAULT_VALUE="N"
prompt="请输入内容Y/N，10秒内无输入将采用默认值(Y): "

# 使用read的-t选项及命令替换特性
read -t 10 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}

if [ "$USER_INPUT" = "Y" ]; then
    echo "正在重启系统..."
    reboot
elif [ "$USER_INPUT" = "N" ]; then
    echo "返回主菜单..."
    # 这里假设main_menu是一个可执行脚本或命令
    sub_main_menu
else
    echo "无效的输入，请输入 Y 或 N"
fi
