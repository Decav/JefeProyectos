#!/usr/bin/env python3
"""Export exact 1920x1080 16:9 Roblox thumbnail (clean + with Vandrheim logo in bottom-left)."""
from pathlib import Path
from PIL import Image, ImageOps, ImageDraw, ImageFont, ImageFilter

DESIGN_ROOT = Path(__file__).resolve().parents[1]
ASSETS_ROOT = Path(__file__).resolve().parents[4]
MASTERS_DIR = DESIGN_ROOT / "Masters"
PREVIEWS_DIR = DESIGN_ROOT / "Previews"
CANDIDATES_DIR = ASSETS_ROOT / "Images" / "Marketing" / "Thumbnails" / "Candidates"
LOGO_PATH = ASSETS_ROOT / "Images" / "Brand" / "Vandrheim__logotipo_nordico_glacial.png"

MASTER_SOURCE = MASTERS_DIR / "Thumbnail_Game_03_R15_Jotunn_master.jpg"
TARGET_SIZE = (1920, 1080)


def save_jpg_under_limit(img: Image.Image, jpg_path: Path, max_bytes: int = 3_000_000) -> int:
    for quality in (95, 92, 90, 87, 85):
        img.save(jpg_path, quality=quality, subsampling=0, optimize=True)
        if jpg_path.stat().st_size < max_bytes:
            return quality
    raise ValueError(f"JPEG exceeds {max_bytes} bytes: {jpg_path}")


def composite_logo_bottom_left(base_rgb: Image.Image, logo_path: Path) -> Image.Image:
    base = base_rgb.convert("RGBA")
    logo = Image.open(logo_path).convert("RGBA")

    # Crop transparent padding around logo
    bbox = logo.getchannel("A").getbbox()
    if bbox:
        logo = logo.crop(bbox)

    # Target width ~28% of 1920 = 540px, leaving generous margins in bottom-left rock area
    target_w = 540
    scale = target_w / logo.width
    target_h = round(logo.height * scale)
    logo_resized = logo.resize((target_w, target_h), Image.Resampling.LANCZOS)

    # Subtle dark drop shadow behind logo for crisp legibility over rock
    alpha = logo_resized.getchannel("A")
    shadow = Image.new("RGBA", logo_resized.size, (0, 0, 0, 0))
    shadow_alpha = alpha.point(lambda p: int(p * 0.75))
    shadow_layer = Image.new("RGBA", logo_resized.size, (8, 12, 20, 255))
    shadow_layer.putalpha(shadow_alpha)
    shadow = shadow_layer.filter(ImageFilter.GaussianBlur(radius=10))

    margin_x = 56
    margin_y = 48
    pos = (margin_x, TARGET_SIZE[1] - target_h - margin_y)
    shadow_pos = (pos[0] + 4, pos[1] + 6)

    base.alpha_composite(shadow, shadow_pos)
    base.alpha_composite(logo_resized, pos)
    return base.convert("RGB")


def main() -> None:
    PREVIEWS_DIR.mkdir(parents=True, exist_ok=True)
    CANDIDATES_DIR.mkdir(parents=True, exist_ok=True)

    art = Image.open(MASTER_SOURCE).convert("RGB")
    if abs(art.width / art.height - 16 / 9) > 0.03:
        raise ValueError(f"Unexpected source aspect ratio: {art.size}")

    clean_1080 = ImageOps.fit(art, TARGET_SIZE, method=Image.Resampling.LANCZOS)
    logo_1080 = composite_logo_bottom_left(clean_1080, LOGO_PATH)

    outputs = [
        ("Thumbnail_Game_03_R15_Jotunn_clean_1920x1080", clean_1080),
        ("Thumbnail_Game_03_R15_Jotunn_logo_1920x1080", logo_1080),
    ]

    for stem, img in outputs:
        png_path = CANDIDATES_DIR / f"{stem}.png"
        jpg_path = CANDIDATES_DIR / f"{stem}.jpg"
        img.save(png_path, optimize=True)
        q = save_jpg_under_limit(img, jpg_path)
        print(f"{stem}: {img.size} {img.mode} | PNG={png_path.stat().st_size}B | JPG(q={q})={jpg_path.stat().st_size}B")

    # Side-by-side comparison preview
    board = Image.new("RGB", (1600, 520), "#111925")
    draw = ImageDraw.Draw(board)
    font = ImageFont.load_default()
    labels = [
        "03a · Limpia (sin texto, espacio bottom-left)",
        "03b · Con logotipo Vandrheim (bottom-left)",
    ]
    for i, (_, img) in enumerate(outputs):
        x = i * 800
        draw.text((x + 20, 18), labels[i], font=font, fill="#f4ede0")
        board.paste(img.resize((760, 428), Image.Resampling.LANCZOS), (x + 20, 64))

    preview_path = PREVIEWS_DIR / "Preview_Comparison.png"
    board.save(preview_path, optimize=True)
    print(f"Preview saved -> {preview_path}")


if __name__ == "__main__":
    main()
