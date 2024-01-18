import bakebit_128_64_oled as oled
from PIL import Image, ImageFont, ImageDraw
import time,signal,subprocess,os

phases = [
    {"message": "Prepare enter DFU", "countdown": [3, 2, 1], "is_text": True},
    {"message": "Press", "countdown": [4, 3, 2, 1, 0]},
    {"message": "Release", "countdown": [8, 7, 6, 5, 4, 3, 2, 1]}
]


background_processes = []

# Initialisation
width, height = 128, 64
image = Image.new('1', (width, height))
draw = ImageDraw.Draw(image)
font18 = ImageFont.truetype('DejaVuSansMono.ttf', 18)
font14 = ImageFont.truetype('DejaVuSansMono.ttf', 14)
font10 = ImageFont.truetype('DejaVuSansMono.ttf', 10)
bash_path =f'{os.getcwd()}/'
#command chk
if '755' != oct(os.stat(f'{bash_path}palera1n').st_mode)[-3:]:
    print('755')
    os.chmod(f'{bash_path}palera1n',0o755)
else:
    print('command is OK')
oled.init()
oled.setNormalDisplay()
oled.setHorizontalMode()

# Variables
current_menu = 'main'
cursor_position = 0
rootless_options = {'Verbose': False, 'Safe Mode': False, 'Force Revert': False, 'Debug': False}
rootfull_options = {'Create FakeFS': False, 'Create BindFS': False, 'Verbose': False, 'Safe Mode': False, 'Restore RootFS': False, 'Debug': False}
recover_options={'Exit Recovery':True}
# Mappage des arguments
rootless_arg_map = {'Verbose': '--verbose-boot ', 'Safe Mode': '--safe-mode ', 'Force Revert': '--force-revert ', 'Debug': '--debug-logging '}
rootfull_arg_map = {'Create FakeFS': '--setup-fakefs ', 'Create BindFS': '--setup-partial-fakefs ', 'Verbose': '--verbose-boot ', 'Safe Mode': '--safe-mode ', 'Restore RootFS': '--force-revert ', 'Debug': '--debug-logging '}
recover_arg_map={'Exit Recovery':'--exit-recovery'}

# Options de menu
menu_options = {
    'main': ['Rootless', 'Rootfull', 'Exit Recovery', 'Exit'],
    'rootless': ['Options', 'Start', 'Back'],
    'rootfull': ['Options', 'Start', 'Back'],
    'recover': ['Options', 'Start', 'Back'],
    'rootless_options': [],
    'rootfull_options': [],
    'recover_options': [],
}

def update_checklist_options(menu, options):
    menu_options[menu] = [f"{'[*]' if options[key] else '[ ]'} {key}" for key in options.keys()] + ["Back"]

update_checklist_options('rootless_options', rootless_options)
update_checklist_options('rootfull_options', rootfull_options)
update_checklist_options('recover_options', recover_options)

def display_menu_with_cursor(menu):
    draw.rectangle((0, 0, width, height), outline=0, fill=0)
    start_index = max(0, cursor_position - 2)
    end_index = start_index + 4
    for i, line in enumerate(menu[start_index:end_index]):
        y_position = i * 15
        text_color = 255
        if i + start_index == cursor_position:
            draw.rectangle((0, y_position, width, y_position + 14), outline=255, fill=255)
            text_color = 0
        draw.text((0, y_position), line, font=font14, fill=text_color)
    oled.drawImage(image)

def get_device_state():
    appledevice = subprocess.check_output('lsusb | grep "Apple"; exit 0', shell=True)
    # --- Check if Apple device connected ---
    if not appledevice:
        return None
    # check if DFU or recovery mode present
    devicerecovery = subprocess.check_output('lsusb | grep "Recovery"; exit 0', shell=True)
    devicedfu = subprocess.check_output('lsusb | grep "DFU"; exit 0', shell=True)
    return "dfu" if devicedfu else \
        "recovery" if devicerecovery else "normal"

def animation_connection(root_type, options):
    global current_menu, cursor_position

    draw.rectangle((0, 0, width, height), outline=0, fill=0)
    text = "Waiting DFU"
    if root_type == 'recover':
       text = "Wait Recovery"
    text_width, text_height = draw.textsize(text, font=font14)
    x_position = (width - text_width) / 2
    y_position = (height - text_height) / 2
    draw.text((x_position, y_position), text, font=font14, fill=255)
    oled.drawImage(image)
    text='dfu'
    if root_type == 'recover':
       text = 'recovery'
    while True:
        if get_device_state() == text:
            break
        time.sleep(1)
    time.sleep(1)
    execute_command(root_type, options)
    draw.rectangle((0, 0, width, height), outline=0, fill=0)
    text = "JAILBREAKING"
    text_width, text_height = draw.textsize(text, font=font14)
    x_position = (width - text_width) / 2
    y_position = (height - text_height) / 2
    draw.text((x_position, y_position), text, font=font14, fill=255)
    oled.drawImage(image)
    time.sleep(15)

    draw.rectangle((0, 0, width, height), outline=0, fill=0)
    text = "BOOTING"
    text_width, text_height = draw.textsize(text, font=font14)
    x_position = (width - text_width) / 2
    y_position = (height - text_height) / 2
    draw.text((x_position, y_position), text, font=font14, fill=255)
    oled.drawImage(image)
    time.sleep(10)

    startTime = time.time()
    while (time.time() - startTime) < 900:
        if get_device_state() == "normal":
            break
        time.sleep(1)

    draw.rectangle((0, 0, width, height), outline=0, fill=0)
    text = "All Done"
    text_width, text_height = draw.textsize(text, font=font14)
    x_position = (width - text_width) / 2
    y_position = (height - text_height) / 2
    draw.text((x_position, y_position), text, font=font14, fill=255)
    oled.drawImage(image)
    time.sleep(3)

    if get_device_state() == "normal":
        for process in background_processes:
                    process.terminate()
        subprocess.Popen(f'python3 {bash_path}menu.py', shell=True)
        exit(0)
    else:
      current_menu = 'main'
      cursor_position = 0
      display_menu_with_cursor(menu_options[current_menu])

def execute_command(root_type, options):
    cmd = ['sudo', f'{bash_path}palera1n']
    args_map = rootless_arg_map if root_type == 'rootless' else rootfull_arg_map if root_type == 'rootfull' else recover_arg_map 
    for option, is_checked in options.items():
        if is_checked:
            cmd += args_map[option].strip().split()
    if root_type == 'rootfull':
        cmd.append('--fakefs')
    process = subprocess.Popen(cmd)
    background_processes.append(process)

def receive_signal(signum, stack):
    global current_menu, cursor_position, rootless_options, rootfull_options, recover_options
    if signum == signal.SIGUSR1:  
        cursor_position = (cursor_position - 1) % len(menu_options[current_menu])
    elif signum == signal.SIGUSR2:  
        cursor_position = (cursor_position + 1) % len(menu_options[current_menu])
    elif signum == signal.SIGALRM:  
        if current_menu == 'main':
            if cursor_position == 0:
                current_menu = 'rootless'
                cursor_position = 0
            elif cursor_position == 1:
                current_menu = 'rootfull'
                cursor_position = 0
            elif cursor_position == 2:
                current_menu = 'recover'
                cursor_position = 0
            elif cursor_position == 3:
                for process in background_processes:
                    process.terminate()
                subprocess.Popen(f'python3 {bash_path}menu.py', shell=True)
                exit(0)
        elif current_menu in ['rootless', 'rootfull','recover']:
            if cursor_position == 0:
                current_menu = f"{current_menu}_options"
                cursor_position = 0
            elif cursor_position == 1:
                animation_connection(current_menu, rootless_options if current_menu == 'rootless' else rootfull_options if current_menu == 'rootfull' else recover_options)
            elif cursor_position == 2:
                current_menu = 'main'
                cursor_position = 0
        elif current_menu.endswith('_options'):
            root_type = current_menu.split('_')[0]
            option_keys = list(rootless_options.keys() if root_type == 'rootless' else rootfull_options.keys()  if root_type == 'rootfull' else recover_options.keys() )
            if cursor_position == len(option_keys):
                current_menu = root_type
                cursor_position = 0
            else:
                selected_option = option_keys[cursor_position]
                if root_type == 'rootless':
                    rootless_options[selected_option] = not rootless_options[selected_option]
                elif root_type == 'recover':
                    recover_options[selected_option] = not recover_options[selected_option]
                else:
                    rootfull_options[selected_option] = not rootfull_options[selected_option]
                update_checklist_options(current_menu, rootless_options if root_type == 'rootless' else rootfull_options if root_type == 'rootfull' else recover_options)
    display_menu_with_cursor(menu_options[current_menu])

def display_start():
    ver_text='For Ios15-16.x'
    ver_text_width,ver_text_hight=draw.textsize(ver_text, font=font14)
    image_path = f"{bash_path}palera1n.png"
    anim_img = Image.open(image_path).convert('1')
    draw1=ImageDraw.Draw(anim_img)
    for i in range(1, len(ver_text)+1):  
        draw1.text((width-ver_text_width-2,height-ver_text_hight-3), ver_text[0:i], font=font14, fill=255)
        oled.drawImage(anim_img)
    return 1

def main():
    signal.signal(signal.SIGUSR1, receive_signal)
    signal.signal(signal.SIGUSR2, receive_signal)
    signal.signal(signal.SIGALRM, receive_signal)  

    start_en=0
    start_time=time.time()
    while True:
        if  start_en==0:
            display_start()
            start_en+=1
        elif start_en==1:
            if time.time()-start_time>5:
                start_en+=1
        elif start_en==2:
            display_menu_with_cursor(menu_options[current_menu])
            start_en+=1
        time.sleep(0.2)

if __name__ == "__main__":
    main()


