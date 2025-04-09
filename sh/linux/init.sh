#!/bin/bash
echo "Preparing to initialize Linux"

#######################################################chang_repo_update########################################################################################
chang_repo() {
echo ""
echo "Adjusting repository information, system upgrade, installing basic packages"
DEFAULT_VALUE="Y"
prompt="Enter content (Y/N), default value will be used if no input within 10 seconds ( $DEFAULT_VALUE ): "
# Use read's -t option and command substitution feature
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}

if [ "$USER_INPUT" = "Y" ] && [ "$COUNTRY" = "cn" ]; then
    echo "Now adjusting repository information, system upgrade, installing basic packages"
    case $OS in
        debian)
            echo "Executing operations for Debian..."
            # https://mirrors.tuna.tsinghua.edu.cn/help/debian/
            sed -i.bak 's#http://deb.debian.org#https://mirrors.tuna.tsinghua.edu.cn/debian#g' /etc/apt/sources.list
            sed -i 's#http://security.debian.org#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate xz-utils -y
            ;;
        ubuntu)
            echo "Executing operations for Ubuntu..."
            sed -i.bak 's#http://archive.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list.d/sources.list
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate xz-utils -y
            ;;
        armbian)
            echo "Executing operations for Armbian..."
            #systemctl enable armbian-resize-filesystem
            #systemctl start armbian-resize-filesystem
            sed -i.bak 's#http://apt.armbian.com#https://mirrors.tuna.tsinghua.edu.cn/armbian#g' /etc/apt/sources.list.d/armbian.list
            sed -i 's#http://archive.ubuntu.com#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate ntp xz-utils -y
            systemctl disable --now ssh.socket
            systemctl enable --now ssh.service
            ;;
        alpine)
            echo "Executing operations for Alpine..."
            # Alpine does not enable tun by default, so it needs to be enabled manually
            modprobe tun
            echo "tun" >>/etc/modules

            # Check if it takes effect
            lsmod | grep tun
            apk upgrade --no-cache --available
            # Install qemu-guest-agent tzdata
            # Add to default startup
            # Check enabled system startup services on Alpine Linux
            apk add qemu-guest-agent tzdata
            rc-update add qemu-guest-agent
            rc-status -a
            ;;
        *)
            echo "Unknown system type: $OS"
            ;;
    esac
else
    echo "Not adjusting repository, directly upgrading and installing basic packages"
    case $OS in
        debian)
            echo "Executing operations for Debian..."
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate ntp xz-utils -y
            ;;
        ubuntu)
            echo "Executing operations for Ubuntu..."
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate ntp xz-utils -y
            ;;
        armbian)
            echo "Executing operations for Armbian..."
            apt update -y && apt upgrade -y
            apt-get install net-tools wget ntpdate ntp xz-utils -y
            ;;
        alpine)
            echo "Executing operations for Alpine..."
            # Alpine does not enable tun by default, so it needs to be enabled manually
            modprobe tun
            echo "tun" >>/etc/modules

            # Check if it takes effect
            lsmod | grep tun
            apk upgrade --no-cache --available
            # Install qemu-guest-agent tzdata
            # Add to default startup
            # Check enabled system startup services on Alpine Linux
            apk add qemu-guest-agent tzdata
            rc-update add qemu-guest-agent
            rc-status -a
            ;;
        *)
            echo "Unknown system type: $OS"
            ;;
    esac
fi
}

chang_repo
#######################################################chang_dns_time########################################################################################
chang_dns_time() {
echo ""
echo "Adjusting system DNS and timezone"
DEFAULT_VALUE="Y"
prompt="Enter content (Y/N), default value will be used if no input within 10 seconds ( $DEFAULT_VALUE ): "
# Use read's -t option and command substitution feature
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}
if [ "$USER_INPUT" = "Y" ] && [ "$COUNTRY" = "cn" ]; then
    echo "Now adjusting DNS to domestic DNS resolution"
    # Domestic DNS
    rm -rf /etc/resolv.conf 
cat > /etc/resolv.conf << EOF 
nameserver 223.5.5.5 
nameserver 114.114.114.114
EOF
    cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
else
    echo "Now adjusting DNS to foreign DNS resolution and timezone"
    # Foreign DNS
    rm -rf /etc/resolv.conf 
cat > /etc/resolv.conf << EOF 
nameserver 8.8.8.8 
nameserver 1.1.1.1
EOF
    fi
    cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
}
chang_dns_time
#######################################################chang_hostname########################################################################################
chang_hostname() {
echo ""
echo "Adjusting system hostname"
DEFAULT_VALUE="qq-hk20-000-gost"
prompt="Enter content (manufacturer-country+number-user number-purpose | qq-hk20-000-gost), default value will be used if no input within 20 seconds ( $DEFAULT_VALUE ): "
# Use read's -t option and command substitution feature
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}
HNAME=$USER_INPUT
echo $HNAME > /etc/hostname
hostname $HNAME
}
chang_hostname
#######################################################chang_ssh########################################################################################
chang_ssh() {
echo ""
echo "Adjusting system SSH configuration"
DEFAULT_VALUE="N"
prompt="Enter content (Y/N), default value will be used if no input within 10 seconds ( $DEFAULT_VALUE ): "
# Use read's -t option and command substitution feature
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}
if [ "$USER_INPUT" = "Y" ]; then
DEFAULT_PASSWD="!passWord"
prompt="Enter root password, default value will be used if no input within 10 seconds ( $DEFAULT_PASSWD ): "
# Use read's -t option and command substitution feature
read -t 20 -p "$prompt" PASSWD_INPUT || PASSWD_INPUT=$DEFAULT_PASSWD
: ${PASSWD_INPUT:=$DEFAULT_PASSWD}
echo -e "$PASSWD_INPUT\n$PASSWD_INPUT" | (passwd root) 

echo "Generating local SSH authorized login"
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cd .ssh
cp id_rsa.pub authorized_keys
chmod 600 authorized_keys

echo "Disabling X11 forwarding and changing port"
sed -i s'/^X11Forwarding yes$/#X11Forwarding yes/' /etc/ssh/sshd_config 
sed -i s'/^#Port 22$/Port 32123/' /etc/ssh/sshd_config 
sed -i s'/^Port 22$/Port 32123/' /etc/ssh/sshd_config 
sed -i s'/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 
sed -i s'/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart
echo "Successfully changed SSH port to 32123, password is: $PASSWD_INPUT, enabled host password login"
fi
}
chang_ssh

#######################################################chang_wireguard########################################################################################
chang_wireguard() {
echo ""
echo "Adjusting repository to install Wireguard kernel support"
DEFAULT_VALUE="N"
prompt="Enter content (Y/N), default value will be used if no input within 20 seconds ( $DEFAULT_VALUE ): "
# Use read's -t option and command substitution feature
read -t 20 -p "$prompt" USER_INPUT || USER_INPUT=$DEFAULT_VALUE
: ${USER_INPUT:=$DEFAULT_VALUE}

if [ "$USER_INPUT" = "Y" ] && [ "$COUNTRY" = "cn" ]; then
    echo "Now adjusting repository information, system upgrade, installing basic packages"
    case $OS in
        debian)
            echo "Executing operations for Debian..."
            echo 'deb http://mirrors.aliyun.com/debian buster-backports main' | tee /etc/apt/sources.list.d/buster-backports.list
            apt update -y
            apt install linux-headers-$(uname -r) -y
            apt install wireguard -y
            modprobe wireguard && lsmod | grep wireguard
            ;;
        ubuntu)
            echo "Executing operations for Ubuntu..."
            ;;
        armbian)
            echo "Executing operations for Armbian..."
            ;;
        *)
            echo "Unknown system type: $OS"
            ;;
    esac
else
    echo "Not adjusting repository, directly upgrading and installing basic packages"
    case $OS in
        debian)
            # echo "Executing operations for Debian..."
            # echo 'deb http://ftp.debian.org/debian buster-backports main' | tee /etc/apt/sources.list.d/buster-backports.list
            # apt update -y
            # apt install linux-headers-$(uname -r) -y
            # apt install wireguard -y
            # modprobe wireguard && lsmod | grep wireguard
            ;;
        ubuntu)
            echo "Executing operations for Ubuntu..."
            ;;
        armbian)
            echo "Executing operations for Armbian..."
            ;;
        *)
            echo "Unknown system type: $OS"
            ;;
    esac
fi
}
chang_wireguard
#######################################################chang_sysctl########################################################################################
chang_sysctl() {
echo ""
echo "Adjusting system sysctl information"
cat > /etc/sysctl.conf << TEMPEOF
## Increase the file limit for the entire system
fs.file-max = 35525
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 32400
fs.fanotify.max_queued_events = 65536
## Adjust kernel open file descriptors
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_reuse = 1
##net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 40000 65000
net.ipv4.tcp_max_syn_backlog = 8192
#net.ipv4.tcp_max_tw_buckets = 5000
#net.netfilter.nf_conntrack_max=1048576
#net.nf_conntrack_max=1048576
## Enable TCP Fast Open
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
## Enable bbr
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
## Virtual memory optimization
vm.swappiness=10
## Disable IPV6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
TEMPEOF
sysctl -p
echo "Successfully adjusted kernel parameters and enabled BBR"
}
chang_sysctl
