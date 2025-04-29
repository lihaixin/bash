#!/bin/bash
echo "Preparing to install pure Debian 12 system online"

DEFAULT_VALUE="password"
prompt="Please enter the installation password, using the default value ( $DEFAULT_VALUE ) if no input within 20 seconds: "
read -t 20 -p "$prompt" PASSWORD || PASSWORD=$DEFAULT_VALUE

if [ "$COUNTRY" == "cn" ]; then
    URL="https://cnb.cool/bin456789/reinstall/-/git/raw/main/reinstall.sh"
else
    URL="https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh"
fi

TEMP_SCRIPT="/tmp/online_install_debian.sh"
if ! curl -o "$TEMP_SCRIPT" "$URL" && ! wget -O "$TEMP_SCRIPT" "$URL"; then
    echo "Failed to download the script. Exiting."
    exit 1
fi

bash "$TEMP_SCRIPT" debian12
rm -f "$TEMP_SCRIPT"
