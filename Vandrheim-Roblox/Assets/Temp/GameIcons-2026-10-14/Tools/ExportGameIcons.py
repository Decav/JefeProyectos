"""Export production sizes and a comparison sheet without altering the artwork."""
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
labels = {'01_Jotunn': '01 · Jotunn', '02_Desafio': '02 · Desafío', '03_Reliquia': '03 · Reliquia'}
sheet = Image.new('RGB', (1080, 630), '#111925')
draw = ImageDraw.Draw(sheet)
font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 24)
small = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 18)
for index, asset in enumerate(data['assets']):
    source = Path(asset['source'])
    art = Image.open(source)
    if art.width != art.height:
        raise ValueError(f'Non-square artwork: {source}')
    if art.mode == 'RGBA' and art.getchannel('A').getextrema() != (255, 255):
        raise ValueError(f'Unexpected transparency in game icon: {source}')
    shutil.copy2(source, masters / f"Icon_Game_{asset['id']}_master.png")
    art = art.convert('RGB')
    icon = art.resize((512, 512), Image.Resampling.LANCZOS)
    output = folder / f"Icon_Game_{asset['id']}_512.png"
    icon.save(output, optimize=True)
    thumbnail = art.resize((150, 150), Image.Resampling.LANCZOS)
    thumbnail.save(previews / f"Icon_Game_{asset['id']}_150.png", optimize=True)
    x = index * 360
    draw.text((x + 20, 18), labels[asset['id']], fill='#f4ede0', font=font)
    sheet.paste(icon.resize((320, 320), Image.Resampling.LANCZOS), (x + 20, 58))
    draw.text((x + 20, 404), 'Vista real a 150 × 150', fill='#9db9cf', font=small)
    sheet.paste(thumbnail, (x + 105, 444))
    exported = Image.open(output)
    assert exported.size == (512, 512) and exported.mode == 'RGB'
    print(f"{output.name}: {exported.size}, {exported.mode}; master {art.size}")
sheet.save(folder / 'Preview_Comparison.png', optimize=True)
print('Saved Preview_Comparison.png and 150px previews.')
