#!/bin/bash
echo "Preparing to install pure Debian 12 system online"

DEFAULT_VALUE="password"
prompt="Please enter the installation password, using the default value ( $DEFAULT_VALUE ) if no input within 20 seconds: "
read -t 20 -p "$prompt" PASSWORD || PASSWORD=$DEFAULT_VALUE
: ${PASSWORD:=$DEFAULT_VALUE}

# if [ "$COUNTRY" == "cn" ]; then
#   bash <(wget --no-check-certificate -qO- 'https://bash.15099.net/linux/netinstallos.sh') -d 12 -v 64 -p "$PASSWORD" --mirror 'http://mirrors.aliyun.com/debian/'
# else
#   bash <(wget --no-check-certificate -qO- 'https://bash.15099.net/linux/netinstallos.sh') -d 12 -v 64 -p "$PASSWORD"
# fi
if [ "$COUNTRY" == "cn" ]; then
  curl -O https://cnb.cool/bin456789/reinstall/-/git/raw/main/reinstall.sh || wget -O /tmp/online_install_debian.sh $_ 
else
  curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh || wget -O /tmp/online_install_debian.sh $_
fi
bash /tmp/online_install_debian.sh debian12
rm -rf /tmp/online_install_debian.sh
