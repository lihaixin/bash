#!/bin/bash

# 定义颜色
RED='\033[0;31m'    # 错误或警告信息
GREEN='\033[0;32m'  # 成功信息
YELLOW='\033[0;33m' # 警告或提示信息
BLUE='\033[0;34m'   # 一般信息
CYAN='\033[0;36m'   # 时间戳或强调信息
NC='\033[0m'        # 重置颜色

# 日志输出函数（带时间戳和类别）
log_message() {
    local type=$1    # 日志类别：INFO, SUCCESS, WARNING, ERROR
    local message=$2 # 日志内容

    case $type in
        INFO)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${BLUE}[INFO]${NC} $message"
            ;;
        SUCCESS)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}[SUCCESS]${NC} $message"
            ;;
        WARNING)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}[WARNING]${NC} $message"
            ;;
        ERROR)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}[ERROR]${NC} $message"
            ;;
        *)
            echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ${NC}$message"
            ;;
    esac
}

# 打印可用磁盘列表
log_message INFO "Available disk list:"
lsblk -d -o NAME,SIZE,TYPE

# 提示用户输入目标磁盘的路径
read -p "Please enter the full path of the target disk (e.g., /dev/sdb): " target_disk

# 检查目标磁盘是否已挂载，如果已挂载则尝试卸载
mounted=$(grep -c "^$target_disk" /proc/mounts)
if [ $mounted -gt 0 ]; then
    log_message WARNING "The target disk is mounted. The script will try to unmount it automatically."
    mount_point=$(mount | grep "$target_disk" | cut -d' ' -f3)
    if [ -n "$mount_point" ]; then
        log_message INFO "Unmounting mount point: $mount_point"
        umount "$mount_point" || { log_message ERROR "Unmount failed. Please unmount manually and try again."; exit 1; }
    else
        log_message ERROR "Unable to determine the mount point. Cannot unmount automatically."
        exit 1
    fi
fi

# 确认用户输入
read -p "Are you sure you want to write the selected image file to $target_disk? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    log_message WARNING "Operation canceled by the user."
    exit 1
fi

# 检查目标设备是否存在
if [[ ! -b $target_disk ]]; then
    log_message ERROR "The specified device path does not exist or is not a block device."
    exit 1
fi

# 显示镜像文件选项及大小
images_urls=(
    "https://dl.armbian.com/uefi-x86/Bookworm_current_xfce 2.1G"
    "https://dl.armbian.com/uefi-x86/Noble_current_server 0.9G"
    "https://dl.armbian.com/uefi-x86/Noble_current_xfce 1.9G"
    "https://dl.armbian.com/uefi-x86/Noble_cloud_minimal-qcow2 0.7G"
    "https://dl.armbian.com/uefi-x86/Bookworm_cloud_minimal-qcow2 0.6G"
)

log_message INFO "Please select the image file to download and write, along with its size:"
for ((i=0; i<${#images_urls[@]}; i++)); do
    size=${images_urls[i]##* }
    url=${images_urls[i]% *}
    log_message INFO "$((i+1)). URL: $url, Image size: $size (Host memory should be twice the size to install successfully)"
done

# 读取用户选择
read -p "Please enter the image number: " choice

# 验证用户输入
if ((choice > 0 && choice <= ${#images_urls[@]})); then
    url=${images_urls[$((choice-1))]% *}
    filename=/tmp/armbian.img.xz

    # 检查镜像文件是否已经下载
    if [ -f "$filename" ]; then
        log_message INFO "Image file $filename already exists locally. Skipping download."
    else
        log_message INFO "Downloading the image file..."
        wget -c "$url" -O "$filename"
        if [ $? -ne 0 ]; then
            log_message ERROR "Failed to download the image file."
            rm -rf /tmp/armbian.img.xz
            exit 1
        fi
        log_message SUCCESS "Image file downloaded successfully."
    fi

    # 写入镜像文件到目标磁盘
    sync
    log_message INFO "Writing $filename to disk $target_disk, please wait..."
    unxz -c $filename | dd of="$target_disk" bs=128K status=progress oflag=direct iflag=fullblock conv=noerror,sync
    if [ $? -eq 0 ]; then
        log_message SUCCESS "Write operation completed."
    else
        log_message ERROR "An error occurred during the write operation."
    fi
else
    log_message ERROR "Invalid input. Operation aborted."
fi

# 清理下载的镜像文件（可选）
rm -f $filename
log_message INFO "Temporary image file removed."

# 记录日志
echo "$(date) - Successfully wrote $filename to $target_disk" >> /var/log/image_writer.log
log_message SUCCESS "Operation log recorded. Please check the system log to confirm the operation is successful."
