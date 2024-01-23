import bakebit_128_64_oled as oled
from PIL import Image, ImageFont, ImageDraw
import os
from random import randint

width = 128
height = 64
bash_path =f'{os.getcwd()}/'
image = Image.new('1', (width, height))
draw = ImageDraw.Draw(image)
font18 = ImageFont.truetype('DejaVuSansMono.ttf', 22)
font10 = ImageFont.truetype('DejaVuSansMono.ttf', 13)
text='PaleBox'
name='lazybot'
os.setpgrp()
def draw_drop(draw, x, y, r):
    draw.ellipse((x, y, x+r, y+r+3), outline="white", fill="white")
def draw_text(draw, text, x, y,font):
    draw.text((x, y), text, font=font, fill="white")    

oled.init()
oled.setNormalDisplay()
oled.setHorizontalMode()

def bb(text,name):
    x_tab=[]
    y_tab=[]
    textlen=1
    text_width, text_height = draw.textsize(text, font=font18)
    name_width, name_height=draw.textsize(name, font=font10)
    x=1
    y=3
    bb_r=1
    tmp=(width-name_width)//len(text)
    for i in range(randint(12,18)):
        x_tab.append(randint(3,128))
        y_tab.append(randint(0,64))
    for i in range(23):
        draw.rectangle((0, 0, width, height), outline=0, fill=0)
        draw_text(draw, text[(len(text)-textlen):len(text)], x, (height-text_height)//2,font18)
        draw_text(draw, name, (width-(textlen-1)*tmp), (height-name_height-2),font10)
        if textlen<len(text):
            textlen+=1
        else:
            for k in range(len(x_tab)):
                draw_drop(draw, x_tab[k], (y_tab[k]+y+randint(0,3))%64,bb_r)
            y+=randint(6,9)
        if x<(width - text_width) / 2:
            x+=2
        oled.drawImage(image)

if __name__ == "__main__":
    oled.clearDisplay()
    bb(text,name)
    print(f'run python3 {bash_path}menu.py')
    os.system(f'python3 {bash_path}menu.py')
    exit(0)