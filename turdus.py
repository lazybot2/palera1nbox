import subprocess,psutil,os,signal,time
from PIL import Image, ImageFont, ImageDraw
import bakebit_128_64_oled as oled
import re
# Initialisation avec gestion d'exception
def init_oled():
    try:
        oled.init()
        oled.setNormalDisplay()
        oled.setHorizontalMode()
    except Exception as e:
        print(f"Erreur d'initialisation de l'OLED: {e}")

# Variables globales
width, height = 128, 64
image = Image.new('1', (width, height))
draw = ImageDraw.Draw(image)
font14 = ImageFont.truetype('DejaVuSansMono.ttf', 14)
font_small = ImageFont.truetype('DejaVuSansMono.ttf', 9)  # Taille de police plus petite
bash_path = f'{os.getcwd()}/'
#command chk
if '755' != oct(os.stat(f'{bash_path}turdus.sh').st_mode)[-3:]:
    print('755')
    os.chmod(f'{bash_path}turdus.sh',0o755)
else:
    print('command is OK')
# Options de menu et état
menu_options = {
    'main': ['Options', 'Run turdus', 'Stop turdus', 'Exit'],
    'options': ['Safe Mode', 'Revert', 'SHSH', 'Back']
}
current_menu = 'main'
cursor_position = 0
options = {'Safe Mode': False, 'Revert': False, 'SHSH': False}
arg_map = {'Safe Mode': '--safe-mode', 'Revert': '--force-revert', 'SHSH': '--shsh2'}
background_processes = []
manage_close = 0
# Mise à jour des options de checklist
def update_checklist_options():
    menu_options['options'] = [f"{'[*]' if options[key] else '[ ]'} {key}" for key in options.keys()] + ["Back"]
update_checklist_options()

# Affichage du menu avec le curseur
def display_menu_with_cursor():
    try:
        draw.rectangle((0, 0, width, height), outline=0, fill=0)
        start_index = max(0, cursor_position - 2)
        end_index = start_index + 4
        for i, line in enumerate(menu_options[current_menu][start_index:end_index]):
            y_position = i * 15
            if i + start_index == cursor_position:
                draw.rectangle((0, y_position, width, y_position + 14), outline=255, fill=255)
                draw.text((0, y_position), line, font=font14, fill=0)
            else:
                draw.text((0, y_position), line, font=font14, fill=255)
        oled.drawImage(image)
    except Exception as e:
        print(f"Erreur d'affichage: {e}")

# Exécution de Checkra1n avec gestion d'exception
def run_checkra1n():
    out_en=False
    try:
        #subprocess.call(['sudo', 'systemctl', 'restart', 'usbmuxd'])
        cmd = ['bash', f'{bash_path}turdus.sh']
        cmd += [arg_map[option] for option, is_checked in options.items() if is_checked]
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, shell=False)
        background_processes.append(process)
        output_lines = []
        for line in process.stdout:
            output_lines.append(line)
            display_message_scroll(output_lines)  # Met à jour l'affichage avec scroll
            print(line.strip())
            if "All Done" in line:
                time.sleep(3)
                exit_program()
    except Exception as e:
        display_message(f"Erreur: {e}")

# Tuer les processus en arrière-plan
def kill_checkra1n():
    try:
        pids = psutil.pids()
        for pid in pids:
            p = psutil.Process(pid)
            process_name=p.name()
            #print(f"PID: {pid}, 名称: {p.name()}")
            if 'turdus.sh' == process_name:
                os.kill(pid, signal.SIGKILL)
            elif 'turdus_merula' == process_name:
                os.kill(pid, signal.SIGKILL)
            elif 'turdusra1n' == process_name:
                os.kill(pid, signal.SIGKILL)
            elif 'rsync' == process_name:
                os.kill(pid, signal.SIGKILL)
    except Exception as e:
        display_message(f"E: {e}")
        #print(f"E: {e}")
        
def display_message(message):
    try:
        draw.rectangle((0, 0, width, height), outline=0, fill=0)
        draw.text((0, 0), message, font=font14, fill=255)
        oled.drawImage(image)
        time.sleep(2)  # Affiche le message pendant 2 secondes
    except Exception as e:
        print(f"Erreur d'affichage: {e}")

def display_message_scroll(lines):
    draw.rectangle((0, 0, width, height), outline=0, fill=0)
    start_line = max(len(lines) -6, 0)  # Affiche les 8 dernières lignes
    for i, line in enumerate(lines[start_line:start_line +6]):
        draw.text((0, i * 10),  re.sub(r'.*?]','',re.sub(r'.*?>.','',re.sub(r'\033\[[0-9;]+m', '', line))), font=font_small, fill=255)
    oled.drawImage(image)

def kill_background_processes():
    for process in background_processes:
        try:
            process.kill()
        except Exception as e:
            print(f"Erreur lors de la fermeture du processus: {e}")
    background_processes.clear()

# Gestion des signaux pour les boutons
def receive_signal(signum, stack):
    global current_menu, cursor_position, manage_close
    try:
        if signum == signal.SIGUSR1:  # Bouton 1
            cursor_position = (cursor_position - 1) % len(menu_options[current_menu])
            display_menu_with_cursor()
        elif signum == signal.SIGUSR2:  # Bouton 2
            cursor_position = (cursor_position + 1) % len(menu_options[current_menu])
            display_menu_with_cursor()
        elif signum == signal.SIGALRM:  # Bouton 3
            manage_selection()
            if manage_close == 0:
                display_menu_with_cursor()
    except Exception as e:
        print(f"Erreur de signal: {e}")

# Gestion de la sélection dans le menu
def manage_selection():
    global current_menu, cursor_position, manage_close
    if current_menu == 'main':
        if cursor_position == 0:
            current_menu = 'options'
            cursor_position = 0
            manage_close=0
        elif cursor_position == 1:
            if manage_close == 0:
                manage_close = 1
                kill_background_processes()
                time.sleep(0.1)
                kill_checkra1n()
                time.sleep(0.1)
                oled.clearDisplay()
                run_checkra1n()
                manage_close = 0
        elif cursor_position == 2:
            kill_background_processes()
            time.sleep(0.1)
            kill_checkra1n()  # Modification ici
            manage_close=0
        elif cursor_position == 3:
            exit_program()
            manage_close=0
    elif current_menu == 'options':
        if cursor_position == len(options):
            current_menu = 'main'
            cursor_position = 0
        else:
            selected_option = list(options.keys())[cursor_position]
            options[selected_option] = not options[selected_option]
            update_checklist_options()

# Fonction pour quitter le programme
def exit_program():
    kill_background_processes()
    time.sleep(0.1)
    kill_checkra1n()
    subprocess.Popen(f'python3 {bash_path}menu.py', shell=True)
    exit(0)

def display_start():
    cmd = "hostname -I | cut -d\' \' -f1"
    IP = subprocess.check_output(cmd, shell=True).decode("utf-8")
    if len(IP) < 2:
        IP ="No Network"
    else:
        IP="IP:"+IP.strip( '\n')

    ver_text='For A9(X)A10(X)'
    ver_text_width,ver_text_hight=draw.textsize(ver_text, font=font14)
    IP_width,IP_hight=draw.textsize(IP, font=font_small)

    image_path = f"{bash_path}turdus.png"
    anim_img = Image.open(image_path).convert('1')
    draw1=ImageDraw.Draw(anim_img)
    draw1.text((width-IP_width-6,height-IP_hight-ver_text_hight-7), IP, font=font_small, fill=255)  
    for i in range(1, len(ver_text)+1):
        draw1.text((width-ver_text_width-2,height-ver_text_hight-3), ver_text[0:i], font=font14, fill=255)
        oled.drawImage(anim_img)
    return 1

def main():
    init_oled()
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
            display_menu_with_cursor()
            start_en+=1
        time.sleep(0.2)

if __name__ == "__main__":
    main()
