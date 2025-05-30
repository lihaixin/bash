#!/bin/bash
export TERM=xterm-256color
# 定义颜色
RED='\033[0;31m'    # 错误或警告信息
GREEN='\033[0;32m'  # 成功信息
YELLOW='\033[0;33m' # 警告或提示信息
BLUE='\033[0;34m'   # 一般信息
CYAN='\033[0;36m'   # 时间戳或强调信息
NC='\033[0m'        # 重置颜色

# 定义日志文件
export LOG_FILE=${LOG_FILE:-"/tmp/15099.log"}

# 创建日志文件并设置权限（如果需要）
touch "$LOG_FILE" && chmod 644 "$LOG_FILE"

# 日志输出函数（带时间戳和类别）
log_message() {
    local type=$1    # 日志类别：INFO, SUCCESS, WARNING, ERROR
    local message=$2 # 日志内容

    case $type in
        INFO)
            echo -e "${BLUE}$message${NC}"
            ;;
        SUCCESS)
            echo -e "${GREEN}$message${NC}"
            ;;
        WARNING)
            echo -e "${YELLOW}$message${NC}"
            ;;
        ERROR)
            echo -e "${RED}$message${NC}"
            ;;
        *)
            echo -e "${RED}$message${NC}"
            ;;
    esac
}

# 使用 read_with_message
read_with_message() {
    local prompt_message="$1"
    local variable_name="$2"
    # 打印带颜色的提示信息
    printf "${BLUE}$prompt_message:${NC} "
    
    # 读取用户输入
    read -t 60 -r $variable_name
}
