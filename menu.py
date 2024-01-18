import bakebit_128_64_oled as oled
from PIL import Image, ImageFont, ImageDraw
import time
import signal
import os
import subprocess

# Définition des dimensions de l'écran
width = 128
height = 64
bash_path = f'{os.getcwd()}/'
#f"{bash_path}"
# Initialise un nouveau groupe de processus
os.setpgrp()

# Initialisation de l'écran OLED
oled.init()
oled.setNormalDisplay()
oled.setHorizontalMode()

font14 = ImageFont.truetype('DejaVuSansMono.ttf', 14)

# Création de l'image et du contexte de dessin
image = Image.new('1', (width, height))
draw = ImageDraw.Draw(image)
# Définition des options avec leurs images et commandes associées
options = [
    {"image": f"{bash_path}menu_palera1n.png", "command": f"sudo python3 {bash_path}palera1n.py"},
    {"image": f"{bash_path}menu_checkra1n.png", "command": f"sudo python3 {bash_path}checkra1n.py"},
    {"image": f"{bash_path}menu_reboot.png", "command": "sudo shutdown -r now"}
]

current_option_index = 0
in_reboot_confirmation = False
reboot_confirmation_option = "YES"  # Commence par "YES"
startTime = time.time()
outTime = 30
def display_image():
    image_path = options[current_option_index]['image']
    image = Image.open(image_path)
    oled.drawImage(image.convert('1'))  # Convertit l'image en noir et blanc

def display_reboot_confirmation():
    global reboot_confirmation_option
    clear_screen()  # Fonction pour effacer l'écran
    draw.text((10, 0), "Reboot?", font=font14, fill=255)
    
    # Affiche les options avec un curseur
    if reboot_confirmation_option == "YES":
        draw.rectangle((10, 20, 50, 35), outline=255, fill=255)  # Rectangle blanc pour "YES"
        draw.text((10, 20), "YES", font=font14, fill=0)  # Texte en noir
        draw.text((60, 20), "NO", font=font14, fill=255)  # Texte en blanc pour "NO"
    else:
        draw.rectangle((60, 20, 100, 35), outline=255, fill=255)  # Rectangle blanc pour "NO"
        draw.text((10, 20), "YES", font=font14, fill=255)  # Texte en blanc pour "YES"
        draw.text((60, 20), "NO", font=font14, fill=0)  # Texte en noir

    oled.drawImage(image)

def execute_option():
    global in_reboot_confirmation, reboot_confirmation_option
    command = options[current_option_index]['command']

    if current_option_index == len(options) - 1:  # L'index de l'option "Reboot"
        in_reboot_confirmation = True
        reboot_confirmation_option = "YES"
        display_reboot_confirmation()
    elif command:
        subprocess.Popen(command, shell=True, preexec_fn=os.setsid)
        os.killpg(0, signal.SIGTERM)  # Tue tous les processus dans le groupe actuel

def navigate_options(signum, stack):
    global current_option_index,startTime
    if signum == signal.SIGUSR1:  # Bouton 1: navigation vers le haut
        startTime = time.time()
        current_option_index = (current_option_index - 1) % len(options)
    elif signum == signal.SIGUSR2:  # Bouton 2: navigation vers le bas
        startTime = time.time()
        current_option_index = (current_option_index + 1) % len(options)
    display_image()
    
def validate_option(signum, stack):
    global startTime
    if time.time()-startTime > outTime:
        startTime = time.time()
        display_image()
    else:
        startTime = time.time()
        execute_option()

def navigate_reboot_confirmation(signum, stack):
    global reboot_confirmation_option
    if signum == signal.SIGUSR1:  # Bouton 1: sélectionner "YES"
        reboot_confirmation_option = "YES"
    elif signum == signal.SIGUSR2:  # Bouton 2: sélectionner "NO"
        reboot_confirmation_option = "NO"

    display_reboot_confirmation()

def validate_reboot_confirmation(signum, stack):
    global in_reboot_confirmation
    if reboot_confirmation_option == "YES":
        clear_screen()
        # Centre le message "Rebooting !" sur l'écran
        text = "Rebooting !"
        w, h = draw.textsize(text, font=font14)
        x = (width - w) // 2
        y = (height - h) // 2
        draw.text((x, y), text, font=font14, fill=255)
        oled.drawImage(image)
        time.sleep(3)  # Affiche le message pendant 3 secondes
        subprocess.Popen("sudo shutdown -r now", shell=True)
    else:
        in_reboot_confirmation = False
        display_image()  # Revenir à l'affichage normal

def clear_screen():
    global draw, image
    draw.rectangle((0, 0, width, height), outline=0, fill=0)
    oled.drawImage(image)

def get_device_state():
    appledevice = subprocess.check_output('lsusb | grep "Apple"; exit 0', shell=True)
    # --- Check if Apple device connected ---
    if not appledevice:
        return False
    # check if DFU or recovery mode present
    devicerecovery = subprocess.check_output('lsusb | grep "Recovery"; exit 0', shell=True)
    devicedfu = subprocess.check_output('lsusb | grep "DFU"; exit 0', shell=True)
    return "dfu" if devicedfu else \
        "recovery" if devicerecovery else "normal"


if __name__ == "__main__":
    signal.signal(signal.SIGUSR1, navigate_options)
    signal.signal(signal.SIGUSR2, navigate_options)
    signal.signal(signal.SIGALRM, validate_option)
    
    display_image()  # Affiche l'image de bienvenue au démarrage
    startTime = time.time()
    Close_EN=True
    while True:
        if (time.time() - startTime) > outTime:
            if get_device_state():
                print('iphone')
                startTime = time.time()
                display_image()
            elif Close_EN:
                oled.clearDisplay()
                Close_EN=False
        elif in_reboot_confirmation:
            signal.signal(signal.SIGUSR1, navigate_reboot_confirmation)
            signal.signal(signal.SIGUSR2, navigate_reboot_confirmation)
            signal.signal(signal.SIGALRM, validate_reboot_confirmation)
            Close_EN=True
        else:
            signal.signal(signal.SIGUSR1, navigate_options)
            signal.signal(signal.SIGUSR2, navigate_options)
            signal.signal(signal.SIGALRM, validate_option)
            Close_EN=True
        time.sleep(0.2)
        
        
