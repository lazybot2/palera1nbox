#!/bin/bash
SSID="lazy"
PASSWORD="12345678"
chkwifi=$(nmcli device | grep -o -E "^wlxe.*wifi.*disconnected.*")
if [[  ! -z "$chkwifi" ]];then
    #wifidir=$(echo "$chkwifi" | grep -o -E "^wlxe\w*")
    nmcli device wifi connect "$SSID" password "$PASSWORD"
fi