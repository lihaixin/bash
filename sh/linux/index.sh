#!/bin/bash
main_menu() {
    clear
    echo "##################################################################################"
    echo "#   Welcome to https://bash.15099.net Script Management System                   #"
    echo "#   This program only supports debian | ubuntu | armbian, other distributions are not supported #"
    echo "#   Is the host a virtual platform: $VIRTUAL_PLATFORM  System: $OS               #"
    echo "#   Host memory size (MB): $MEM_TOTAL Disk size: $DISK_TOTAL                     #"
    echo "#   Host IP address: $WANIP        IP country: $COUNTRY                          #"
    echo "##################################################################################"
    echo "Please select an option:"
    echo "1) Online system replacement | Change Linux version, install OpenWrt, one-click install Armbian on physical machine"
    echo "2) Linux initialization | Upgrade, repo, timezone, time, hostname, etc."
    echo "3) Docker environment initialization | Version, proxy, log settings, etc."
    echo "4) Install Portainer Chinese graphical interface"
    echo "5) Host bench stress test | Disk, network speed test"
    echo "6) Host unixbench stress test | CPU, memory test"
    echo "0) Return to the previous menu"
    read -p "Enter option: " -r choice
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
        5)
		run_script5
		;;
        6)
		run_script6
		;;  
        0)
		exit 0 
  		;;
        *)
		echo "Invalid option, please select again."
  		sleep 2
    		main_menu
      		;;
    esac
}

run_script1() {
    echo "Running online script 1... Online system replacement"
    # Place the code to execute script 1 here, e.g., fetch and execute via curl or wget
    # Example: curl -sL https://someurl/script1.sh | bash
    curl -sL https://bash.15099.net/linux/os.sh > /tmp/os.sh
    bash /tmp/os.sh
    rm -rf /tmp/os.sh
    echo "Script 1 execution completed, press Enter to continue."
    read
    main_menu
}

run_script2() {
    echo "Running online script 2... Linux initialization"
    # Similarly, insert the logic to execute script 2 here
    curl -sL https://bash.15099.net/linux/init.sh > /tmp/init.sh
    bash /tmp/init.sh
    rm -rf /tmp/init.sh
    echo "Script 2 execution completed, press Enter to continue."
    read
    main_menu
}

run_script3() {
    echo "Running online script 3... Docker environment initialization"
    # Insert the logic to execute script 3 here
    curl -sL https://bash.15099.net/linux/docker.sh > /tmp/docker.sh
    bash /tmp/docker.sh
    rm -rf /tmp/docker.sh
    echo "Script 3 execution completed, press Enter to continue."
    read
    main_menu
}

run_script4() {
    echo "Running online script 4... Install Portainer Chinese graphical interface"
    # Insert the logic to execute script 4 here
    curl -sL https://bash.15099.net/linux/portainer.sh > /tmp/portainer.sh
    bash /tmp/portainer.sh
    rm -rf /tmp/portainer.sh
    echo "Script 4 execution completed, press Enter to continue."
    read
    main_menu
}

run_script5() {
    echo "Running online script 5... Host stress test"
    # Insert the logic to execute script 5 here
    curl -sL https://bash.15099.net/linux/bench.sh > /tmp/bench.sh
    bash /tmp/bench.sh
    rm -rf /tmp/bench.sh
    echo "Script 5 execution completed, press Enter to continue."
    read
    main_menu
}

run_script6() {
    echo "Running online script 6... Host stress test"
    # Insert the logic to execute script 6 here
    curl -sL https://bash.15099.net/linux/unixbench.sh > /tmp/unixbench.sh
    bash /tmp/unixbench.sh
    rm -rf /tmp/unixbench.sh
    echo "Script 6 execution completed, press Enter to continue."
    read
    main_menu
}
# Main program start
clear
main_menu
