from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
MASTERS = ROOT / "Masters"
EXPORTS = ROOT / "Exports"
PREVIEWS = ROOT / "Previews"
OUTPUT_NAMES = ["Icon_UI_settings", "Icon_UI_trash", "Icon_UI_sell_all"]
CANVAS = 512
ICON_MAX = 420
SIZES = [16, 24, 32, 48, 64]


def fitted_export(master_path: Path) -> Image.Image:
    source = Image.open(master_path).convert("RGBA")
    alpha_bounds = source.getchannel("A").getbbox()
    if alpha_bounds is None:
        raise ValueError(f"No visible artwork in {master_path}")

    artwork = source.crop(alpha_bounds)
    scale = ICON_MAX / max(artwork.size)
    dimensions = tuple(max(1, round(value * scale)) for value in artwork.size)
    artwork = artwork.resize(dimensions, Image.Resampling.LANCZOS)

    result = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    offset = ((CANVAS - artwork.width) // 2, (CANVAS - artwork.height) // 2)
    result.alpha_composite(artwork, offset)
    return result


def write_preview_sheet(exports: dict[str, Image.Image]) -> None:
    panel_w, panel_h = 192, 190
    sheet = Image.new("RGB", (panel_w * len(OUTPUT_NAMES), panel_h * 2), "#242529")
    draw = ImageDraw.Draw(sheet)
    labels = {
        "Icon_UI_settings": "AJUSTES",
        "Icon_UI_trash": "BASURA",
        "Icon_UI_sell_all": "VENDER TODO",
    }
    font = ImageFont.load_default()

    for column, name in enumerate(OUTPUT_NAMES):
        x = column * panel_w
        for row, (background, size, caption_color, caption) in enumerate(
            [("#242529", 64, "#F4EDE0", "64 px · oscuro"), ("#EDE7DC", 24, "#292A2E", "24 px · claro")]
        ):
            y = row * panel_h
            draw.rectangle((x, y, x + panel_w - 1, y + panel_h - 1), fill=background)
            icon = exports[name].resize((size, size), Image.Resampling.LANCZOS)
            sheet.paste(icon, (x + (panel_w - size) // 2, y + 40), icon)
            title = labels[name]
            title_box = draw.textbbox((0, 0), title, font=font)
            draw.text((x + (panel_w - (title_box[2] - title_box[0])) // 2, y + 124), title, fill=caption_color, font=font)
            draw.text((x + 8, y + 158), caption, fill=caption_color, font=font)

    sheet.save(ROOT / "Preview_Action_Icons.png")


def main() -> None:
    EXPORTS.mkdir(exist_ok=True)
    PREVIEWS.mkdir(exist_ok=True)
    exports = {}

    for name in OUTPUT_NAMES:
        image = fitted_export(MASTERS / f"{name}_master.png")
        image.save(EXPORTS / f"{name}.png")
        exports[name] = image
        for size in SIZES:
            image.resize((size, size), Image.Resampling.LANCZOS).save(
                PREVIEWS / f"{name}_{size}.png"
            )

    write_preview_sheet(exports)
    for name in OUTPUT_NAMES:
        image = Image.open(EXPORTS / f"{name}.png").convert("RGBA")
        if image.size != (CANVAS, CANVAS) or image.getpixel((0, 0))[3] != 0:
            raise ValueError(f"Unexpected dimensions or opaque canvas corner: {name}")
    print("Exported 3 transparent 512x512 icons and 15 small-size previews.")


if __name__ == "__main__":
    main()
