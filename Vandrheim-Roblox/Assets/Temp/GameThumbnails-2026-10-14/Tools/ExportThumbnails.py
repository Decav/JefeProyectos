"""Export exact 16:9 delivery files and a visual comparison of generated artwork."""
from pathlib import Path
import json
import shutil
from PIL import Image, ImageOps, ImageDraw, ImageFont

folder = Path(__file__).resolve().parents[1]
data = json.loads((folder / 'prompts.json').read_text(encoding='utf-8'))
masters = folder / 'Masters'
masters.mkdir(exist_ok=True)
labels = ['01 · Desafío de Jotunn', '02 · Reliquia de Helada']
board = Image.new('RGB', (1600, 520), '#111925')
draw = ImageDraw.Draw(board)
font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 26)
for i, asset in enumerate(data['assets']):
    source = Path(asset['source'])
    art = Image.open(source)
    if abs(art.width / art.height - 16 / 9) > 0.02:
        raise ValueError(f'Unexpected source aspect ratio: {art.size}')
    if art.mode == 'RGBA' and art.getchannel('A').getextrema() != (255, 255):
        raise ValueError(f'Unexpected transparent background: {source}')
    shutil.copy2(source, masters / f"Thumbnail_Game_{asset['id']}_master.png")
    art = art.convert('RGB')
    # Correct the slight native aspect rounding with a centered fit, preserving proportions.
    output = ImageOps.fit(art, (1920, 1080), method=Image.Resampling.LANCZOS)
    stem = f"Thumbnail_Game_{asset['id']}_1920x1080"
    output.save(folder / (stem + '.png'), optimize=True)
    jpg_path = folder / (stem + '.jpg')
    for quality in [95, 92, 90, 87, 85]:
        output.save(jpg_path, quality=quality, subsampling=0, optimize=True)
        if jpg_path.stat().st_size < 3_000_000:
            break
    else:
        raise ValueError('JPEG exceeds the thumbnail upload-size target')
    with Image.open(jpg_path) as saved:
        assert saved.size == (1920, 1080) and saved.mode == 'RGB'
    x = i * 800
    draw.text((x + 20, 16), labels[i], font=font, fill='#f4ede0')
    board.paste(output.resize((760, 428), Image.Resampling.LANCZOS), (x + 20, 64))
    print(f"{jpg_path.name}: 1920x1080 RGB, {jpg_path.stat().st_size} bytes, quality={quality}; source={art.size}")
board.save(folder / 'Preview_Comparison.png', optimize=True)
