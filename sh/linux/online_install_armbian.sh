# List all block devices
echo "Available disk list:"
lsblk -d -o NAME,SIZE,TYPE

# Prompt user to input the target disk name (e.g., /dev/sdx)
read -p "Please enter the full path of the target disk (e.g., /dev/sdb): " target_disk

# Check if the disk is mounted, if mounted then try to unmount
mounted=$(grep -c "^$target_disk" /proc/mounts)
if [ $mounted -gt 0 ]; then
    echo "Warning: The target disk is mounted, the script will try to unmount it automatically."
    # Try to find the mount point
    mount_point=$(mount | grep "$target_disk" | cut -d' ' -f3)
    if [ -n "$mount_point" ]; then
        echo "Unmounting mount point: $mount_point"
        umount "$mount_point" || { echo "Unmount failed, please unmount manually and try again."; exit 1; }
    else
        echo "Unable to determine the mount point, cannot unmount automatically."
        exit 1
    fi
fi

# Confirm user input
read -p "Are you sure you want to write the selected image file to $target_disk? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Operation canceled."
    exit 1
fi

# Check if the target device exists and is not standard input/output
if [[ ! -b $target_disk ]]; then
    echo "Error: The specified device path does not exist or is not a block device."
    exit 1
fi

# List of image file URLs and size remarks
images_urls=(
    "https://dl.armbian.com/uefi-x86/Bookworm_current_server 0.7G"
    "https://dl.armbian.com/uefi-x86/Jammy_current_server 0.9G"
    "https://dl.armbian.com/uefi-x86/Noble_current_server 0.9G"
    "https://dl.armbian.com/uefi-x86/Noble_current_xfce 1.9G"
    "https://mirror.iscas.ac.cn/armbian-releases/uefi-x86/archive/Armbian_24.8.1_Uefi-x86_bookworm_current_6.6.47.img.xz 0.7G"
    "https://mirror.iscas.ac.cn/armbian-releases/uefi-x86/archive/Armbian_24.8.1_Uefi-x86_noble_current_6.6.47.img.xz 0.9G"
    "https://mirror.iscas.ac.cn/armbian-releases/uefi-x86/archive/Armbian_24.8.1_Uefi-x86_jammy_current_6.6.47.img.xz 0.9G"
)

# Display image options and their sizes
echo "Please select the image file to download and write, along with its size:"
for ((i=0; i<${#images_urls[@]}; i++)); do
    size=${images_urls[i]##* }
    url=${images_urls[i]% *}
    echo "$((i+1)). URL: $url, Image size: $size (Host memory should be twice the size to install successfully)"
done

# Read user choice
read -p "Please enter the image number: " choice

# Check if the input is valid
if ((choice > 0 && choice <= ${#images_urls[@]})); then
    url=${images_urls[$((choice-1))]% *}
    filename=/tmp/armbian.img.xz

    # Check if the image file is already downloaded
    if [ -f "$filename" ]; then
        echo "Image file $filename already exists locally, skipping download."
    else
        # Download the image file
        wget -c "$url" -O "$filename"
        if [ $? -ne 0 ]; then
            echo "Failed to download the image file."
            exit 1
        fi
        echo "Image file downloaded successfully."
    fi
    
    # Sync filesystem caches before starting
    sync
    # Write the image file to disk
    echo "Writing $filename to disk $target_disk, please wait..."
    unxz -c $filename | dd of="$target_disk" bs=128K status=progress oflag=direct iflag=fullblock conv=noerror,sync | pv
    
    if [ $? -eq 0 ]; then
        echo "Write operation completed."
    else
        echo "An error occurred during the write operation."
    fi
else
    echo "Invalid input."
fi

# Clean up the downloaded image file (optional)
rm $filename

# Log the operation (example, specify the actual log file path)
echo "$(date) - Successfully wrote $filename to $target_disk" >> /var/log/image_writer.log

echo "Operation log recorded, please check the system log to confirm the operation is successful."

# Note: This script involves disk-level operations, please use it with caution to ensure data safety.
