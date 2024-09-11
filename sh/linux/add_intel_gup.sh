# 宿主机
apt-get update &&sudo apt-get install mesa-utils

##找到Intel核显的Vendor和Device ID
lspci -nn | grep -i 'VGA' | grep -i intel
这条命令会列出与Intel相关的显示设备信息，从中您可以找到类似于Vendor: XXYY和Device ZZWW的行，其中XXYY是Vendor ID，ZZWW是Device ID。例如，Intel的常见Vendor ID是8086。

## 备份GRUB配置文件在进行任何修改之前，先备份现有的GRUB配置文件是一个好习惯。通常GRUB配置文件位于/etc/default/grub。执行以下命令进行备份：

cp /etc/default/grub /etc/default/grub.backup

## 编辑GRUB配置文件接下来，使用文本编辑器编辑GRUB配置文件。这里以nano为例：

nano /etc/default/grub
bash在文件中找到以GRUB_CMDLINE_LINUX_DEFAULT开头的行。在这行的末尾添加intel_iommu=on以启用IOMMU，并根据之前查找到的信息添加pci-stub.ids=XX:YY:ZZ:WW，其中XX:YY:ZZ:WW应替换为您实际查找到的Vendor ID和Device ID。例如，如果Vendor ID是8086，Device ID是1234，则添加：GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on pci-stub.ids=8086:1234"

##更新GRUB配置并重启系统保存并关闭文件后，更新GRUB以应用更改：

update-grub

## 重启计算机使更改生效：

reboot
## 验证更改重启后，您可以通过检查dmesg输出来验证IOMMU是否已启用，以及GPU是否被预留给了pci-stub驱动：

dmesg | grep -e DMAR -e pci-stub

1. DMAR 相关输出：确认IOMMU（Intel的Direct Memory Access Remapping，即直接内存访问重映射）是否启用。成功的输出应该包含类似以下的行，表明系统支持并已启用IOMMU功能：[    0.000000] DMAR: DMA remapping enabled with IRQL_not_less_or_equal emulation
󠁪或者[    0.000000] Intel-IOMMU: enabled
󠁪2. pci-stub.ids 相关输出（如果有配置）：如果您之前按照步骤为特定设备配置了pci-stub以预留GPU或其他设备，那么输出中还应该能看到pci-stub模块加载并成功预留设备的信息，类似于：[    7.558997] pci-stub 0000:00:02.0: claimed by stub
󠁪其中 0000:00:02.0 是一个示例PCI地址，表示pci-stub模块已经接管了这个设备。

## 容器调用

docker run -v /dev/dri:/dev/dri glxgears-image

FROM ubuntu:latest
RUN apt-get update &&\
    apt-get install -y intel-opencl-icd ocl-icd-libopencl1 opencl-headers clinfo &&\
    rm -rf /var/lib/apt/lists/*
CMD ["clinfo"] # 或者其他测试GPU的命令


docker build -t my-intel-gpu-test .
docker run --device=/dev/dri:/dev/dri my-intel-gpu-test

运行 clinfo：在已经配置好并运行了支持OpenCL的容器中，执行 clinfo 命令。2. 检查输出信息：观察 clinfo 的输出，寻找与GPU相关的信息。如果GPU已被成功直通，您应该能看到类似于以下的输出段落，其中列出了OpenCL平台和设备的详细信息：Platform ID #0
  Name          Intel(R) OpenCL HD Graphics
  Vendor        Intel(R) Corporation
  Version       OpenCL 2.1 
  ...
  Devices:
    Device ID #0
      Type                     GPU
      Name              Intel(R) UHD Graphics [0xXXXX]
      ...
text特别注意 Type 行，如果显示为 GPU，则表明找到了一个GPU设备。3. 确认设备匹配：确认列出的GPU设备与宿主机上的核显型号相匹配。可以通过在宿主机上同样运行 clinfo 来比较信息。
