"""Preserve original icon art and export consistent transparent HUD sizes."""
from pathlib import Path
import json
import shutil
from PIL import Image, ImageDraw, ImageFont

folder = Path(__file__).resolve().parents[1]
data = json.loads((folder / 'prompts.json').read_text(encoding='utf-8'))
masters = folder / 'Masters'
previews = folder / 'Previews'
masters.mkdir(exist_ok=True)
previews.mkdir(exist_ok=True)
labels = ['Dungeon', 'Guía de dungeon', 'Grupos', 'Cambiar objetivo']
board = Image.new('RGB', (1024, 450), '#211916')
draw = ImageDraw.Draw(board)
font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 23)
small = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 16)
for i, asset in enumerate(data['assets']):
    source = Path(asset['source'])
    original = Image.open(source)
    if original.mode != 'RGBA' or original.getchannel('A').getextrema() != (0, 255):
        raise ValueError(f'Required genuine RGBA transparency missing: {source}')
    shutil.copy2(source, masters / (asset['id'] + '_master.png'))
    alpha = original.getchannel('A')
    bounds = alpha.point(lambda v: 255 if v > 8 else 0).getbbox()
    left, top, right, bottom = bounds
    bounds = (max(0,left-8),max(0,top-8),min(original.width,right+8),min(original.height,bottom+8))
    art = original.crop(bounds)
    art.thumbnail((420,420),Image.Resampling.LANCZOS)
    icon = Image.new('RGBA',(512,512),(0,0,0,0))
    icon.alpha_composite(art,((512-art.width)//2,(512-art.height)//2))
    icon.save(folder / (asset['id'] + '.png'),optimize=True)
    for size in [24,32,48]:
        icon.resize((size,size),Image.Resampling.LANCZOS).save(previews / f"{asset['id']}_{size}.png",optimize=True)
    x = i*256
    board.paste(icon.resize((224,224),Image.Resampling.LANCZOS),(x+16,20),icon.resize((224,224),Image.Resampling.LANCZOS))
    draw.text((x+16,265),labels[i],fill='#f4ede0',font=font)
    draw.text((x+32,310),'32 px',fill='#b8aa96',font=small)
    draw.text((x+151,310),'24 px',fill='#b8aa96',font=small)
    for size,offset in [(32,38),(24,160)]:
        thumb=icon.resize((size,size),Image.Resampling.LANCZOS)
        board.paste(thumb,(x+offset,345),thumb)
    with Image.open(folder / (asset['id'] + '.png')) as saved:
        assert saved.size==(512,512) and saved.mode=='RGBA'
        assert saved.getchannel('A').getextrema()==(0,255)
        assert saved.getpixel((0,0))[3]==0 and saved.getpixel((511,511))[3]==0
    print(asset['id'], original.size, '-> 512x512 RGBA, alpha 0..255')
board.save(folder/'Preview_Micromenu.png',optimize=True)

# Original and new icons on a common black field for comparing visual families.
refs=data['references']
styleboard=Image.new('RGB',(1024,620),'#000000')
style_draw=ImageDraw.Draw(styleboard)
style_draw.text((20,12),'Referencias existentes',fill='#f4ede0',font=font)
for i,path in enumerate(refs):
    image=Image.open(path).convert('RGB').resize((220,220),Image.Resampling.LANCZOS)
    styleboard.paste(image,(20+i*256,50))
style_draw.text((20,300),'Nuevos iconos',fill='#f4ede0',font=font)
for i,asset in enumerate(data['assets']):
    image=Image.open(folder/(asset['id']+'.png')).resize((220,220),Image.Resampling.LANCZOS)
    styleboard.paste(image,(20+i*256,350),image)
styleboard.save(folder/'Preview_StyleMatch.png',optimize=True)
