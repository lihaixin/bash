#!/bin/bash

# 打印准备安装信息
log_message INFO "Preparing to install pure Debian 12 system online..."

# 设置默认密码并提示用户输入
DEFAULT_VALUE="password"
prompt="Please enter the installation password, using the default value ($DEFAULT_VALUE) if no input within 20 seconds: "
read -t 20 -p "$prompt" PASSWORD || PASSWORD=$DEFAULT_VALUE
log_message INFO "Using installation password: $PASSWORD"

# 根据国家选择下载 URL
if [ "$COUNTRY" == "cn" ]; then
    URL="https://cnb.cool/bin456789/reinstall/-/git/raw/main/reinstall.sh"
else
    URL="https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh"
fi
log_message INFO "Selected script URL: $URL"

# 定义临时脚本路径
TEMP_SCRIPT="/tmp/online_install_debian.sh"

# 下载脚本文件
log_message INFO "Downloading the installation script..."
if ! curl -o "$TEMP_SCRIPT" "$URL" && ! wget -O "$TEMP_SCRIPT" "$URL"; then
    log_message ERROR "Failed to download the script. Exiting."
    exit 1
fi
log_message SUCCESS "Installation script downloaded successfully."

# 执行安装脚本
log_message INFO "Executing the installation script..."
bash "$TEMP_SCRIPT" debian12
if [ $? -eq 0 ]; then
    log_message SUCCESS "Debian 12 installation script executed successfully."
else
    log_message ERROR "An error occurred while executing the installation script."
    exit 1
fi

# 删除临时脚本文件
rm -f "$TEMP_SCRIPT"
log_message INFO "Temporary installation script removed."
