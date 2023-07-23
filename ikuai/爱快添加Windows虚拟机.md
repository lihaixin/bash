# 爱快添加Windows虚拟机

引言：爱快虚拟机功能，如果是物理机上安装爱快，而机器还有剩余资源可以利用，可以安装早期的windows7/windows10 作为远程打印机（钉钉远程打印支持手机打印）、下载机使用。

1.  创建windows模板（可选）可以直接跳过此步，从百度云下载已经创建好的模板上传到爱快磁盘文件夹里,如果需要自己创建模板，操作如下：
    

挂在/F/kvm到容器里，运行lihaixin/toolbox容器，然后在里面下载模板和调整磁盘大小，原始模板来源：[https://odc.cxthhhhh.com/](https://odc.cxthhhhh.com/)

    # win10模板
    ## 下载模板到容器里
    wget https://odc.cxthhhhh.com/d/SyStem/Windows_DD_Disks/Historical_File_Windows_DD_Disk/Disk_Windows_10_x64_Lite_by_CXT_v1.0.vhd.gz
    ## 解压模板磁盘文件
    gunzip -d Disk_Windows_10_x64_Lite_by_CXT_v1.0.vhd.gz
    ## 查看磁盘文件信息
    qemu-img info Disk_Windows_10_x64_Lite_by_CXT_v1.0.vhd
    ## 转化磁盘文件raw格式到qcow2,此类文件减少存储空间
    qemu-img convert -f raw -O qcow2 Disk_Windows_10_x64_Lite_by_CXT_v1.0.vhd Disk_Windows_10_x64_Lite_by_CXT_v1.0.qcow2
    ## 扩充磁盘空间，增加30G
    qemu-img resize Disk_Windows_10_x64_Lite_by_CXT_v1.0.qcow2 +30G
    ## 删除原vhd文件
    rm -rf Disk_Windows_10_x64_Lite_by_CXT_v1.0.vhd
    
    # win7模板
    wget https://odc.cxthhhhh.com/d/SyStem/Windows_DD_Disks/Historical_File_Windows_DD_Disk/Disk_Windows_7_Vienna_Ultimate_CN_v2.0.vhd.gz
    gunzip -d Disk_Windows_7_Vienna_Ultimate_CN_v2.0.vhd.gz
    qemu-img info Disk_Windows_7_Vienna_Ultimate_CN_v2.0.vhd
    qemu-img convert -f raw -O qcow2 Disk_Windows_7_Vienna_Ultimate_CN_v2.0.vhd Disk_Windows_7_Vienna_Ultimate_CN_v2.0.qcow2
    qemu-img resize Disk_Windows_7_Vienna_Ultimate_CN_v2.0.qcow2 +30G
    rm -rf Disk_Windows_7_Vienna_Ultimate_CN_v2.0.vhd
    
    # 使用类似的方法，可以快速创建windows2016 2022等服务器模板

2.  上传虚拟机模板到爱快磁盘
    

> 模板文件名称：Disk\_Windows\_10\_x64\_Lite\_by\_CXT\_v1.0.qcow2

> 模板下载地址： [https://pan.baidu.com/s/1a5euAQf4GQUSpt46gGU8Nw?pwd=5uyu](https://pan.baidu.com/s/1a5euAQf4GQUSpt46gGU8Nw?pwd=5uyu)

> 系统：Windows\_10\_x64

> 磁盘空间：35G

> 网卡：dhcp动态分配

> ssh： 账号：administrator 密码：cxthhhhhh.com 远程控制端口：8839

> 模板文件名称：Disk\_Windows\_7\_Vienna\_Ultimate\_CN\_v2.0.qcow2

> 模板下载地址： [https://pan.baidu.com/s/1M39dTPQiEe-U5aV20aFT9Q?pwd=mvft](https://pan.baidu.com/s/1M39dTPQiEe-U5aV20aFT9Q?pwd=mvft) 

> 系统：Windows\_7\_x64

> 磁盘空间：35G

> 网卡：dhcp动态分配

> ssh： 账号：administrator 密码：cxthhhhhh.com 远程控制端口：8839

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/1X3lEkxJwedAqJbv/img/7ade65ac-b5b7-404e-951c-a65548097f74.png)

3.  添加虚拟机配置，这里以windows 10为例
    

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/1X3lEkxJwedAqJbv/img/05230404-5e2e-4a4d-9dc2-e8d50e81a80b.png)

4.  登录vnc查看,默认账号administrator密码为：cxthhhhhh.com 动态分配的IP，使用ifconfig命令
    

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/1X3lEkxJwedAqJbv/img/6cde4ed8-82b4-4911-b777-dd5413264984.png)

5.  通过爱快DHCP分配列表添加静态分配
    

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/1X3lEkxJwedAqJbv/img/105409b4-2ff9-4463-9c13-74655d67df8c.png)

6.  自定义分配IP和主机名（标识）
    

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/1X3lEkxJwedAqJbv/img/ff074cb5-d7a5-49f9-b14e-58618dcddac0.png)

7.  扩展C盘空间，
    

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/1X3lEkxJwedAqJbv/img/d9d64056-4882-4335-9c02-7f1dd8e3973b.png)

8.  添加额外磁盘（可选）如果需要额外空间，请在爱快虚拟机额外添加磁盘，然后再在主机里扩展
    

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/1X3lEkxJwedAqJbv/img/8899209a-cdaa-476b-9052-f6cd40f2d8d3.png)

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/1X3lEkxJwedAqJbv/img/36af20c7-b3ef-42e3-9f65-ba7a2f99381d.png)

9.  重启主机，就可以使用远程桌面访问了
    

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/1X3lEkxJwedAqJbv/img/71795f3a-8abe-4513-adf9-a3e315eee2f7.png)
