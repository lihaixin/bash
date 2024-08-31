wget https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x32_3.7.5_Build202308021413.iso -O ikuai8.iso
wget https://www.ikuai8.com/download.php?n=/3.x/iso/iKuai8_x64_3.7.12_Build202406112125.iso -O ikuai8.iso
步骤2: 挂载ISO镜像

mount -o loop ikuai8.iso /mnt

 

步骤3: 复制ISO镜像启动文件

cp -rpf /mnt/boot /

 

步骤4: 输入重启

reboot
