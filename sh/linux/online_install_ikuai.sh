#!/bin/bash
echo "Preparing to install iKuai router system online"
echo "Current host memory size (MB): $MEM_TOTAL"
if [ "$MEM_TOTAL" -lt 2024 ]; then
    echo "Current host memory is less than 2G, choosing x32 architecture for iKuai system"
    wget https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x32_3.6.13_Build202301131532.iso -O /tmp/ikuai8.iso
else
    echo "Current host memory is greater than 2G, choosing x64 architecture for iKuai system"
    wget https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x64_3.6.13_Build202301131532.iso -O /tmp/ikuai8.iso
fi

echo "Mounting disk"
mount -o loop /tmp/ikuai8.iso /mnt
echo "Copying files to root directory"
cp -rpf /mnt/boot /

echo "Preparing to reboot, then open the VNC interface on the cloud host operation page of Tencent Cloud & Alibaba Cloud"
DEFAULT_VALUE="N"
prompt="Please enter Y/N, if no input within 10 seconds, the default value (N) will be used: "

# Use the -t option of read and command substitution feature
read -t 10 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}

if [ "$USER_INPUT" = "Y" ]; then
    echo "Rebooting system..."
    reboot
elif [ "$USER_INPUT" = "N" ]; then
    echo "Returning to main menu..."
    # Assuming main_menu is an executable script or command
    sub_main_menu
else
    echo "Invalid input, please enter Y or N"
fi
