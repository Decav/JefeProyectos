#!/usr/bin/env python3
"""Exporta las variantes A (Jefe Jotunn) y C (Botin epico) a 1920x1080 con el logotipo oficial
abajo a la izquierda y, en C, el texto EPIC LOOT sobre el logo."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

DESIGN_ROOT = Path(__file__).resolve().parents[1]
ASSETS_ROOT = Path(__file__).resolve().parents[4]
MASTERS = DESIGN_ROOT / "Masters"
PREVIEWS = DESIGN_ROOT / "Previews"
OUT = ASSETS_ROOT / "Images" / "Marketing" / "Thumbnails" / "Candidates"
LOGO = ASSETS_ROOT / "Images" / "Brand" / "Vandrheim__logotipo_nordico_glacial.png"
FONT = "/System/Library/Fonts/Supplemental/Copperplate.ttc"
SIZE = (1920, 1080)
MARGIN_X, MARGIN_Y = 52, 44


def shadowed(layer: Image.Image, blur: int, opacity: float) -> Image.Image:
    sh = Image.new("RGBA", layer.size, (6, 10, 18, 255))
    sh.putalpha(layer.getchannel("A").point(lambda p: int(p * opacity)))
    return sh.filter(ImageFilter.GaussianBlur(blur))


def paste_with_shadow(base: Image.Image, layer: Image.Image, pos, blur=12, opacity=0.85):
    pad = blur * 3
    big = Image.new("RGBA", (layer.width + pad * 2, layer.height + pad * 2), (0, 0, 0, 0))
    big.alpha_composite(layer, (pad, pad))
    base.alpha_composite(shadowed(big, blur, opacity), (pos[0] - pad + 3, pos[1] - pad + 5))
    base.alpha_composite(layer, pos)


def logo_layer(width: int) -> Image.Image:
    logo = Image.open(LOGO).convert("RGBA")
    logo = logo.crop(logo.getchannel("A").getbbox())
    return logo.resize((width, round(logo.height * width / logo.width)), Image.Resampling.LANCZOS)


def caption_layer(text: str, height: int) -> Image.Image:
    font = ImageFont.truetype(FONT, height, index=2)  # Copperplate Bold
    l, t, r, b = font.getbbox(text, stroke_width=6)
    w, h = r - l + 4, b - t + 4
    # Relleno con degradado dorado y contorno oscuro
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).text((-l + 2, -t + 2), text, font=font, fill=255)
    grad = Image.new("RGBA", (w, h))
    gd = ImageDraw.Draw(grad)
    top, bot = (255, 226, 140), (214, 146, 52)
    for y in range(h):
        k = y / max(1, h - 1)
        gd.line([(0, y), (w, y)], fill=tuple(round(top[i] + (bot[i] - top[i]) * k) for i in range(3)) + (255,))
    stroke = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(stroke).text((-l + 2, -t + 2), text, font=font, fill=(26, 18, 10, 255),
                                stroke_width=6, stroke_fill=(26, 18, 10, 255))
    fill = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    fill.paste(grad, (0, 0), mask)
    stroke.alpha_composite(fill)
    return stroke


def compose(master: str, logo_w: int, caption=None) -> Image.Image:
    base = ImageOps.fit(Image.open(MASTERS / master).convert("RGB"), SIZE, Image.Resampling.LANCZOS).convert("RGBA")
    logo = logo_layer(logo_w)
    lpos = (MARGIN_X, SIZE[1] - logo.height - MARGIN_Y)
    paste_with_shadow(base, logo, lpos)
    if caption:
        cap = caption_layer(caption, 74)
        cpos = (MARGIN_X + 8, lpos[1] - cap.height - 6)
        paste_with_shadow(base, cap, cpos, blur=10, opacity=0.9)
    return base.convert("RGB")


def save(img: Image.Image, stem: str):
    png, jpg = OUT / f"{stem}.png", OUT / f"{stem}.jpg"
    img.save(png, optimize=True)
    for q in (95, 92, 90, 87):
        img.save(jpg, quality=q, subsampling=0, optimize=True)
        if jpg.stat().st_size < 3_000_000:
            break
    print(f"{stem}: {img.size} PNG={png.stat().st_size} JPG(q={q})={jpg.stat().st_size}")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    a = compose("Thumbnail_Game_04_VarianteA_Jotunn_1920_master.png", 560)
    c = compose("Thumbnail_Game_05_VarianteC_Botin_1920_master.png", 470, "EPIC LOOT")
    save(a, "Thumbnail_Game_04_Jefe_Jotunn_logo_1920x1080")
    save(c, "Thumbnail_Game_05_Botin_Epico_logo_1920x1080")
    board = Image.new("RGB", (1600, 500), "#111925")
    for i, img in enumerate((a, c)):
        board.paste(img.resize((760, 428), Image.Resampling.LANCZOS), (20 + i * 800, 36))
    board.save(PREVIEWS / "Preview_A_C_logo.png", optimize=True)


if __name__ == "__main__":
    main()
