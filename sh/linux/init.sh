#!/bin/bash
echo "准备初始化linux"

DEFAULT_VALUE="默认值"
prompt="请输入内容，10秒内无输入将采用默认值: "

# 使用read的-t选项及命令替换特性
read -t 10 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
echo "${USER_INPUT:-$DEFAULT_VALUE}"

#后续操作基于${USER_INPUT:-$DEFAULT_VALUE}进行
bash
