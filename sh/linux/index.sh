#!/bin/bash
main_menu() {
    clear
    echo "################################################################"
    echo "#   欢迎访问  https://bash.15099.net 脚本管理系统                #"
    echo "#   当前程序只支持debian | ubutun | armbian 其他发行版未适配      #"
    echo "#   主机是否为虚拟平台：$VIRTUAL_PLATFORM  系统：$OS              #"
    echo "#   主机内存大小(MB): $MEM_TOTAL 磁盘大小: $DISK_TOTAL           #"
    echo "#   主机IP地址: $WANIP        IP所属国家: $COUNTRY               #"
    echo "################################################################"
    echo "请选择一个操作:"
    echo "1) 在线更换系统|Linux换其他版本、灌爱快系统、一键物理机安装armbian"
    echo "2) Linux初始化|升级、repo、时区、时间、主机名等"
    echo "3) Docker环境初始化| 版本、代理、日志等设置"
    echo "4) Portainer中文图像界面安装"
    echo "5) 主机bench压力测试"
    echo "0) 返回上级菜单"
    read -p "输入选项: " -r choice
    case $choice in
        1)
		run_script1
 		;;
        2)
		run_script2
  		;;
        3)
		run_script3
  		;;
        4)
		run_script4
  		;;
        5)	run_script5
		;;
        6)	run_script6
		;;  
        0)
		exit 0 
  		;;
        *)
		echo "无效的选项，请重新选择。"
  		sleep 2
    		main_menu
      		;;
    esac
}

run_script1() {
    echo "正在运行在线脚本1...在线更换系统"
    # 这里放置执行脚本1的代码，例如通过curl或wget获取并执行
    # 示例：curl -sL https://someurl/script1.sh | bash
    curl -sL https://bash.15099.net/linux/os.sh > /tmp/os.sh
    bash /tmp/os.sh
    rm -rf /tmp/os.sh
    echo "脚本1执行完毕，按回车键继续。"
    read
    main_menu
}

run_script2() {
    echo "正在运行在线脚本2...Linux初始化"
    # 同样，这里插入脚本2的执行逻辑
    curl -sL https://bash.15099.net/linux/init.sh > /tmp/init.sh
    bash /tmp/init.sh
    rm -rf /tmp/init.sh
    echo "脚本2执行完毕，按回车键继续。"
    read
    main_menu
}

run_script3() {
    echo "正在运行在线脚本3...Docker环境初始化"
    # 插入脚本3的执行逻辑
    curl -sL https://bash.15099.net/linux/docker.sh > /tmp/docker.sh
    bash /tmp/docker.sh
    rm -rf /tmp/docker.sh
    echo "脚本3执行完毕，按回车键继续。"
    read
    main_menu
}

run_script4() {
    echo "正在运行在线脚本4...Portainer中文图像界面安装"
    # 插入脚本4的执行逻辑
    curl -sL https://bash.15099.net/linux/portainer.sh > /tmp/portainer.sh
    bash /tmp/portainer.sh
    rm -rf /tmp/portainer.sh
    echo "脚本4执行完毕，按回车键继续。"
    read
    main_menu
}

run_script5() {
    echo "正在运行在线脚本5...主机压力测试"
    # 插入脚本5的执行逻辑
    curl -sL https://bash.15099.net/linux/bench.sh > /tmp/bench.sh
    bash /tmp/bench.sh
    rm -rf /tmp/bench.sh
    echo "脚本5执行完毕，按回车键继续。"
    read
    main_menu
}

run_script6() {
    echo "正在运行在线脚本5...主机压力测试"
    # 插入脚本5的执行逻辑
    curl -sL https://bash.15099.net/linux/unixbench.sh > /tmp/unixbench.sh
    bash /tmp/unixbench
    rm -rf /tmp/unixbench
    echo "脚本6执行完毕，按回车键继续。"
    read
    main_menu
}
# 主程序开始
clear
main_menu
