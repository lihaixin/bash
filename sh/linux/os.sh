#!/bin/bash
sub1_main_menu() {
    clear
    echo "################################################################"
    echo "#   欢迎访问 https://bash.15099.net 脚本OS管理系统               "
    echo "#   主机是否为虚拟平台：$VIRTUAL_PLATFORM                        "
    echo "#   主机内存大小(MB): $MEM_TOTAL 磁盘大小: $DISK_TOTAL           "
    echo "#   主机IP地址: $WANIP        IP所属国家: $COUNTRY               "
    echo "################################################################"
    echo "请选择一个操作:"
    echo "1) Linux换成Debian12纯版本"
    echo "2) 灌爱快系统"
    echo "3) 一键物理机安装armbian"
    echo "4) 一键物理机安装飞牛NAS"
    echo "0) 返回上级菜单"
    read -p "输入选项: " choice
    case $choice in
        1) sub1_run_script1 ;;
        2) sub1_run_script2 ;;
        3) sub1_run_script3 ;;
        4) sub1_run_script4 ;;
        0) exit 0 ;;
        *) echo "无效的选项，请重新选择。"; sleep 2; main_menu ;;
    esac
}

sub1_run_script1() {
    echo "正在运行在线Linux换成Debian11纯版本系统"
    # 这里放置执行脚本1的代码，例如通过curl或wget获取并执行
    # 示例：curl -sL https://someurl/script1.sh | bash
    curl -sL https://bash.15099.net/linux/online_install_linux.sh > /tmp/online_install_linux.sh
    bash /tmp/online_install_linux.sh
    rm -rf /tmp/online_install_linux.sh
    echo "Linux换成Debian12纯版本系统执行完毕，按回车键继续。"
    read
    sub1_main_menu
}

sub1_run_script2() {
    echo "正在运行在线灌爱快系统"
    # 同样，这里插入脚本2的执行逻辑
    curl -sL https://bash.15099.net/linux/online_install_ikuai.sh > /tmp/online_install_ikuai.sh
    bash /tmp/online_install_ikuai.sh
    rm -rf //tmp/online_install_ikuai.sh
    echo "在线灌爱快系统执行完毕，按回车键继续。"
    read
    sub1_main_menu
}

sub1_run_script3() {
    echo "正在运行在线一键物理机安装armbian"
    # 插入脚本3的执行逻辑
    curl -sL https://bash.15099.net/linux/online_install_armbian.sh > /tmp/online_install_armbian.sh
    bash /tmp/online_install_armbian.sh
    rm -rf /tmp/online_install_armbian.sh
    echo "在线一键物理机安装armbian执行完毕，按回车键继续。"
    read
    sub1_main_menu
}

sub1_run_script4() {
    echo "正在运行在线一键物理机安装飞牛nas"
    # 插入脚本4的执行逻辑
    curl -sL https://gh.15099.net/https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh > /tmp/online_install_fnos.sh
    bash /tmp/online_install_fnos.sh fnos
    rm -rf /tmp/online_install_fnos.sh 
    echo "在线一键物理机安装fnos执行完毕，按回车键继续。"
    read
    sub1_main_menu
}
clear
while true; do
    sub1_main_menu
done
