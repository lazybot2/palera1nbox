
## palera1n & checkra1n for NaonPi NEO(2)
---

![xml](doc/palebox.jpg)

![xml](doc/palebox1.jpg)

![xml](doc/palebox2.jpg)

## Installation instructions
---    

1.Download Armbian - Armbian Jammy
-   [NanoPi Neo](https://k-space.ee.armbian.com/oldarchive/nanopineo/archive/Armbian_23.8.1_Nanopineo_jammy_current_6.1.47.img.xz)
   
-   [NanoPi Neo2](https://k-space.ee.armbian.com/oldarchive/nanopineo2/archive/Armbian_23.8.1_Nanopineo2_jammy_current_6.1.47.img.xz)

2.Balena Etcher for burning the SD card

-   [Etcher](https://etcher.balena.io/)

3.SSH Connection

    Log in in with username root and default password 1234, after logging in change the password to lazybot

    When being asked to provide a username after changing the default root password, please enter lazybot as username and lazybot as password.

    Tip:
        Create root password: lazybot
        Repeat root password: lazybot
        Choose default system command shell: 1 (bash)
        Please provide a username (eg. your first name):lazybot
        Create user (lazybot) password:lazybot
        Repeat user (lazybot) password:lazybot
        Please provide your real name: Lazybot : ENter
        Set user language based on your location? [Y/n]Y
        At your location, more locales are possible: 1 

4.install

    git clone https://github.com/lazybot2/palera1nbox.git
    cd palera1nbox
    sudo chmod +x ./install.sh
    sudo ./install.sh

-   select NanoPi：0 或 1

-   0.NanoPi NEO
-   1.NanoPi NEO2

5.Turn on I2C module loading

    sudo armbian-config

    Menu System > Hardware > enable i2c0

    Save and reboot

* Palera1n function menu

> Support IOS15-16.x system, palera1n official website. The box version is: v2.0.0 beta 7

> Function menu: Rootless (no root jailbreak) --Rootfull (rooted jailbreak) --Exit Recovery (exit recovery mode) --Exit (exit back to the main menu)

> Submenu: Options --Start --Back

> Rooted Jailbreak Submenu: Create FakeFs (First Full Jailbreak (Support 32G and above phones)--Create BindFS (16G must choose this for the first jailbreak)--Safe Mode (Jailbreak into safe mode)--Restore RootFs (Clear Jailbreak)

> (The asterisk is selected) Press the rightmost button to change the selected state, and you can only choose one of the above four options. After the first jailbreak, you don't need to choose to boot the boot, just start directly.

* Checkra1n功能菜单

> Support IOS12-14.x, checkra1n official website. The box version is: 0.12.4

> Submenu setting: Options(Settings)--Run Checkran--Stop Checkra1n(Close Checkra1n process)--Exit(Return to the main menu)

> Submenu setting: Safe Mode - Revert is selected when there is an asterisk, and no need to set it for normal jailbreak.

* Turdus function menu

> Support A9(X) A10(X) no shsh downgrade, turdus merula official website. Now available for support Neo2

> Function menu: Options (Settings) --Run turdus (start fully automatic downgrade boot) --Stop turdus (Close turdus process) --Exit (Return to the main menu)

> Sub-menu settings: Safe Mode - Revert (clear the local phone archive, used when the downgrade process is abnormal) is selected when there is an asterisk, and no need to set it for normal use.

* ReBoot (for rebooting the box)

other:

	1.Download palera1nbox img for NEO
   -  [google](https://drive.google.com/drive/folders/1dJ0MHaLiGA3qyHK-HXtDJz3COD-yDQUt?usp=sharing)
   -  [baidu](https://pan.baidu.com/s/1v_ai5yPQtnU9-sPLJFLSgg?pwd=pale)提取码:pale

	2.Etcher To SD card

## [Youtube](https://www.youtube.com/playlist?list=PLv2ojzLXyelMOqk1nPhixQuGTWQnM8f3E)

## Donation

If this project does help you, please consider donating to support the development of this project.

### Alipay

![alipay](doc/alipay.jpg)

### Wechat

![wechat](doc/wechat.jpg)

### PayPal

<a href="https://www.paypal.com/paypalme/szyato"><img src="./doc/Paypal.jpg"></a>

