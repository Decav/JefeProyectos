#!/usr/bin/env python3
"""
Vandrheim RPG - Micromenu Run / Sprint Icon Exporter
Processes candidate icons into canonical 512x512 transparent PNGs and multi-res previews.
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


def extract_and_fit_icon(
    source_path: Path,
    core_thresh: int = 14,
    edge_thresh: int = 38
) -> Image.Image:
    source_img = Image.open(source_path).convert("RGBA")
    w, h = source_img.size
    data = np.array(source_img, dtype=np.float32)
    rgb = data[:, :, :3]
    max_c = np.max(rgb, axis=2)

    # 1. Outer background flood fill from 4 borders
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

                if is_hole and len(candidate_pixels) > 80:
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

    # 3. Alpha calculation and de-premultiplying
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


def generate_style_match_sheet(candidates: dict[str, Image.Image], out_path: Path) -> None:
    # Compare against existing micromenu icons
    existing_icons = {
        "Dungeon": CANONICAL_DIR / "Icon_Menu_dungeon.png",
        "Quest": CANONICAL_DIR / "Icon_Menu_quest.png",
        "Target": CANONICAL_DIR / "Icon_Menu_target_cycle.png",
        "Party": CANONICAL_DIR / "Icon_Menu_party.png",
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

    # Dark UI row (#222327)
    draw.rectangle([0, 0, sheet_w, cell_h], fill="#222327")
    # Light parchment row (#EDE7DC)
    draw.rectangle([0, cell_h, sheet_w, sheet_h], fill="#EDE7DC")
    font = ImageFont.load_default()

    for i, (label, icon) in enumerate(all_icons):
        thumb = icon.resize((160, 160), Image.Resampling.LANCZOS)
        x = i * cell_w + (cell_w - 160) // 2

        # Dark row
        sheet.paste(thumb, (x, 30), thumb)
        draw.text((i * cell_w + 16, 215), label.upper(), fill="#F4EDE0", font=font)
        draw.text((i * cell_w + 16, 232), "512px / RGBA", fill="#8FB7D6", font=font)

        # Light row
        sheet.paste(thumb, (x, cell_h + 30), thumb)
        draw.text((i * cell_w + 16, cell_h + 215), label.upper(), fill="#292A2E", font=font)
        draw.text((i * cell_w + 16, cell_h + 232), "512px / RGBA", fill="#555555", font=font)

    sheet.save(out_path)
    print(f"Generated style match preview at {out_path}")


def main() -> None:
    PREVIEWS_DIR.mkdir(parents=True, exist_ok=True)
    CANONICAL_DIR.mkdir(parents=True, exist_ok=True)

    candidates = {
        "run_winged_boot": MASTERS_DIR / "Icon_Menu_run_winged_boot_master.jpg",
        "run_warrior": MASTERS_DIR / "Icon_Menu_run_warrior_master.jpg",
    }

    processed = {}
    for name, master_path in candidates.items():
        print(f"Processing {name} from {master_path.name}...")
        icon = extract_and_fit_icon(master_path)
        processed[name] = icon

        # Multi-resolution previews
        for size in PREVIEW_SIZES:
            preview_dest = PREVIEWS_DIR / f"{name}_{size}.png"
            icon.resize((size, size), Image.Resampling.LANCZOS).save(preview_dest)

    # 1. Option 1 is primary canonical export (Icon_Menu_run.png)
    primary_canonical = CANONICAL_DIR / "Icon_Menu_run.png"
    processed["run_winged_boot"].save(primary_canonical)
    print(f"Canonical export (Primary: Winged Boot) -> {primary_canonical}")

    # 2. Option 2 variant export (Icon_Menu_run_variant_warrior.png)
    variant_canonical = DESIGN_ROOT / "Icon_Menu_run_variant_warrior.png"
    processed["run_warrior"].save(variant_canonical)
    print(f"Variant export (Warrior) -> {variant_canonical}")

    # 3. Generate side-by-side style match contact sheet
    sheet_candidates = {
        "Correr (Bota Alada)": processed["run_winged_boot"],
        "Correr (Guerrero)": processed["run_warrior"],
    }
    style_match_sheet = DESIGN_ROOT / "Preview_StyleMatch.png"
    generate_style_match_sheet(sheet_candidates, style_match_sheet)

    print("Run icon export process completed successfully.")


if __name__ == "__main__":
    main()

