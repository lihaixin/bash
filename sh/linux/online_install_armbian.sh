
# 列出所有块设备
echo "可用磁盘列表:"
lsblk -d -o NAME,SIZE,TYPE

# 请用户输入要写入的磁盘名称（例如 /dev/sdx）
read -p "请输入目标磁盘的完整路径（如 /dev/sdb）: " target_disk

# 检查磁盘是否挂载，如果挂载则尝试卸载
mounted=$(grep -c "^$target_disk" /proc/mounts)
if [ $mounted -gt 0 ]; then
    echo "警告：目标磁盘已挂载，脚本将尝试自动卸载。"
    # 尝试查找挂载点
    mount_point=$(mount | grep "$target_disk" | cut -d' ' -f3)
    if [ -n "$mount_point" ]; then
        echo "卸载挂载点: $mount_point"
        sudo umount "$mount_point" || { echo "卸载失败，请手动卸载并重试。"; exit 1; }
    else
        echo "未能确定挂载点，无法自动卸载。"
        exit 1
    fi
fi

# 确认用户输入
read -p "您确定要将选定的镜像文件写入到 $target_disk 吗？(y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "操作已取消。"
    exit 1
fi

# 检查目标设备是否存在且不是标准输入输出
if [[ ! -b $target_disk ]]; then
    echo "错误：指定的设备路径不存在或不是块设备。"
    exit 1
fi

# 镜像文件在线地址列表及大小备注
images_urls=(
    "https://dl.armbian.com/uefi-x86/Bookworm_current_server 0.7G"
    "https://dl.armbian.com/uefi-x86/Jammy_current_server 0.9G"
    "https://dl.armbian.com/uefi-x86/Noble_current_server 0.9G"
    "https://dl.armbian.com/uefi-x86/Noble_current_xfce 1.9G"
    "https://mirror.iscas.ac.cn/armbian-releases/uefi-x86/archive/Armbian_24.8.1_Uefi-x86_bookworm_current_6.6.47.img.xz 0.7G"
    "https://mirror.iscas.ac.cn/armbian-releases/uefi-x86/archive/Armbian_24.8.1_Uefi-x86_noble_current_6.6.47.img.xz 0.9G"
    "https://mirror.iscas.ac.cn/armbian-releases/uefi-x86/archive/Armbian_24.8.1_Uefi-x86_jammy_current_6.6.47.img.xz 0.9G"
)

# 显示镜像选项及其大小
echo "请选择要下载并写入的镜像文件及其大小："
for ((i=0; i<${#images_urls[@]}; i++)); do
    size=${images_urls[i]##* }
    url=${images_urls[i]% *}
    echo "$((i+1)). URL: $url, 镜像容量大小: $size 主机内存要两倍$size才能成功安装"
done

# 读取用户选择
read -p "请输入镜像编号: " choice

# 检查输入是否有效
if ((choice > 0 &&choice <= ${#images_urls[@]})); then
    url=${images_urls[$((choice-1))]% *}
    filename=/tmp/armbian.img.xz

    # 检查镜像文件是否已下载
    if [ -f "$filename" ]; then
        echo "镜像文件 $filename 已经存在本地，跳过下载。"
    else
        # 下载镜像文件
        wget -c "$url" -O "$filename"
        if [ $? -ne 0 ]; then
            echo "下载镜像文件失败。"
            exit 1
        fi
        echo "镜像文件下载完成。"
    fi
    
    # 开始执行前同步文件系统缓存
    sync
    # 执行写入操作到磁盘
    echo "正在将 $filename 写入磁盘 $target_disk，请稍候..."
    unxz -c $filename | dd of="$target_disk" bs=128K status=progress oflag=direct iflag=fullblock conv=noerror,sync | pv
    
    if [ $? -eq 0 ]; then
        echo "写入操作完成。"
    else
        echo "写入过程中发生错误。"
    fi
else
    echo "无效的输入。"
fi

# 清理下载的镜像文件（可选）
rm  $filename

# 记录操作日志（示例，实际需指定日志文件路径）
echo "$(date) - 成功将$filename写入$target_disk" >> /var/log/image_writer.log

echo "操作日志已记录，请检查系统日志以确认操作无误。"

# 注意：此脚本执行涉及磁盘级操作，务必谨慎使用，确保数据安全。
