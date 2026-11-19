#!/usr/bin/env python3
"""
Vandrheim RPG - UI Compact Button Icon Exporter
Processes the master image into the canonical UI icon format.
"""

from pathlib import Path
from PIL import Image
import numpy as np

# Use the same logic as the successful run icon exporter
DESIGN_ROOT = Path(__file__).resolve().parents[1]
MASTER = DESIGN_ROOT / "Masters/Icon_UI_compact_master.jpg"
CANONICAL_DEST = Path(__file__).resolve().parents[4] / "Icons/UI/Common/Icon_UI_compact.png"

def extract_and_fit(source_path: Path):
    source_img = Image.open(source_path).convert("RGBA")
    w, h = source_img.size
    data = np.array(source_img, dtype=np.float32)
    # Threshold based on previous success (charcoal outlines + dark bg)
    max_c = np.max(data[:, :, :3], axis=2)
    
    # Simple alpha thresholding for flat UI icons
    alpha = np.where(max_c > 40, 255.0, 0.0)
    data[:, :, 3] = alpha
    
    res = Image.fromarray(data.astype(np.uint8), "RGBA")
    bbox = res.getchannel("A").getbbox()
    cropped = res.crop(bbox)
    
    # Scale to fill canvas 512x512
    cw, ch = cropped.size
    scale = min(420 / cw, 420 / ch)
    nw, nh = max(1, round(cw * scale)), max(1, round(ch * scale))
    scaled = cropped.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    offset = ((512 - nw) // 2, (512 - nh) // 2)
    canvas.alpha_composite(scaled, offset)
    return canvas

def main():
    icon = extract_and_fit(MASTER)
    icon.save(CANONICAL_DEST, optimize=True)
    print(f"Exported icon to {CANONICAL_DEST}")

if __name__ == "__main__":
    main()
