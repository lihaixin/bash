# proxmox
proxmox笔记

# 取消绑定

```
echo "0000:03:00.0" > /sys/bus/pci/drivers/vfio-pci/unbind
echo "0000:03:00.1" > /sys/bus/pci/drivers/vfio-pci/unbind
echo "0000:03:00.1" > /sys/bus/pci/drivers/vfio-pci/bind
echo "0000:03:00.0" > /sys/bus/pci/drivers/vfio-pci/bind
```

video=vesafb:off video=efifb:off ：禁止启动和vesa驱动和efi启动的显卡
