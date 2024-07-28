#!/bin/bash

# 列出所有块设备
echo "可用磁盘列表:"
lsblk -d -o NAME,SIZE,TYPE

# 请用户输入要写入的磁盘名称（例如 /dev/sdx）
read -p "请输入目标磁盘的完整路径（如 /dev/sdb）: " target_disk

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

# 镜像文件在线地址列表
images_urls=(
    "http://example.com/mirror1.iso"
    "http://example.com/mirror2.iso"
    "http://example.com/mirror3.iso"
)

# 显示镜像选项
echo "请选择要下载并写入的镜像文件："
for ((i=0; i<${#images_urls[@]}; i++)); do
    echo "$((i+1)). ${images_urls[i]}"
done

# 读取用户选择
read -p "请输入镜像编号: " choice

# 检查输入是否有效
if ((choice > 0 &&choice <= ${#images_urls[@]})); then
    url=${images_urls[$((choice-1))]}
    
    # 下载镜像文件
    filename=$(basename "$url")
    wget -c "$url" -O "$filename"
    
    if [ $? -eq 0 ]; then
        echo "镜像文件下载完成。"
        
        # 执行写入操作到磁盘
        echo "正在将 $filename 写入磁盘 $target_disk，请稍候..."
        sudo dd if="$filename" of="$target_disk" bs=4M status=progress oflag=direct conv=fdatasync
        
        if [ $? -eq 0 ]; then
            echo "写入操作完成。"
        else
            echo "写入过程中发生错误。"
        fi
    else
        echo "下载镜像文件失败。"
    fi
else
    echo "无效的输入。"
fi

# 清理下载的镜像文件（可选）
# rm "$filename"

# 注意：此脚本执行涉及磁盘级操作，务必谨慎使用，确保数据安全。
