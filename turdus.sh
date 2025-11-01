#!/bin/bash
turdusra1n="sudo ./turdusra1n"
turdus_merula="sudo ./turdus_merula"
checkra1n="sudo ./checkra1n"
irecovery="sudo irecovery"
Mode=""
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
if [[ "$*" =~ "--safe-mode" ]];then
    Mode=1
elif  [[ "$*" =~ "--force-revert" ]];then
    Mode=2
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
get_ecid(){
    div=`lsusb | grep "Apple" `
    dfu=`lsusb | grep "DFU" `
    if [ ! -z "$div" ]; then
        tip_con=1
        if [ ! -z "$dfu" ]; then
            #echo 'YES'
            ECID=`$irecovery -q | grep "ECID"`
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

if true;then
    file_name=("6s" "6sp" "5se" "ipad97" "ipad5" "i7" "i7p" "ipod7" "ipad7" "ipadp129-2" "ipadp10")
    usb_path="/media/"
    ipsw_path="/root/palera1nbox/IPSW/"
    # 使用for循环遍历数组
    for name in "${file_name[@]}"
    do
        copyfile=`find "$usb_path" -maxdepth 4 -name "$name.ipsw"`
        if [[ -f $copyfile ]];then
            echo "copy $name.ipsw to IPSW/"
            sleep 10
            rsync -avP "$copyfile" "$ipsw_path"
            sleep 10
        fi
    done
fi
echo "Lazy Bot Auto turdus" 
echo "Tethered Downgrade Guide"
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
            #echo "-----开始越狱-----" 
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
                        echo "$i"
                        sleep 1
                    done
                    find ./JB/ -name "$ID*" -type f -print -exec rm -rf {} \;
                    find ./image4/ -name "$ID*" -type f -print -exec rm -rf {} \;
                    find ./block/ -name "$ID*" -type f -print -exec rm -rf {} \;
                    exit
                elif [[ $Mode -eq 1 ]];then
                    echo " safe-mode JB"
                    sleep 3
                fi
                if [ $CHK ];then
                    echo "Jailbroken the device"
                    sleep 3
                    while true;
                    do  
                        if [[ $Mode -eq 1 ]];then
                            $turdusra1n -srTP $CHK | tee ./run.log
                        else
                            $turdusra1n -rTP $CHK | tee ./run.log
                        fi
                        sleep 1
                        if grep -q "Finally" ./run.log; then
                            echo "Jailbroken device Ok"
                            sleep 5
                            echo "All Done"
                            sleep 5
                            exit
                        fi
                    done
                    exit
                elif [ $PTE ];then
                    echo "Booting the device"
                    while true;
                    do
                        $turdusra1n -TP $PTE | tee ./run.log
                        sleep 1
                        if grep -q "Sent bootux" ./run.log; then
                            cp -f $PTE ./JB
                            echo "Booting device Ok"
                            sleep 10
                            exit
                        fi
                    done
                elif [[ -f $CURRENT ]] && [[ -f $SEP ]];then
                    while true;
                    do
                        $turdusra1n -g -i $SEP -C $CURRENT | tee ./run.log
                        sleep 1
                        if grep -q ".bin saved to" ./run.log; then
                            echo -e "pteblock Ok"
                            sleep 15
                            break
                        fi
                    done
                    break
                elif [ $RESTORE ];then
                    if [ $SEP ];then
                        if [ $update -eq 1 ];then
                            tmp=1
                        else
                            tmp=2
                        fi
                        if [[ $tmp -eq 2 ]];then
                            echo "Restoring the device"
                            sleep 3
                            if [ -f "$ISPW" ] ;then
                                $turdusra1n -D
                                sleep 5
                                $turdus_merula -y -o --load-shcblock $RESTORE $ISPW  | tee ./run.log
                                sleep 1
                                if grep -q "DONE" ./run.log; then
                                    echo "Restoring Ok"
                                    sleep 15
                                    update=1
                                    break
                                fi
                                sleep 3
                                break
                            else
                                echo "fIles: $ISPW"
                                echo "No Find"
                                sleep 10
                                exit
                            fi
                        elif [[ $tmp -eq 1 ]];then
                            while true;
                            do
                                $turdusra1n -g | tee ./run.log
                                sleep 1
                                if grep -q ".bin saved to" ./run.log; then
                                    echo -e "current shcblock OK"
                                    sleep 15
                                    break
                                fi
                            done
                            break
                        fi
                    else
                        echo "Restoring the device"
                        sleep 3
                        if [ -f "$ISPW" ] ;then
                            $turdusra1n -D
                            sleep 5
                            $turdus_merula -y -o --load-shcblock $RESTORE $ISPW  | tee ./run.log
                            sleep 1
                            if grep -q "DONE" ./run.log; then
                               echo "Restoring Ok"
                                sleep 15
                                update=1
                                break
                            fi
                            sleep 3
                            break
                        else
                            echo "fIles: $ISPW"
                            echo "No Find"
                            sleep 10
                            exit
                        fi
                    fi
                else
                    if [[ -f "$ISPW" ]] ;then
                        $turdusra1n -D
                        sleep 3
                        while true;
                        do
                            $turdus_merula -y --get-shcblock $ISPW | tee ./run.log
                            sleep 1
                            if grep -q ".bin saved to" ./run.log; then
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
                        exit
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
                    echo "Clear All file $IDs"
                    for i in {10..1}
                    do
                        echo "$i"
                        sleep 1
                    done
                    find ./JB/ -name "$ID*" -type f -print -exec rm -rf {} \;
                    find ./image4/ -name "$ID*" -type f -print -exec rm -rf {} \;
                    find ./block/ -name "$ID*" -type f -print -exec rm -rf {} \;
                    exit
                elif [[ $Mode -eq 1 ]];then
                    echo "safe-mode Jailbroken"
                    sleep 3
                fi
                if [[ -f $JB_BOOTIMG ]] && [[ -f $JB_SEPI ]] && [[ -f $JB_SEPP ]];then
                    echo "Jailbroken the device"
                    sleep 3
                    while true;
                    do  
                        if [[ $Mode -eq 1 ]];then
                            $turdusra1n -srt $JB_BOOTIMG -i $JB_SEPI -p $JB_SEPP | tee ./run.log
                        else
                            $turdusra1n -rt $JB_BOOTIMG -i $JB_SEPI -p $JB_SEPP | tee ./run.log
                        fi
                        sleep 1
                        if grep -q "Finally" ./run.log; then
                            echo "Jailbroken device Ok"
                            sleep 5
                            echo "All Done"
                            sleep 5
                            exit
                        fi
                    done
                    exit
                elif [[ -f $BOOTIMG ]] && [[ -f $SEPI ]] && [[ -f $SEPP ]];then
                    echo "Booting the device"
                    sleep 3
                    while true;
                    do
                        $turdusra1n -t $BOOTIMG -i $SEPI -p $SEPP | tee ./run.log
                        sleep 1
                        if grep -q "Sent bootux" ./run.log; then
                            cp -f $BOOTIMG ./JB
                            cp -f $SEPI ./JB
                            cp -f $SEPP ./JB
                            echo "Booting device Ok"
                            sleep 10
                            exit
                        fi
                    done
                    exit
                else

                    if [ -f "$ISPW" ] ;then
                        echo "Restoring the device"
                        sleep 3
                        update=0
                        $turdusra1n -D
                        sleep 3
                        $turdus_merula -y -o $ISPW | tee ./run.log
                        sleep 1
                        if grep -q "DONE" ./run.log; then
                            echo "Restoring Ok"
                            sleep 15
                            update=1
                            break
                        fi
                    else
                        echo "fIles: $ISPW"
                        echo "No Find"
                        sleep 10
                        exit
                    fi
                fi
            else
                echo "not supported the iphone"
                echo "ECID:$ID"
                echo "$i_CPID"
                sleep 15
                exit
            fi
        else
            if [ $tip_con -eq 0 ];then
                echo -e "waiting connect iphone"
                while true;do 
                    get_ecid
                    if [ $tip_con -eq 1 ];then
                        break
                    fi
                done
            fi
        fi
        ID=0
        sleep 5
    done
    ID=0
    echo "complete..."
    sleep 2
done