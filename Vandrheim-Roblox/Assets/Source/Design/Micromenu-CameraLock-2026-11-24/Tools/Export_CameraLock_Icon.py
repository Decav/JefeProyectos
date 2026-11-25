#!/usr/bin/env python3
"""
Vandrheim RPG - Micromenu Camera Lock Crosshair Icon Exporter
Extracts outer + inner black background, fits to 512x512 RGBA, and generates previews.
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


def extract_from_black_with_holes(source_path: Path, core_thresh: int = 12, edge_thresh: int = 28) -> Image.Image:
    source_img = Image.open(source_path).convert("RGBA")
    w, h = source_img.size
    data = np.array(source_img, dtype=np.float32)
    rgb = data[:, :, :3]
    max_c = np.max(rgb, axis=2)

    bg_mask = np.zeros((h, w), dtype=bool)
    visited = np.zeros((h, w), dtype=bool)
    q = deque()

    # 1. Outer border flood fill
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

    # 2. Inner hole flood fill (ring interior)
    hole_visited = np.zeros((h, w), dtype=bool)
    for y in range(h):
        for x in range(w):
            if not bg_mask[y, x] and not hole_visited[y, x] and max_c[y, x] <= 4:
                hq = deque([(x, y)])
                hole_visited[y, x] = True
                candidate = [(x, y)]
                is_hole = True

                while hq:
                    hx, hy = hq.popleft()
                    for dx, dy in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
                        nx, ny = hx + dx, hy + dy
                        if 0 <= nx < w and 0 <= ny < h:
                            if not hole_visited[ny, nx]:
                                hole_visited[ny, nx] = True
                                if max_c[ny, nx] <= 4:
                                    hq.append((nx, ny))
                                    candidate.append((nx, ny))
                        else:
                            is_hole = False

                if is_hole and len(candidate) > 100:
                    eq = deque(candidate)
                    for px, py in candidate:
                        bg_mask[py, px] = True
                    while eq:
                        ex, ey = eq.popleft()
                        for dx, dy in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
                            nx, ny = ex + dx, ey + dy
                            if 0 <= nx < w and 0 <= ny < h and not bg_mask[ny, nx]:
                                if max_c[ny, nx] <= edge_thresh:
                                    bg_mask[ny, nx] = True
                                    if max_c[ny, nx] <= core_thresh:
                                        eq.append((nx, ny))

    # 3. Alpha + de-premultiply edges
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
                    if a > 0:
                        scale = 255.0 / a
                        data[y, x, 0] = min(255.0, data[y, x, 0] * scale)
                        data[y, x, 1] = min(255.0, data[y, x, 1] * scale)
                        data[y, x, 2] = min(255.0, data[y, x, 2] * scale)

    data[:, :, 3] = alpha
    result_img = Image.fromarray(np.clip(data, 0, 255).astype(np.uint8))

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


def generate_style_match_sheet(new_icon: Image.Image, out_path: Path) -> None:
    icons = [
        ("[Actual] Dungeon", Image.open(CANONICAL_DIR / "Icon_Menu_dungeon.png")),
        ("[Actual] Target", Image.open(CANONICAL_DIR / "Icon_Menu_target_cycle.png")),
        ("[Actual] Run", Image.open(CANONICAL_DIR / "Icon_Menu_run.png")),
        ("[Actual] Drawer", Image.open(CANONICAL_DIR / "Icon_Menu_drawer.png")),
        ("[Nuevo] Camera Lock", new_icon),
    ]

    cell_w, cell_h = 220, 260
    sheet_w = cell_w * len(icons)
    sheet_h = cell_h * 2
    sheet = Image.new("RGB", (sheet_w, sheet_h), "#18191C")
    draw = ImageDraw.Draw(sheet)
    draw.rectangle([0, 0, sheet_w, cell_h], fill="#222327")
    draw.rectangle([0, cell_h, sheet_w, sheet_h], fill="#EDE7DC")
    font = ImageFont.load_default()

    for i, (label, icon) in enumerate(icons):
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

    icon = extract_from_black_with_holes(MASTERS_DIR / "Icon_Menu_camera_lock_master.jpg")
    canonical_dest = CANONICAL_DIR / "Icon_Menu_camera_lock.png"
    icon.save(canonical_dest)

    for size in PREVIEW_SIZES:
        icon.resize((size, size), Image.Resampling.LANCZOS).save(PREVIEWS_DIR / f"Icon_Menu_camera_lock_{size}.png")

    corners = [icon.getpixel((0, 0))[3], icon.getpixel((511, 0))[3], icon.getpixel((0, 511))[3], icon.getpixel((511, 511))[3]]
    print(f"Icon_Menu_camera_lock: size={icon.size}, bbox={icon.getchannel('A').getbbox()}, corner_alphas={corners}, inner_ring_alpha={icon.getpixel((180, 256))[3]}")
    generate_style_match_sheet(icon, DESIGN_ROOT / "Preview_StyleMatch.png")


if __name__ == "__main__":
    main()
