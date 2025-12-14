#!/bin/bash
SSID="lazybot"
PASSWORD="12345678"
chkwifi=$(nmcli device | grep -o -E "^wlxe.*wifi.*disconnected.*")
if [[  ! -z "$chkwifi" ]];then
    chkwifi=$(nmcli device wifi list | grep -w "$SSID")
    if [[  ! -z "$chkwifi" ]];then
        nmcli device wifi connect "$SSID" password "$PASSWORD"
    fi
fi