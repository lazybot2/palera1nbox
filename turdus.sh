#!/bin/bash
turdusra1n="sudo ./turdusra1n"
turdus_merula="sudo ./turdus_merula"
checkra1n="sudo ./checkra1n"
irecovery="sudo irecovery"
Mode=""
SHSH=""
ID=0
ISPW=""
CURRENT=""
RESTORE=""
SEP=""
IM4P=""
tmp=""
CHK=""
PTE=""
input=""
iphoe_chk=""
AMODE=""
update=0
tip_con=0
tip_dfu=0
BOOTIMG=""
SEPI=""
SEPP=""
JB_BOOTIMG=""
JB_SEPI=""
JB_SEPP=""
Log="./run.log"
if [[ "$*" =~ "--safe-mode" ]];then
    Mode=1
elif  [[ "$*" =~ "--force-revert" ]];then
    Mode=2
elif [[ "$*" =~ "--sileo" ]];then
    Mode=3
elif  [[ "$*" =~ "--normal" ]];then
    Mode=4
fi
if [[ "$*" =~ "--shsh2" ]];then
    SHSH="SHSH"
fi
if [ -d /tmp ];then
    Log="/tmp/turdus_run.log"
fi
if [ ! -d ./JB ];then
    mkdir JB
fi
if [ ! -d ./block ];then
    mkdir block
fi
if [ ! -d ./image4 ];then
    mkdir image4
fi
if [ ! -d ./IPSW ];then
    mkdir IPSW
fi
if [ ! -d /lazybot_load ];then
    mkdir /lazybot_load
fi
rsync -a --delete ./JB/ /lazybot_load/
get_ecid(){
    div=`sudo lsusb | grep "Apple";exit 0`
    #dfu=`lsusb | grep "DFU" `
    if [ ! -z "$div" ]; then
        tip_con=1
        if [[ "$div" =~ "DFU" ]]; then
            #echo 'YES'
            ECID=`$irecovery -q | grep "ECID";exit 0`
            if [ ! -z "$ECID" ]; then
                ECID=${ECID#*: }
                ID=$(($ECID+0))
                i_CPID=`$irecovery -q | grep "CPID"`
                i_BDID=`$irecovery -q | grep "BDID"`
                i_CPID=${i_BDID#*: }${i_CPID#*: }
                i_CPID=${i_CPID,,}
                #echo "$i_CPID"
                if [[ "0x040x8000 0x040x8003" =~ "$i_CPID" ]];then
                    iphoe_chk="6S"
                    ISPW="./IPSW/6s.ipsw"
                    AMODE="A9"
                elif [[ "0x060x8000 0x060x8003" =~ "$i_CPID" ]];then
                    iphoe_chk="6SP"
                    ISPW="./IPSW/6sp.ipsw"
                    AMODE="A9"
                elif [[ "0x020x8003 0x020x8000" =~ "$i_CPID" ]];then
                    iphoe_chk="5SE"
                    ISPW="./IPSW/5se.ipsw"
                    AMODE="A9"
                elif [[ "0x080x8001 0x0a0x8001" =~ "$i_CPID" ]];then
                    iphoe_chk="iPad Pro 9.7-inch"
                    ISPW="./IPSW/ipad97.ipsw"
                    AMODE="A9"
                elif [[ "0x100x8001 0x120x8001" =~ "$i_CPID" ]];then
                    iphoe_chk="iPad Pro 12.9-inch 1代"
                    ISPW="./IPSW/ipadp129-1.ipsw"
                    AMODE="A9"
                elif [[ "0x100x8000 0x100x8003 0x120x8000 0x120x8003" =~ "$i_CPID" ]];then
                    iphoe_chk=" iPad  5th gen"
                    ISPW="./IPSW/ipad5.ipsw"
                    AMODE="A9"
                elif [[ "0x080x8010 0x0c0x8010" =~ "$i_CPID" ]];then
                    iphoe_chk="iP 7"
                    ISPW="./IPSW/i7.ipsw"
                    AMODE="A10"
                elif [[ "0x0a0x8010 0x0e0x8010" =~ "$i_CPID" ]];then
                    iphoe_chk="iP 7P"
                    ISPW="./IPSW/i7p.ipsw"
                    AMODE="A10"
                elif [[ "0x160x8010" =~ "$i_CPID" ]];then
                    iphoe_chk="iPod Touch 7th"
                    ISPW="./IPSW/ipod7.ipsw"
                    AMODE="A10"
                elif [[ "0x180x8010 0x2a0x8010 0x1c0x8010 0x1e0x8010" =~ "$i_CPID" ]];then
                    iphoe_chk="iPad 7th "
                    ISPW="./IPSW/ipad7.ipsw"
                    AMODE="A10"
                elif [[ "0x0c0x8011 0x0e0x8011" =~ "$i_CPID" ]];then
                    iphoe_chk="iPad Pro 12.9-inch 2nd"
                    ISPW="./IPSW/ipadp129-2.ipsw"
                    AMODE="A10"
                elif [[ "0x040x8011 0x060x8011" =~ "$i_CPID" ]];then
                    iphoe_chk="iPad Pro 10.5-inch"
                    ISPW="./IPSW/ipadp10.ipsw"
                    AMODE="A10"
                else
                    iphoe_chk="no"
                    AMODE=""
                fi
            fi
            tip_dfu=0
        else
            if [ $tip_dfu -eq 0 ];then
                echo -e "waiting DFU"
                tip_dfu=1
            fi
            sleep 0.5
        fi
    else
        tip_con=0
        tip_dfu=0
    fi
}
if [ -z "$SHSH" ];then
    
    file_name=("6s" "6sp" "5se" "ipad97" "ipad5" "i7" "i7p" "ipod7" "ipad7" "ipadp129-2" "ipadp10")
    usb_path="/media/"
    ipsw_path="/root/palera1nbox/IPSW/"
    out=""
    if [[ "$(find "$usb_path" -mindepth 1 -maxdepth 1 -type d )" ]];then
        echo "Backup dir name is:"
        echo "lazybot_back"
        echo "Upload dir name is:"
        echo "lazybot_load"
        sleep 3
    fi
    for buck_path in $(find "$usb_path" -maxdepth 2 -type d -name "lazybot_load");do
        if [[ -d $buck_path ]];then
            echo "up load files"
            sleep 3
            cp -uv "$buck_path/"*.bin "./JB/"
            cp -uv "$buck_path/"*.img4 "./JB/"
            cp -uv "$buck_path/"*.im4p "./JB/"
            echo "Up load files OK"
            sleep 5
            out="YES"
            break
        fi
    done
    for buck_path in $(find "$usb_path" -maxdepth 2 -type d -name "lazybot_back");do
        if [[ -d $buck_path ]];then
            echo "backup files to lazybot_back"
            sleep 3
            cp -urv "./JB/" "$buck_path"
            echo "Backup filse OK"
            sleep 5
            out="YES"
            break
        fi
    done
    
    # 使用for循环遍历数组
    for name in "${file_name[@]}"
    do
        for file in $(find "$usb_path" -maxdepth 5 -name "$name.ipsw");do
            if [[ -f $file ]];then
                echo "copy $name.ipsw to IPSW/"
                sleep 3
                rsync -avP -append-verify --partial "$file" "$ipsw_path"
                sleep 10
                out="YES"
                break
            fi
        done
    done
    if [[ "$out" = "YES" ]];then
        for buck_path in $(find "$usb_path" -mindepth 1 -maxdepth 1 -type d);do
            sudo umount "$buck_path"
        done
        echo "Please remove USB drive"
        sleep 6
        exit 2
    fi
fi
echo "Lazy Bot Auto turdus" 
echo "Downgrade Guide"
echo "For A9(X) A10(X)"
sleep 3
while true;do
    tip_con=0
    tip_dfu=0
    ID=0
    while true;
    do
        tmp=5
        get_ecid
        if [ $ID -gt 0 ] ;then
            if [[ "$SHSH" = "SHSH" ]];then
                echo "$iphoe_chk:$ID"
                sleep 5
                SHSH_PATH=""
                SHSH_SHSH=""
                SHSH_IPSW=""
                SHSH_SHC=""
                generator=""
                for buck_path in $(find "/media/" -maxdepth 2 -type d -name "$ID");do
                    if [[ -d $buck_path ]];then
                        SHSH_PATH="$buck_path"
                        echo "path $SHSH_PATH"
                        break
                    fi
                done
                if [[ -z "$SHSH_PATH" ]];then
                    echo "SHSH_PATH is ERR"
                    for buck_path in $(find "/media/" -type d -name "sd*");do
                        if [[ -d $buck_path ]];then
                            echo "create $ID folder"
                            sudo mkdir "$buck_path/$ID"
                            echo "this device $iphoe_chk" > "$buck_path/$ID/$ID.txt"
                            echo "create $ID folder" >> "$buck_path/$ID/$ID.txt"
                            echo "Please insert the *.shsh2 file and the corresponding *.ipsw file" >> "$buck_path/$ID/$ID.txt"
                            sleep 3
                            echo "Please remove USB drive"
                            sleep 3
                            echo "All Done"
                            sleep 5
                            exit 0
                        fi
                    done
                    exit 0
                else
                    echo "chk file"
                    for file in $(find "$SHSH_PATH" -name "*.shsh2");do
                        if [[ -f "$file" ]];then
                            SHSH_SHSH="$file"
                        fi
                    done
                    for file in $(find "$SHSH_PATH" -name "*.ipsw");do
                        if [[ -f "$file" ]];then
                            SHSH_IPSW="$file"
                        fi
                    done
                fi
                if [[ ! -f "$SHSH_SHSH" ]];then
                    echo "No find *.shsh2 file"
                    sleep 10
                    exit 0
                else
                    txt=`cat $SHSH_SHSH | grep -A 1 "generator"`
                    if [[ $txt ]];then
                        txt=${txt##*<string>}
                        txt=${txt%</string>*}
                    fi
                    if [[ $txt ]];then
                        generator="$txt"
                    fi
                    if [[ $generator ]];then
                        echo "gen:$generator"
                    else
                        echo "No find generator"
                        sleep 10
                        exit 0
                    fi
                fi
                if [[ ! -f "$SHSH_IPSW" ]];then
                    echo "No find *.ipsw file"
                    sleep 10
                    exit 0
                else
                    echo "$SHSH_IPSW"
                fi
                ###################
                if [[ "$AMODE" = "A9" ]];then
                    ###############
                    SHSH_SHC=`find ./block -name "$ID*restore-shcblock2.bin"`
                    if [ $SHSH_SHC ];then
                        for i in {10..1}
                        do
                            echo "Restoring the device $i S"
                            sleep 1
                        done
                        $turdusra1n -Db $generator
                        sleep 5
                        $turdus_merula -y -w --load-shsh "$SHSH_SHSH" --load-shcblock "$SHSH_SHC" "$SHSH_IPSW"  | tee "$Log"
                        sleep 1
                        if grep -q "DONE" "$Log"; then
                            echo "Restoring Ok"
                            sleep 10
                            find ./JB/ -name "$ID*" -type f -print -exec rm -rf {} \;
                            find ./image4/ -name "$ID*" -type f -print -exec rm -rf {} \;
                            find ./block/ -name "$ID*" -type f -print -exec rm -rf {} \;
                            echo "Please remove USB drive"
                            sleep 5
                            echo "All Done"
                            sleep 10
                            exit 0
                        fi
                        sleep 3
                        echo "Restoring Err"
                        sleep 10
                        exit 0                     
                    else
                        $turdusra1n -D
                        sleep 3
                        while true;
                        do
                            $turdus_merula -y --get-shcblock "$SHSH_IPSW" | tee "$Log"
                            sleep 1
                            if grep -q ".bin saved to" "$Log"; then
                                echo -e "shcblock Ok"
                                sleep 15
                                break
                            fi
                        done
                        break
                    fi
                    #########
                elif [[ "$AMODE" = "A10" ]];then
                    for i in {10..1}
                    do
                        echo "Restoring the device $i S"
                        sleep 1
                    done
                    $turdusra1n -Db $generator
                    sleep 5
                    $turdus_merula -y -w --load-shsh "$SHSH_SHSH" "$SHSH_IPSW" | tee "$Log"
                    sleep 1
                    if grep -q "DONE" "$Log"; then
                        echo "Restoring Ok"
                        sleep 10
                        find ./JB/ -name "$ID*" -type f -print -exec rm -rf {} \;
                        find ./image4/ -name "$ID*" -type f -print -exec rm -rf {} \;
                        find ./block/ -name "$ID*" -type f -print -exec rm -rf {} \;
                        echo "Please remove USB drive"
                        sleep 5
                        echo "All Done"
                        sleep 10
                        exit 0
                    fi
                    sleep 3
                    echo "Restoring Err"
                    sleep 10
                    exit 0 
                else
                    echo "not supported the device"
                    echo "ECID:$ID"
                    echo "$i_CPID"
                    sleep 15
                    exit 0
                fi
            else    
                if [[ "$AMODE" = "A9" ]];then
                    echo "$iphoe_chk:$ID"
                    sleep 5
                    CHK=`find ./JB -name "$ID*current-pteblock2.bin"`
                    PTE=`find ./block -name "$ID*current-pteblock2.bin"`
                    SEP=`find ./image4 -name "$ID*signed-SEP.img4"`
                    IM4P=`find ./image4 -name "$ID*-SEP.im4p"`
                    CURRENT=`find ./block -name "$ID*current-shcblock2.bin"`
                    RESTORE=`find ./block -name "$ID*restore-shcblock2.bin"`
                    if [[ $Mode -eq 2 ]];then
                        echo "Clear All file $IDs"
                        for i in {10..1}
                        do
                            echo "Clear file $i S"
                            sleep 1
                        done
                        find ./JB/ -name "$ID*" -type f -print -exec rm -rf {} \;
                        find ./image4/ -name "$ID*" -type f -print -exec rm -rf {} \;
                        find ./block/ -name "$ID*" -type f -print -exec rm -rf {} \;
                        exit 0
                    fi
                    if [ $CHK ];then
                        if [[ $Mode -eq 4 ]];then
                            echo "Booting the device"
                        else
                            echo "Jailbroken the device"
                            if [[ $Mode -eq 1 ]];then
                                echo "Safe Mode"
                            fi
                        fi
                        sleep 3
                        while true;
                        do  
                            if [[ $Mode -eq 4 ]];then
                                $turdusra1n -TP $CHK | tee "$Log"
                                sleep 1
                                if grep -q "Sent bootux" "$Log"; then
                                    echo "Booting device Ok"
                                    sleep 5
                                    echo "All Done"
                                    sleep 5
                                    exit 0
                                fi
                            else
                                if [[ $Mode -eq 1 ]];then
                                    $turdusra1n -srTP $CHK | tee "$Log"
                                else
                                    $turdusra1n -rTP $CHK | tee "$Log"
                                fi
                                sleep 1
                                if grep -q "Finally" "$Log"; then
                                    echo "Jailbroken device Ok"
                                    sleep 5
                                    if [[ $Mode -eq 3 ]];then
                                        for i in {30..1}
                                        do
                                            echo "Install Silen wait..$i S"
                                            sleep 1
                                        done
                                        expect ./install_Sileo.sh
                                    fi
                                    echo "All Done"
                                    sleep 5
                                    exit 0
                                fi
                            fi
                        done
                        exit 0
                    elif [ $PTE ];then
                        echo "Booting the device"
                        while true;
                        do
                            $turdusra1n -TP $PTE | tee "$Log"
                            sleep 1
                            if grep -q "Sent bootux" "$Log"; then
                                cp -f $PTE ./JB
                                echo "Booting device Ok"
                                sleep 10
                                exit 0
                            fi
                        done
                    elif [[ -f $CURRENT ]] && [[ -f $SEP ]];then
                        while true;
                        do
                            $turdusra1n -g -i $SEP -C $CURRENT | tee "$Log"
                            sleep 1
                            if grep -q ".bin saved to" "$Log"; then
                                echo -e "pteblock Ok"
                                sleep 15
                                break
                            fi
                        done
                        break
                    elif [[ -f $RESTORE ]];then
                        if [[ -f $SEP ]];then
                            while true;
                            do
                                $turdusra1n -g | tee "$Log"
                                sleep 1
                                if grep -q ".bin saved to" "$Log"; then
                                    echo -e "current shcblock OK"
                                    sleep 15
                                    break
                                fi
                            done
                            break
                        else
                            echo "Restoring the device"
                            sleep 3
                            if [ -f "$ISPW" ] ;then
                                $turdusra1n -D
                                sleep 5
                                $turdus_merula -y -o --load-shcblock $RESTORE $ISPW  | tee "$Log"
                                sleep 5
                                if grep -q "DONE" "$Log"; then
                                    echo "Restoring Ok"
                                    sleep 10
                                    break
                                else
                                    echo "Restoring Err"
                                    find ./JB/ -name "$ID*" -type f -print -exec rm -rf {} \;
                                    find ./image4/ -name "$ID*" -type f -print -exec rm -rf {} \;
                                    find ./block/ -name "$ID*" -type f -print -exec rm -rf {} \;
                                    sleep 20
                                    exit 2
                                fi
                                sleep 3
                                break
                            else
                                echo "fIles: $ISPW"
                                echo "No Find"
                                sleep 10
                                exit 0
                            fi
                        fi
                    else
                        if [[ -f "$ISPW" ]] ;then
                            $turdusra1n -D
                            sleep 3
                            while true;
                            do
                                $turdus_merula -y --get-shcblock $ISPW | tee "$Log"
                                sleep 1
                                if grep -q ".bin saved to" "$Log"; then
                                    echo -e "shcblock Ok"
                                    sleep 15
                                    break
                                fi
                            done
                            break
                        else
                            echo "fIles: $ISPW"
                            echo "No Find"
                            sleep 10
                            exit 0
                        fi
                    fi
                elif [[ "$AMODE" = "A10" ]];then
                    echo "$iphoe_chk:$ID"
                    sleep 5
                    JB_BOOTIMG=`find ./JB -name "$ID*-iBoot.img4"`
                    JB_SEPI=`find ./JB -name "$ID*-signed-SEP.img4"`
                    JB_SEPP=`find ./JB -name "$ID*-SEP.im4p"`
                    BOOTIMG=`find ./image4 -name "$ID*-iBoot.img4"`
                    SEPI=`find ./image4 -name "$ID*-signed-SEP.img4"`
                    SEPP=`find ./image4 -name "$ID*-SEP.im4p"`
                    if [[ $Mode -eq 2 ]];then
                        echo "Clear All file $ID s"
                        for i in {10..1}
                        do
                            echo "$i"
                            sleep 1
                        done
                        find ./JB/ -name "$ID*" -type f -print -exec rm -rf {} \;
                        find ./image4/ -name "$ID*" -type f -print -exec rm -rf {} \;
                        find ./block/ -name "$ID*" -type f -print -exec rm -rf {} \;
                        exit 0
                    fi
                    if [[ -f $JB_BOOTIMG ]] && [[ -f $JB_SEPI ]] && [[ -f $JB_SEPP ]];then
                        if [[ $Mode -eq 4 ]];then
                            echo "Booting the device"
                        else
                            echo "Jailbroken the device"
                            if [[ $Mode -eq 1 ]];then
                                echo "Safe Mode"
                            fi
                        fi
                        sleep 3
                        while true;
                        do  
                            if [[ $Mode -eq 4 ]];then
                                $turdusra1n -t $JB_BOOTIMG -i $JB_SEPI -p $JB_SEPP | tee "$Log"
                                sleep 1
                                if grep -q "Sent bootux" "$Log"; then
                                    echo "Booting device Ok"
                                    sleep 5
                                    echo "All Done"
                                    sleep 5
                                    exit 0
                                fi
                            else
                                if [[ $Mode -eq 1 ]];then
                                    $turdusra1n -srt $JB_BOOTIMG -i $JB_SEPI -p $JB_SEPP | tee "$Log"
                                else
                                    $turdusra1n -rt $JB_BOOTIMG -i $JB_SEPI -p $JB_SEPP | tee "$Log"
                                fi
                                sleep 1
                                if grep -q "Finally" "$Log"; then
                                    echo "Jailbroken device Ok"
                                    sleep 5
                                    if [[ $Mode -eq 3 ]];then
                                        for i in {30..1}
                                        do
                                            echo "Install Silen wait..$i S"
                                            sleep 1
                                        done
                                        expect ./install_Sileo.sh
                                    fi
                                    echo "All Done"
                                    sleep 5
                                    exit 0
                                fi
                            fi
                        done
                        exit 0
                    elif [[ -f $BOOTIMG ]] && [[ -f $SEPI ]] && [[ -f $SEPP ]];then
                        echo "Booting the device"
                        sleep 3
                        while true;
                        do
                            $turdusra1n -t $BOOTIMG -i $SEPI -p $SEPP | tee "$Log"
                            sleep 1
                            if grep -q "Sent bootux" "$Log"; then
                                cp -f $BOOTIMG ./JB
                                cp -f $SEPI ./JB
                                cp -f $SEPP ./JB
                                echo "Booting device Ok"
                                sleep 10
                                exit 0
                            fi
                        done
                        exit 0
                    else
                        if [ -f "$ISPW" ] ;then
                            echo "Restoring the device"
                            sleep 3
                            $turdusra1n -D
                            sleep 3
                            $turdus_merula -y -o $ISPW | tee "$Log"
                            sleep 5
                            if grep -q "DONE" "$Log"; then
                                echo "Restoring Ok"
                                sleep 10
                                break
                            else
                                echo "Restoring Err"
                                find ./JB/ -name "$ID*" -type f -print -exec rm -rf {} \;
                                find ./image4/ -name "$ID*" -type f -print -exec rm -rf {} \;
                                find ./block/ -name "$ID*" -type f -print -exec rm -rf {} \;
                                sleep 20
                                exit 2
                            fi
                        else
                            echo "fIles: $ISPW"
                            echo "No Find"
                            sleep 10
                            exit 0
                        fi
                    fi
                else
                    echo "not supported the device"
                    echo "ECID:$ID"
                    echo "$i_CPID"
                    sleep 15
                    exit 0
                fi
            fi
        else
            if [ $tip_con -eq 0 ];then
                echo -e "waiting connect device"
                while true;do 
                    get_ecid
                    if [ $tip_con -eq 1 ];then
                        break
                    fi
                done
            fi
        fi
        ID=0
        sleep 0.5
    done
    ID=0
    echo "complete..."
    sleep 2
done