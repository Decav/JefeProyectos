from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import numpy as np


ROOT = Path(__file__).resolve().parent
MASTER = ROOT / "Masters"
OUTPUTS = {
    "gloves": ("Icon_Item_traveler_gloves_master.png", "Icon_Item_traveler_gloves_v1.png"),
    "chest": ("Icon_Item_traveler_chest_master.png", "Icon_Item_traveler_chest_v1.png"),
    "legs": ("Icon_Item_traveler_legs_master.png", "Icon_Item_traveler_legs_v1.png"),
}
SIZE = (512, 512)
MAX_CONTENT = 438  # leaves an 8.4% clear border on the longest side
ALPHA_CUTOFF = 16  # remove near-transparent extraction noise around the cutout


def premultiplied_resize(source: Image.Image, size: tuple[int, int]) -> Image.Image:
    rgba = np.asarray(source.convert("RGBA"), dtype=np.float32)
    alpha = rgba[:, :, 3] / 255.0
    rgb = rgba[:, :, :3] * alpha[:, :, None]
    premul = Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB")
    alpha_image = Image.fromarray(np.clip(alpha * 255, 0, 255).astype(np.uint8), "L")
    premul = premul.resize(size, Image.Resampling.LANCZOS)
    alpha_image = alpha_image.resize(size, Image.Resampling.LANCZOS)
    p = np.asarray(premul, dtype=np.float32)
    a = np.asarray(alpha_image, dtype=np.float32)
    out_rgb = np.zeros_like(p)
    nonzero = a > 0.25
    out_rgb[nonzero] = np.clip(p[nonzero] * (255.0 / a[nonzero, None]), 0, 255)
    out = np.dstack([out_rgb.astype(np.uint8), a.astype(np.uint8)])
    return Image.fromarray(out, "RGBA")


def prepare_icon(source_path: Path, destination: Path) -> tuple[Image.Image, tuple[int, int, int, int]]:
    source = Image.open(source_path).convert("RGBA")
    alpha = source.getchannel("A").point(lambda value: value if value > ALPHA_CUTOFF else 0)
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError(f"No visible subject found in {source_path}")
    subject = source.crop(bbox)
    subject.putalpha(alpha.crop(bbox))

    scale = min(MAX_CONTENT / subject.width, MAX_CONTENT / subject.height)
    new_size = (max(1, round(subject.width * scale)), max(1, round(subject.height * scale)))
    scaled = premultiplied_resize(subject, new_size)
    canvas = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    position = ((SIZE[0] - new_size[0]) // 2, (SIZE[1] - new_size[1]) // 2)
    canvas.alpha_composite(scaled, position)
    canvas.save(destination)
    return canvas, canvas.getchannel("A").getbbox()


def contact_sheet(icons: dict[str, Image.Image], out_path: Path) -> None:
    panel_w, panel_h = 560, 620
    sheet = Image.new("RGB", (panel_w * 3, panel_h), (34, 31, 29))
    d = ImageDraw.Draw(sheet)
    try:
        title_font = ImageFont.truetype("arial.ttf", 25)
        label_font = ImageFont.truetype("arial.ttf", 19)
    except OSError:
        title_font = label_font = ImageFont.load_default()
    labels = {"gloves": "GUANTES", "chest": "PECHO", "legs": "PANTALÓN"}
    for i, name in enumerate(("gloves", "chest", "legs")):
        x = i * panel_w
        d.text((x + 22, 18), labels[name], font=title_font, fill=(236, 219, 190))
        # Checkerboard preview only; exported item icons remain transparent.
        tile = 32
        for yy in range(65, panel_h):
            for xx in range(x, x + panel_w):
                if ((xx // tile) + (yy // tile)) % 2:
                    sheet.putpixel((xx, yy), (65, 59, 53))
                else:
                    sheet.putpixel((xx, yy), (50, 46, 42))
        sheet_rgba = sheet.convert("RGBA")
        icon = icons[name]
        sheet_rgba.alpha_composite(icon, (x + (panel_w - 512) // 2, 75))
        sheet = sheet_rgba.convert("RGB")
        d = ImageDraw.Draw(sheet)
        d.text((x + 22, 575), "PNG 512×512 · fondo transparente", font=label_font, fill=(210, 198, 180))
    sheet.save(out_path)


def main() -> None:
    prepared = {}
    for name, (master_name, output_name) in OUTPUTS.items():
        out_path = ROOT / output_name
        image, bbox = prepare_icon(MASTER / master_name, out_path)
        if image.size != SIZE or image.mode != "RGBA":
            raise AssertionError(f"Invalid output: {out_path}")
        alpha = image.getchannel("A")
        if alpha.getpixel((0, 0)) != 0 or alpha.getpixel((511, 511)) != 0:
            raise AssertionError(f"Transparent corners expected: {out_path}")
        if bbox is None:
            raise AssertionError(f"Empty icon: {out_path}")
        margins = (bbox[0], bbox[1], SIZE[0] - bbox[2], SIZE[1] - bbox[3])
        print(f"{name}: RGBA {image.size}; visible bbox={bbox}; margins L/T/R/B={margins}")
        prepared[name] = image

    contact_sheet(prepared, ROOT / "Preview_TravelerStarterIcons.png")
    print(f"Preview: {ROOT / 'Preview_TravelerStarterIcons.png'}")


if __name__ == "__main__":
    main()
