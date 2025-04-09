#!/bin/bash
sub1_main_menu() {
    clear
    echo "################################################################"
    echo "#   Welcome to https://bash.15099.net OS Management System      "
    echo "#   Is the host a virtual platform: $VIRTUAL_PLATFORM            "
    echo "#   Host memory size (MB): $MEM_TOTAL Disk size: $DISK_TOTAL     "
    echo "#   Host IP address: $WANIP        IP country: $COUNTRY          "
    echo "################################################################"
    echo "Please select an operation:"
    echo "1) Replace Linux with pure Debian 12"
    echo "2) Install iKuai system"
    echo "3) One-click install Armbian on physical machine"
    echo "4) One-click install Feiniu NAS on physical machine"
    echo "0) Return to previous menu"
    read -p "Enter choice: " choice
    case $choice in
        1) sub1_run_script1 ;;
        2) sub1_run_script2 ;;
        3) sub1_run_script3 ;;
        4) sub1_run_script4 ;;
        0) exit 0 ;;
        *) echo "Invalid option, please try again."; sleep 2; main_menu ;;
    esac
}

sub1_run_script1() {
    echo "Running script to replace Linux with pure Debian 12"
    # Insert the code to execute script 1 here, e.g., download and execute via curl or wget
    # Example: curl -sL https://someurl/script1.sh | bash
    curl -sL https://bash.15099.net/linux/online_install_linux.sh > /tmp/online_install_linux.sh
    bash /tmp/online_install_linux.sh
    rm -rf /tmp/online_install_linux.sh
    echo "Replacing Linux with pure Debian 12 system completed, press Enter to continue."
    read
    sub1_main_menu
}

sub1_run_script2() {
    echo "Running script to install iKuai system"
    # Insert the logic to execute script 2 here
    curl -sL https://bash.15099.net/linux/online_install_ikuai.sh > /tmp/online_install_ikuai.sh
    bash /tmp/online_install_ikuai.sh
    rm -rf /tmp/online_install_ikuai.sh
    echo "Installing iKuai system completed, press Enter to continue."
    read
    sub1_main_menu
}

sub1_run_script3() {
    echo "Running script to install Armbian on physical machine"
    # Insert the logic to execute script 3 here
    curl -sL https://bash.15099.net/linux/online_install_armbian.sh > /tmp/online_install_armbian.sh
    bash /tmp/online_install_armbian.sh
    rm -rf /tmp/online_install_armbian.sh
    echo "Installing Armbian on physical machine completed, press Enter to continue."
    read
    sub1_main_menu
}

sub1_run_script4() {
    echo "Running script to install Feiniu NAS on physical machine"
    # Insert the logic to execute script 4 here
    curl -sL https://gh.15099.net/https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh > /tmp/online_install_fnos.sh
    bash /tmp/online_install_fnos.sh fnos
    rm -rf /tmp/online_install_fnos.sh 
    echo "Installing Feiniu NAS on physical machine completed, press Enter to continue."
    read
    sub1_main_menu
}
clear
while true; do
    sub1_main_menu
done
