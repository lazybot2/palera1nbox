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
sudo apt-get install -y i2c-tools git wget vim python3-dev python3-pil python3-smbus python3-pip python3-serial 
sudo pip3 install --upgrade setuptools
sudo pip3 install sh
sudo pip3 install wheel
sudo pip3 install psutil
sudo apt-get install -y  libc6 libncurses5 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libatk1.0-0 libgdk-pixbuf2.0-0 libglib2.0-0 libfontconfig1 \
 libfreetype6 libgtk-3-0 libusb-1.0-0 libplist3 usbmuxd ideviceinstaller python3-imobiledevice libimobiledevice-utils python3-plist ifuse libusbmuxd-tools \
 libjpeg-dev pkg-config libplist-dev libreadline-dev libusb-1.0-0-dev build-essential checkinstall autoconf automake libtool-bin
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
    sudo rm -f ./NanoHatOLED-neo2
    ;;
    1)
    wget -O checkra1n https://assets.checkra.in/downloads/linux/cli/arm64/43019a573ab1c866fe88edb1f2dd5bb38b0caf135533ee0d6e3ed720256b89d0/checkra1n
    wget -O palera1n https://github.com/palera1n/palera1n/releases/download/v2.0.0-beta.7/palera1n-linux-arm64
    sudo rm -f ./NanoHatOLED
    mv ./NanoHatOLED-neo2 ./NanoHatOLED
    ;;
esac
sudo chmod +x ./NanoHatOLED
sudo chmod +x ./checkra1n
sudo chmod +x ./palera1n
sudo apt-get install -y armbian-config=24.2.1
du -h /var/cache/apt/archives
sudo apt-get autoclean -y
sudo apt-get clean -y
sudo apt-get autoremove -y
sudo armbian-config




