#!/bin/bash
# 打印准备安装信息
log_message INFO "Preparing to install iKuai router system online..."
log_message INFO "Current host memory size (MB): $MEM_TOTAL"

# 判断内存大小并选择下载对应架构的 iKuai 系统镜像
if [ "$MEM_TOTAL" -lt 2024 ]; then
    log_message WARNING "Current host memory is less than 2G. Choosing x32 architecture for iKuai system."
    wget https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x32_3.6.13_Build202301131532.iso -O /tmp/ikuai8.iso
    if [ $? -eq 0 ]; then
        log_message SUCCESS "Successfully downloaded iKuai x32 ISO."
    else
        log_message ERROR "Failed to download iKuai x32 ISO."
        exit 1
    fi
else
    log_message INFO "Current host memory is greater than 2G. Choosing x64 architecture for iKuai system."
    wget https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x64_3.6.13_Build202301131532.iso -O /tmp/ikuai8.iso
    if [ $? -eq 0 ]; then
        log_message SUCCESS "Successfully downloaded iKuai x64 ISO."
    else
        log_message ERROR "Failed to download iKuai x64 ISO."
        exit 1
    fi
fi

# 挂载镜像到 /mnt
log_message INFO "Mounting iKuai ISO to /mnt..."
mount -o loop /tmp/ikuai8.iso /mnt
if [ $? -eq 0 ]; then
    log_message SUCCESS "Successfully mounted iKuai ISO."
else
    log_message ERROR "Failed to mount iKuai ISO."
    exit 1
fi

# 拷贝 boot 文件到根目录
log_message INFO "Copying boot files to the root directory..."
cp -rpf /mnt/boot /
if [ $? -eq 0 ]; then
    log_message SUCCESS "Successfully copied boot files."
else
    log_message ERROR "Failed to copy boot files."
    exit 1
fi

# 提示重启选项
log_message INFO "Preparing to reboot. Please open the VNC interface on the cloud host operation page of Tencent Cloud or Alibaba Cloud."

DEFAULT_VALUE="N"
prompt="Please enter Y/N. If no input within 10 seconds, the default value (N) will be used: "

# 等待用户输入
read -t 10 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}

if [ "$USER_INPUT" = "Y" ]; then
    log_message INFO "Rebooting system..."
    reboot
elif [ "$USER_INPUT" = "N" ]; then
    log_message INFO "Returning to main menu..."
    # 假设 main_menu 是一个可以执行的脚本或命令
    sub_main_menu
else
    log_message WARNING "Invalid input. Please enter Y or N."
fi
