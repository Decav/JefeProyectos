#!/usr/bin/env python3
"""
Vandrheim RPG - Accessories Icon Exporter
Processes Base, Rare, and Epic Necklaces & Rings into canonical 512x512 transparent PNGs.
"""

from collections import deque
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import numpy as np

DESIGN_ROOT = Path(__file__).resolve().parents[1]
MASTERS_DIR = DESIGN_ROOT / "Masters"
PREVIEWS_DIR = DESIGN_ROOT / "Previews"
CANONICAL_DIR = Path(__file__).resolve().parents[4] / "Icons" / "Items" / "Accessories"

TARGET_CANVAS = 512
MAX_ARTWORK = 420
PREVIEW_SIZES = [16, 24, 32, 48, 64]

ITEMS = [
    {
        "id": "Icon_Item_collar",
        "tier": "Common",
        "name": "Collar sencillo",
        "source": MASTERS_DIR / "Icon_Item_collar_master.png",
    },
    {
        "id": "Icon_Item_collar_blue",
        "tier": "Rare",
        "name": "Collar rúnico de zafiro",
        "source": MASTERS_DIR / "Icon_Item_collar_blue_master.jpg",
    },
    {
        "id": "Icon_Item_collar_frost",
        "tier": "Epic",
        "name": "Collar glacial de Jotunn",
        "source": MASTERS_DIR / "Icon_Item_collar_frost_master.jpg",
    },
    {
        "id": "Icon_Item_ring",
        "tier": "Common",
        "name": "Anillo sencillo",
        "source": MASTERS_DIR / "Icon_Item_ring_master.png",
    },
    {
        "id": "Icon_Item_ring_blue",
        "tier": "Rare",
        "name": "Anillo de plata y zafiro",
        "source": MASTERS_DIR / "Icon_Item_ring_blue_master.jpg",
    },
    {
        "id": "Icon_Item_ring_frost",
        "tier": "Epic",
        "name": "Anillo de escarcha eterna",
        "source": MASTERS_DIR / "Icon_Item_ring_frost_master.jpg",
    },
]


def extract_and_fit_icon(
    source_path: Path,
    core_thresh: int = 12,
    edge_thresh: int = 35
) -> Image.Image:
    source_img = Image.open(source_path).convert("RGBA")
    w, h = source_img.size
    data = np.array(source_img, dtype=np.float32)
    rgb = data[:, :, :3]
    max_c = np.max(rgb, axis=2)

    # 1. Outer background flood fill
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

    # 2. Inner hole detection
    hole_visited = np.zeros((h, w), dtype=bool)
    for y in range(h):
        for x in range(w):
            if not bg_mask[y, x] and not hole_visited[y, x] and max_c[y, x] <= 3:
                hq = deque([(x, y)])
                hole_visited[y, x] = True
                candidate_pixels = [(x, y)]
                is_hole = True

                while hq:
                    hx, hy = hq.popleft()
                    for dx, dy in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
                        nx, ny = hx + dx, hy + dy
                        if 0 <= nx < w and 0 <= ny < h:
                            if not hole_visited[ny, nx]:
                                hole_visited[ny, nx] = True
                                if max_c[ny, nx] <= 3:
                                    hq.append((nx, ny))
                                    candidate_pixels.append((nx, ny))
                        else:
                            is_hole = False

                if is_hole and len(candidate_pixels) > 100:
                    eq = deque(candidate_pixels)
                    for px, py in candidate_pixels:
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

    # 3. Alpha calculation and un-premultiplying
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
    result_img = Image.fromarray(np.clip(data, 0, 255).astype(np.uint8), "RGBA")

    # 4. Crop to content bounding box
    bbox = result_img.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError(f"No visible artwork found in {source_path}")
    cropped = result_img.crop(bbox)

    # 5. Fit inside MAX_ARTWORK preserving aspect ratio
    cw, ch = cropped.size
    scale = min(MAX_ARTWORK / cw, MAX_ARTWORK / ch)
    nw, nh = max(1, round(cw * scale)), max(1, round(ch * scale))
    scaled = cropped.resize((nw, nh), Image.Resampling.LANCZOS)

    # 6. Center on TARGET_CANVAS
    canvas = Image.new("RGBA", (TARGET_CANVAS, TARGET_CANVAS), (0, 0, 0, 0))
    offset = ((TARGET_CANVAS - nw) // 2, (TARGET_CANVAS - nh) // 2)
    canvas.alpha_composite(scaled, offset)
    return canvas


def generate_contact_sheet(icons: dict[str, Image.Image], out_path: Path) -> None:
    cell_w, cell_h = 240, 260
    sheet_w = cell_w * len(ITEMS)
    sheet_h = cell_h * 2
    sheet = Image.new("RGB", (sheet_w, sheet_h), "#18191C")
    draw = ImageDraw.Draw(sheet)

    # Dark UI row
    draw.rectangle([0, 0, sheet_w, cell_h], fill="#222327")
    # Light parchment row
    draw.rectangle([0, cell_h, sheet_w, sheet_h], fill="#EDE7DC")
    font = ImageFont.load_default()

    tier_colors_dark = {
        "Common": "#D1D5DB",
        "Rare": "#60A5FA",
        "Epic": "#C4B5FD",
    }
    tier_colors_light = {
        "Common": "#4B5563",
        "Rare": "#1D4ED8",
        "Epic": "#6D28D9",
    }

    for i, item in enumerate(ITEMS):
        item_id = item["id"]
        icon = icons[item_id]
        thumb = icon.resize((180, 180), Image.Resampling.LANCZOS)

        x = i * cell_w + (cell_w - 180) // 2
        # Dark row
        sheet.paste(thumb, (x, 25), thumb)
        draw.text((i * cell_w + 16, 218), item["name"].upper(), fill="#F4EDE0", font=font)
        draw.text((i * cell_w + 16, 234), f"Tier: {item['tier']} | 512px", fill=tier_colors_dark[item["tier"]], font=font)

        # Light row
        sheet.paste(thumb, (x, cell_h + 25), thumb)
        draw.text((i * cell_w + 16, cell_h + 218), item["name"].upper(), fill="#292A2E", font=font)
        draw.text((i * cell_w + 16, cell_h + 234), f"Tier: {item['tier']} | 512px", fill=tier_colors_light[item["tier"]], font=font)

    sheet.save(out_path)
    print(f"Generated preview contact sheet at {out_path}")


def main() -> None:
    PREVIEWS_DIR.mkdir(parents=True, exist_ok=True)
    CANONICAL_DIR.mkdir(parents=True, exist_ok=True)

    icons = {}
    for item in ITEMS:
        item_id = item["id"]
        print(f"Processing {item_id} from {item['source'].name}...")
        icon = extract_and_fit_icon(item["source"])
        icons[item_id] = icon

        # 1. Save canonical file
        canonical_dest = CANONICAL_DIR / f"{item_id}.png"
        icon.save(canonical_dest)
        print(f"  Canonical export -> {canonical_dest}")

        # 2. Save multi-res previews
        for size in PREVIEW_SIZES:
            preview_dest = PREVIEWS_DIR / f"{item_id}_{size}.png"
            preview_img = icon.resize((size, size), Image.Resampling.LANCZOS)
            preview_img.save(preview_dest)

    # 3. Save contact sheet in Previews and DESIGN_ROOT
    contact_sheet_path = DESIGN_ROOT / "Preview_Accessories.png"
    generate_contact_sheet(icons, contact_sheet_path)
    print("Export process completed successfully.")


if __name__ == "__main__":
    main()
