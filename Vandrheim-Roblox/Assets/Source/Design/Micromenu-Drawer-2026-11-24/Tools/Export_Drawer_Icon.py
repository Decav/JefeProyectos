#!/usr/bin/env python3
"""
Vandrheim RPG - Micromenu Drawer Icon Exporter
Processes both drawer candidates (bars on white bg, grid on black bg) into 512x512 transparent PNGs.
"""

from collections import deque
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import numpy as np

DESIGN_ROOT = Path(__file__).resolve().parents[1]
MASTERS_DIR = DESIGN_ROOT / "Masters"
PREVIEWS_DIR = DESIGN_ROOT / "Previews"
CANONICAL_DIR = Path(__file__).resolve().parents[4] / "Icons" / "UI" / "Menu"

TARGET_CANVAS = 512
MAX_ARTWORK = 420
PREVIEW_SIZES = [16, 24, 32, 48, 64]


def extract_from_white(source_path: Path, core_thresh: int = 242, edge_thresh: int = 200) -> Image.Image:
    source_img = Image.open(source_path).convert("RGBA")
    w, h = source_img.size
    data = np.array(source_img, dtype=np.float32)
    rgb = data[:, :, :3]
    min_c = np.min(rgb, axis=2)

    bg_mask = np.zeros((h, w), dtype=bool)
    visited = np.zeros((h, w), dtype=bool)
    q = deque()

    for y in [0, h - 1]:
        for x in range(w):
            if min_c[y, x] >= core_thresh:
                q.append((x, y))
                visited[y, x] = True
                bg_mask[y, x] = True
    for x in [0, w - 1]:
        for y in range(h):
            if min_c[y, x] >= core_thresh and not visited[y, x]:
                q.append((x, y))
                visited[y, x] = True
                bg_mask[y, x] = True

    while q:
        cx, cy = q.popleft()
        for dx, dy in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[ny, nx]:
                visited[ny, nx] = True
                if min_c[ny, nx] >= edge_thresh:
                    bg_mask[ny, nx] = True
                    if min_c[ny, nx] >= core_thresh:
                        q.append((nx, ny))

    alpha = np.ones((h, w), dtype=np.float32) * 255.0
    for y in range(h):
        for x in range(w):
            if bg_mask[y, x]:
                val = min_c[y, x]
                if val >= core_thresh:
                    alpha[y, x] = 0.0
                    data[y, x, :3] = 0.0
                else:
                    a_factor = (core_thresh - val) / (core_thresh - edge_thresh)
                    a = np.clip(a_factor * 255.0, 0.0, 255.0)
                    alpha[y, x] = a

    data[:, :, 3] = alpha
    return fit_to_canvas(Image.fromarray(np.clip(data, 0, 255).astype(np.uint8)))


def extract_from_black(source_path: Path, core_thresh: int = 12, edge_thresh: int = 28) -> Image.Image:
    source_img = Image.open(source_path).convert("RGBA")
    w, h = source_img.size
    data = np.array(source_img, dtype=np.float32)
    rgb = data[:, :, :3]
    max_c = np.max(rgb, axis=2)

    bg_mask = np.zeros((h, w), dtype=bool)
    visited = np.zeros((h, w), dtype=bool)
    q = deque()

    for y in [0, h - 1]:
        for x in range(w):
            if max_c[y, x] <= core_thresh:
                q.append((x, y))
                visited[y, x] = True
                bg_mask[y, x] = True
    for x in [0, w - 1]:
        for y in range(h):
            if max_c[y, x] <= core_thresh and not visited[y, x]:
                q.append((x, y))
                visited[y, x] = True
                bg_mask[y, x] = True

    while q:
        cx, cy = q.popleft()
        for dx, dy in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[ny, nx]:
                visited[ny, nx] = True
                if max_c[ny, nx] <= edge_thresh:
                    bg_mask[ny, nx] = True
                    if max_c[ny, nx] <= core_thresh:
                        q.append((nx, ny))

    alpha = np.ones((h, w), dtype=np.float32) * 255.0
    for y in range(h):
        for x in range(w):
            if bg_mask[y, x]:
                val = max_c[y, x]
                if val <= core_thresh:
                    alpha[y, x] = 0.0
                    data[y, x, :3] = 0.0
                else:
                    a_factor = (val - core_thresh) / (edge_thresh - core_thresh)
                    a = np.clip(a_factor * 255.0, 0.0, 255.0)
                    alpha[y, x] = a

    data[:, :, 3] = alpha
    return fit_to_canvas(Image.fromarray(np.clip(data, 0, 255).astype(np.uint8)))


def fit_to_canvas(result_img: Image.Image) -> Image.Image:
    bbox = result_img.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("No visible artwork found")
    cropped = result_img.crop(bbox)
    cw, ch = cropped.size
    scale = min(MAX_ARTWORK / cw, MAX_ARTWORK / ch)
    nw, nh = max(1, round(cw * scale)), max(1, round(ch * scale))
    scaled = cropped.resize((nw, nh), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (TARGET_CANVAS, TARGET_CANVAS), (0, 0, 0, 0))
    offset = ((TARGET_CANVAS - nw) // 2, (TARGET_CANVAS - nh) // 2)
    canvas.alpha_composite(scaled, offset)
    return canvas


def generate_style_match_sheet(candidates: dict[str, Image.Image], out_path: Path) -> None:
    existing_icons = {
        "Dungeon": CANONICAL_DIR / "Icon_Menu_dungeon.png",
        "Quest": CANONICAL_DIR / "Icon_Menu_quest.png",
        "Run": CANONICAL_DIR / "Icon_Menu_run.png",
    }
    all_icons = []
    for label, path in existing_icons.items():
        if path.exists():
            all_icons.append((f"[Actual] {label}", Image.open(path)))
    for label, icon in candidates.items():
        all_icons.append((f"[Nuevo] {label}", icon))

    cell_w, cell_h = 220, 260
    sheet_w = cell_w * len(all_icons)
    sheet_h = cell_h * 2
    sheet = Image.new("RGB", (sheet_w, sheet_h), "#18191C")
    draw = ImageDraw.Draw(sheet)

    draw.rectangle([0, 0, sheet_w, cell_h], fill="#222327")
    draw.rectangle([0, cell_h, sheet_w, sheet_h], fill="#EDE7DC")
    font = ImageFont.load_default()

    for i, (label, icon) in enumerate(all_icons):
        thumb = icon.resize((160, 160), Image.Resampling.LANCZOS)
        x = i * cell_w + (cell_w - 160) // 2
        sheet.paste(thumb, (x, 30), thumb)
        draw.text((i * cell_w + 16, 215), label.upper(), fill="#F4EDE0", font=font)
        draw.text((i * cell_w + 16, 232), "512px / RGBA", fill="#8FB7D6", font=font)

        sheet.paste(thumb, (x, cell_h + 30), thumb)
        draw.text((i * cell_w + 16, cell_h + 215), label.upper(), fill="#292A2E", font=font)
        draw.text((i * cell_w + 16, cell_h + 232), "512px / RGBA", fill="#555555", font=font)

    sheet.save(out_path)
    print(f"Generated style match preview -> {out_path}")


def main() -> None:
    PREVIEWS_DIR.mkdir(parents=True, exist_ok=True)
    CANONICAL_DIR.mkdir(parents=True, exist_ok=True)

    bars_icon = extract_from_white(MASTERS_DIR / "Icon_Menu_drawer_bars_master.jpg")
    grid_icon = extract_from_black(MASTERS_DIR / "Icon_Menu_drawer_grid_master.jpg")

    processed = {
        "drawer_bars": bars_icon,
        "drawer_grid": grid_icon,
    }

    for name, icon in processed.items():
        for size in PREVIEW_SIZES:
            icon.resize((size, size), Image.Resampling.LANCZOS).save(PREVIEWS_DIR / f"{name}_{size}.png")
        corners = [icon.getpixel((0, 0))[3], icon.getpixel((511, 0))[3], icon.getpixel((0, 511))[3], icon.getpixel((511, 511))[3]]
        print(f"{name}: size={icon.size}, bbox={icon.getchannel('A').getbbox()}, corner_alphas={corners}")

    primary_dest = CANONICAL_DIR / "Icon_Menu_drawer.png"
    grid_icon.save(primary_dest)
    print(f"Canonical export (Grid 2x2) -> {primary_dest}")

    variant_dest = DESIGN_ROOT / "Icon_Menu_drawer_variant_bars.png"
    bars_icon.save(variant_dest)
    print(f"Variant export (Bars) -> {variant_dest}")

    generate_style_match_sheet({"Drawer (Barras)": bars_icon, "Drawer (Grid)": grid_icon}, DESIGN_ROOT / "Preview_StyleMatch.png")


if __name__ == "__main__":
    main()
