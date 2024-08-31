#!/bin/bash
echo "准备初始化docker..."

#######################################################chang_repo_update########################################################################################
chang_repo() {
echo "开始安装doceker.io"
DEFAULT_VALUE="Y"
prompt="请输入内容(Y/N)，20秒内无输入将采用默认值( $DEFAULT_VALUE ): "
# 使用read的-t选项及命令替换特性
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:$DEFAULT_VALUE}"

if [ "$USER_INPUT" = "Y" ] &&[ "$COUNTRY" = "cn" ]; then
    echo "现在安装docker.io"
    apt install docker.io
    echo "成功安装docker.io"
    mkdir -p /etc/docker 
    tee /etc/docker/daemon.json <<-'EOF'
    	{
    	  "log-driver": "json-file", 
    	  "log-opts": { 
    	  "max-size": "20m", "max-file": "3" 
    	  },
          "dns" : [
            "8.8.8.8"
          ]
    	}
    EOF
else
    echo "现在安装docker.io"
    apt install docker.io
    echo "成功安装docker.io"
    mkdir -p /etc/docker 
    tee /etc/docker/daemon.json <<-'EOF'
    	{
    	  "registry-mirrors": ["https://hub.15099.net"],
    	  "log-driver": "json-file", 
    	  "log-opts": { 
    	  "max-size": "20m", "max-file": "3" 
    	  }
    	}
    EOF
fi
}
