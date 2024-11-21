#!/bin/bash

clear
echo '==========================='
echo 'please select NanoPi'
echo '0.NanoPi NEO'
echo '1.NanoPi NEO2'
echo '==========================='
read nanopi
case $nanopi in
    0)
    echo 'select is NanoPi neo'
    ;;
    1)
    echo 'select is NanoPi neo2'
    ;;
    *)
    echo 'No'
    exit;;
esac
usermod -a lazybot -G root
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y i2c-tools git wget vim gcc python3 python3-dev python3-pil python3-smbus python3-pip python3-serial 
sudo pip3 install --upgrade setuptools
sudo pip3 install sh
sudo pip3 install wheel
sudo pip3 install psutil
sudo apt-get install -y  libc6 libncurses5 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libatk1.0-0 libgdk-pixbuf2.0-0 libglib2.0-0 libfontconfig1 \
 libfreetype6 libgtk-3-0 libusb-1.0-0 libplist3 usbmuxd ideviceinstaller python3-imobiledevice libimobiledevice-utils python3-plist ifuse libusbmuxd-tools \
 libjpeg-dev pkg-config libplist-dev libreadline-dev libusb-1.0-0-dev libssl-dev libffi-dev
if [ ! -f /usr/bin/python3 ]; then
    echo "/usr/bin/python3 not found, exiting."
    exit 1
fi

PY3_INTERP=`readlink /usr/bin/python3`
RET=$?
if [ $? -ne 0 ]; then
    echo "No executable python3, exiting."
    exit 1
fi
REAL_PATH=$(realpath $(dirname $0))
sed -i "/^#define.*PYTHON3_INTERP.*$/s/\".*\"/\"${PY3_INTERP}\"/" "${REAL_PATH}/Source/daemonize.h"

echo ""
echo "Compiling with GCC ..."
echo "======================="
gcc Source/daemonize.c Source/main.c -lrt -lpthread -o NanoHatOLED
echo "Compiled NanoHatOLED"

if [ ! -f $PWD/NanoHatOLED ]; then
    echo "$PWD/NanoHatOLED not found, exiting."
    exit 1
fi

if [ ! -f /usr/local/bin/oled-start ]; then
    cat >/usr/local/bin/oled-start <<EOL
#!/bin/sh
EOL
    echo "rm -rf /tmp/* " >> /usr/local/bin/oled-start
    echo "cd $PWD" >> /usr/local/bin/oled-start
    echo "./NanoHatOLED" >> /usr/local/bin/oled-start
    sed -i -e '$i \/usr/local/bin/oled-start\n' /etc/rc.local
    chmod 755 /usr/local/bin/oled-start
fi
case $nanopi in
    0)
    wget -O checkra1n https://assets.checkra.in/downloads/linux/cli/arm/ff05dfb32834c03b88346509aec5ca9916db98de3019adf4201a2a6efe31e9f5/checkra1n
    wget -O palera1n https://github.com/palera1n/palera1n/releases/download/v2.0.0-beta.7/palera1n-linux-armel
    ;;
    1)
    wget -O checkra1n https://assets.checkra.in/downloads/linux/cli/arm64/43019a573ab1c866fe88edb1f2dd5bb38b0caf135533ee0d6e3ed720256b89d0/checkra1n
    wget -O palera1n https://github.com/palera1n/palera1n/releases/download/v2.0.0-beta.7/palera1n-linux-arm64
    ;;
esac
sudo chmod +x ./NanoHatOLED
sudo chmod +x ./checkra1n
sudo chmod +x ./palera1n
sudo rm -rf ./.git
sudo rm -rf ./doc
sudo apt-get remove -y gcc git wget curl vim
du -h /var/cache/apt/archives
sudo apt-get autoclean -y
sudo apt-get clean -y
sudo apt-get autoremove -y
du -sh /root/.cache
sudo rm -rf /var/tmp/*
sudo rm -rf /tmp/*
git clone https://github.com/armbian/config
cd config
bash debian-config




