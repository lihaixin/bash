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
