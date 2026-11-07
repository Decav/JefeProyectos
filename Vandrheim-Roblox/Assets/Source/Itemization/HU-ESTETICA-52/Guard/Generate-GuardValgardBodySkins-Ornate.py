"""
Generate-GuardValgardBodySkins-Ornate.py
Generates the top-tier, ornate Guard of Valgard classic body skins (Shirt and Pants)
for Roblox R15 avatars, strictly adhering to:
1. Template-Shirts-R15v2.png and Template-Pants-R15v2.png (585x559, RGBA).
2. The ornate high-tier visual fidelity standard of EST-33 (Paladin Frost & Paladin Blue):
   - Multi-layered cold-forged silver-blue steel plates with brushed metallic sheen.
   - Double-bevelled antique gold filigree with engraved Norse knotwork.
   - Glowing cyan frost runes etched into the breastplate, vambraces, and greaves.
   - Faceted royal sapphire gemstone set in the center gorget.
   - Dark steel chainmail weave and midnight navy quilted gambeson.
   - Ornate leather belt with forged iron & gold rune medallion buckle.
3. STRICTLY NO HELMET, NO SHOULDER PADS (100% pure body skin).
4. Exact R15 cut lines:
   - Torso: UpperTorso (y=74..169), Joint seam (y=170), LowerTorso (y=171..201), DOWN (y=204..267).
   - Limbs: Upper (y=355..417), Joint seam (y=418), Lower (y=419..466), Joint seam (y=467), Hand/Foot (y=468..482).
"""

import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

WIDTH = 585
HEIGHT = 559
SCALE = 2  # 2x supersampling for razor-sharp anti-aliased geometry and micro-detail

SW = WIDTH * SCALE
SH = HEIGHT * SCALE

def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def hex_to_rgba(h, a=255):
    r, g, b = hex_to_rgb(h)
    return (r, g, b, a)

def scale_pt(p):
    return (int(round(p[0] * SCALE)), int(round(p[1] * SCALE)))

def scale_pts(pts):
    return [scale_pt(p) for p in pts]

def scale_rect(x, y, w, h):
    return (x * SCALE, y * SCALE, (x + w) * SCALE, (y + h) * SCALE)

def draw_polygon_aa(draw, pts, fill, outline=None, width=1):
    scaled = scale_pts(pts)
    draw.polygon(scaled, fill=fill)
    if outline:
        draw.polygon(scaled, outline=outline)
        if width > 1:
            for i in range(len(scaled)):
                p1 = scaled[i]
                p2 = scaled[(i + 1) % len(scaled)]
                draw.line([p1, p2], fill=outline, width=int(round(width * SCALE)))

def draw_line_aa(draw, x1, y1, x2, y2, color, width=1):
    draw.line([scale_pt((x1, y1)), scale_pt((x2, y2))], fill=color, width=int(round(width * SCALE)))

def draw_diamond_aa(draw, cx, cy, rx, ry, fill, outline=None, width=1):
    pts = [(cx, cy - ry), (cx + rx, cy), (cx, cy + ry), (cx - rx, cy)]
    draw_polygon_aa(draw, pts, fill, outline, width)

def draw_rivet(draw, cx, cy, radius=2):
    scx, scy = scale_pt((cx, cy))
    sr = radius * SCALE
    draw.ellipse([scx - sr, scy - sr + 1, scx + sr, scy + sr + 1], fill=hex_to_rgba('#161008'))
    draw.ellipse([scx - sr, scy - sr, scx + sr, scy + sr], fill=hex_to_rgba('#e0be5a'))
    glint_r = max(1, sr // 2)
    draw.ellipse([scx - glint_r, scy - glint_r, scx, scy], fill=hex_to_rgba('#fff7d9'))

def draw_cyan_frost_rune(draw, cx, cy, rx=5, ry=7):
    # Outer cyan frost aura
    draw_diamond_aa(draw, cx, cy, rx + 2, ry + 2, fill=hex_to_rgba('#125575', 180))
    # Glowing cyan body
    draw_diamond_aa(draw, cx, cy, rx, ry, fill=hex_to_rgba('#22d6f2'), outline='#85f4ff', width=1.0)
    # White-cyan core
    draw_diamond_aa(draw, cx, cy, max(1, rx - 3), max(1, ry - 3), fill=hex_to_rgba('#ffffff'))

def generate_metal_noise(w, h, seed=99):
    np.random.seed(seed)
    raw = np.random.normal(0, 1, (h, w))
    im_noise = Image.fromarray((raw * 40 + 128).clip(0, 255).astype(np.uint8))
    im_noise = im_noise.filter(ImageFilter.GaussianBlur(1.2))
    noise_arr = (np.array(im_noise).astype(float) - 128) / 128.0

    raw_s = np.random.normal(0, 1, (h, 1))
    streaks = np.repeat(raw_s, w, axis=1)
    im_s = Image.fromarray((streaks * 30 + 128).clip(0, 255).astype(np.uint8))
    im_s = im_s.filter(ImageFilter.GaussianBlur(1.8))
    streak_arr = (np.array(im_s).astype(float) - 128) / 128.0

    return (noise_arr * 0.6 + streak_arr * 0.4)

def apply_midnight_gambeson_pattern(draw, x, y, w, h, base_col='#141b26', seam_col='#1f2b3e'):
    sx0, sy0, sx1, sy1 = scale_rect(x, y, w, h)
    draw.rectangle([sx0, sy0, sx1, sy1], fill=hex_to_rgba(base_col))
    step = 14 * SCALE
    for d in range(sx0 - (sy1 - sy0), sx1 + (sy1 - sy0), step):
        draw.line([(d, sy0), (d + (sy1 - sy0), sy1)], fill=hex_to_rgba(seam_col), width=SCALE)
        draw.line([(d, sy1), (d + (sy1 - sy0), sy0)], fill=hex_to_rgba(seam_col), width=SCALE)

def apply_chainmail_pattern(draw, x, y, w, h):
    sx0, sy0, sx1, sy1 = scale_rect(x, y, w, h)
    draw.rectangle([sx0, sy0, sx1, sy1], fill=hex_to_rgba('#1c222b'))
    c_step = 6 * SCALE
    for cy in range(sy0, sy1, c_step):
        for cx in range(sx0, sx1, c_step):
            draw.ellipse([cx, cy, cx + 4 * SCALE, cy + 4 * SCALE], outline=hex_to_rgba('#4a5666'), width=SCALE)
            draw.point((cx + 1 * SCALE, cy + 1 * SCALE), fill=hex_to_rgba('#8d9faa'))

def generate_ornate_guard_shirt():
    canvas = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # -------------------------------------------------------------
    # 1. TORSO UNDERLAYER (Midnight Navy Gambeson & Dark Chainmail)
    # -------------------------------------------------------------
    # Middle row: R(165..229), F(231..358), L(359..423), B(425..552)
    # UpperTorso: y=74..169. LowerTorso: y=171..201.
    apply_midnight_gambeson_pattern(draw, 165, 74, 388, 128, base_col='#121924', seam_col='#1c2637')
    # Torso UP (neck/shoulders)
    apply_midnight_gambeson_pattern(draw, 231, 8, 128, 64, base_col='#0f141d', seam_col='#18212f')
    # Torso DOWN (tunic underside)
    apply_midnight_gambeson_pattern(draw, 231, 204, 128, 64, base_col='#0c1017', seam_col='#141a25')

    # Side faces (R: 165..229, L: 359..423):
    # Exposed chainmail weave under armpits & ornate gold-piped side straps
    for side_x, side_w in [(165, 65), (359, 65)]:
        apply_chainmail_pattern(draw, side_x + 8, 76, side_w - 16, 92)
        # Gold side piping
        draw_line_aa(draw, side_x + 6, 74, side_x + 6, 169, '#d4af37', 2.0)
        draw_line_aa(draw, side_x + side_w - 6, 74, side_x + side_w - 6, 169, '#d4af37', 2.0)
        # Side flank leather straps with engraved brass buckles connecting breastplate and backplate
        for sy in [105, 140]:
            draw.rectangle(scale_rect(side_x + 6, sy, side_w - 12, 10), fill=hex_to_rgba('#241a14'))
            draw_line_aa(draw, side_x + 6, sy, side_x + side_w - 6, sy, '#563e2d', 1)
            draw_line_aa(draw, side_x + 6, sy + 10, side_x + side_w - 6, sy + 10, '#100b08', 1)
            bcx = side_x + side_w // 2
            draw.rectangle(scale_rect(bcx - 5, sy - 2, 10, 14), fill=hex_to_rgba('#e0be5a'), outline=hex_to_rgba('#48360d'))
            draw_rivet(draw, side_x + 10, sy + 5, 2)
            draw_rivet(draw, side_x + side_w - 10, sy + 5, 2)

    # -------------------------------------------------------------
    # 2. TORSO FRONT (Ornate Cuirass, Gorget, Sapphire Gem, Frost Runes)
    # -------------------------------------------------------------
    fx0, fx1 = 231, 358
    fcx = 295

    # Raised Collar / Neckline on Front Upper
    draw_polygon_aa(draw, [(248, 74), (fcx, 92), (342, 74), (324, 74), (fcx, 86), (266, 74)], fill=hex_to_rgba('#090d14'))
    draw_line_aa(draw, 248, 74, fcx, 92, '#e0be5a', 2.5)
    draw_line_aa(draw, 342, 74, fcx, 92, '#e0be5a', 2.5)
    draw_line_aa(draw, 248, 75, fcx, 93, '#5c4510', 1.2)
    draw_line_aa(draw, 342, 75, fcx, 93, '#5c4510', 1.2)

    # Main Ornate Cuirass (Cold-forged Silver-Blue Steel Plates)
    cuirass_pts = [
        (242, 88), (348, 88),
        (356, 118), (344, 155),
        (fcx, 169),  # Point ends exactly at UpperTorso joint line y=170
        (246, 155), (234, 118)
    ]
    draw_polygon_aa(draw, cuirass_pts, fill=hex_to_rgba('#5a6c82'), outline=hex_to_rgba('#1e2632'), width=2.5)

    # Pectoral Plates (Left & Right) with specular metallic gradients
    pec_l = [(247, 93), (fcx - 6, 98), (fcx - 8, 145), (252, 150), (239, 119)]
    pec_r = [(343, 93), (fcx + 6, 98), (fcx + 8, 145), (338, 150), (351, 119)]
    draw_polygon_aa(draw, pec_l, fill=hex_to_rgba('#7d92ab'))
    draw_polygon_aa(draw, pec_r, fill=hex_to_rgba('#71859d'))

    # Metallic specular glints (cold steel reflection)
    draw_line_aa(draw, 254, 102, 286, 108, '#dce8f5', 2.0)
    draw_line_aa(draw, 336, 102, 304, 108, '#cce0f0', 2.0)
    draw_line_aa(draw, 250, 132, 283, 140, '#3f4f63', 1.5)
    draw_line_aa(draw, 340, 132, 307, 140, '#3f4f63', 1.5)

    # Double-Bevelled Antique Gold Filigree around Cuirass Contour
    for i in range(len(cuirass_pts)):
        p1 = cuirass_pts[i]
        p2 = cuirass_pts[(i + 1) % len(cuirass_pts)]
        # Outer gold
        draw_line_aa(draw, p1[0], p1[1], p2[0], p2[1], '#d4af37', 2.5)
        # Inner highlight
        draw_line_aa(draw, p1[0], p1[1] + 1, p2[0], p2[1] + 1, '#fff3c2', 1.0)
        # Drop shadow
        draw_line_aa(draw, p1[0], p1[1] + 2, p2[0], p2[1] + 2, '#48350d', 1.0)

    # Glowing Cyan Frost Runes on the Upper Left & Right Pectorals
    draw_cyan_frost_rune(draw, 268, 115, rx=5, ry=7)
    draw_cyan_frost_rune(draw, 322, 115, rx=5, ry=7)
    # Petroglyph rune branches
    draw_line_aa(draw, 268, 108, 274, 104, '#22d6f2', 1.2)
    draw_line_aa(draw, 268, 122, 262, 126, '#22d6f2', 1.2)
    draw_line_aa(draw, 322, 108, 316, 104, '#22d6f2', 1.2)
    draw_line_aa(draw, 322, 122, 328, 126, '#22d6f2', 1.2)

    # Center Gorget with Faceted Royal Sapphire Gemstone
    gorget_pts = [(fcx - 14, 90), (fcx + 14, 90), (fcx + 18, 136), (fcx, 159), (fcx - 18, 136)]
    draw_polygon_aa(draw, gorget_pts, fill=hex_to_rgba('#1e2c3e'), outline=hex_to_rgba('#e0be5a'), width=2.0)
    draw_line_aa(draw, fcx, 92, fcx, 156, '#fff4ca', 1.5)

    # Faceted Sapphire Gemstone at Center (fcx=295, y=118)
    draw_diamond_aa(draw, fcx, 118, 10, 14, fill=hex_to_rgba('#0d2852'), outline='#e0be5a', width=2.0)
    draw_diamond_aa(draw, fcx, 118, 7, 10, fill=hex_to_rgba('#1a559e'), outline='#7cc4ff', width=1.0)
    draw_diamond_aa(draw, fcx, 118, 3, 5, fill=hex_to_rgba('#e0f2ff'))

    # Knotwork diamond inlay below gem (y=140)
    draw_diamond_aa(draw, fcx, 140, 7, 9, fill=hex_to_rgba('#151e2a'), outline='#d4af37', width=1.5)
    draw_cyan_frost_rune(draw, fcx, 140, rx=3, ry=5)

    # Rivets along Cuirass Outer Perimeter
    for rx, ry in [(245, 96), (238, 120), (248, 150), (345, 96), (352, 120), (342, 150)]:
        draw_rivet(draw, rx, ry, 2)

    # Seam joint line at y=170 (Purple cut line in template v2)
    draw_line_aa(draw, fx0, 170, fx1, 170, '#0d121a', 1.5)

    # -------------------------------------------------------------
    # 3. LOWER TORSO FRONT (Fauld, Ornate Utility Belt, Rune Medallion)
    # -------------------------------------------------------------
    # Lower abdominal plate segments (fauld) spanning y=171..182
    draw_polygon_aa(draw, [(244, 171), (fcx, 176), (346, 171), (350, 182), (240, 182)], fill=hex_to_rgba('#4c5c70'), outline='#d4af37', width=1.5)
    draw_line_aa(draw, 252, 177, 338, 177, '#8ca0b8', 1.2)
    draw_cyan_frost_rune(draw, fcx - 30, 176, rx=3, ry=4)
    draw_cyan_frost_rune(draw, fcx + 30, 176, rx=3, ry=4)

    # Ornate Heavy Leather Utility Belt across y=183..197 (14 px high)
    draw.rectangle(scale_rect(fx0, 183, 128, 14), fill=hex_to_rgba('#221812'))
    draw_line_aa(draw, fx0, 183, fx1, 183, '#d4af37', 1.5)
    draw_line_aa(draw, fx0, 197, fx1, 197, '#100b07', 1.5)
    draw_line_aa(draw, fx0, 185, fx1, 185, '#5c402e', 0.8)
    draw_line_aa(draw, fx0, 195, fx1, 195, '#5c402e', 0.8)

    # Ornate Forged Iron & Gold Rune Medallion Buckle (fcx=295, y=190)
    draw.ellipse(scale_rect(fcx - 12, 179, 24, 22), fill=hex_to_rgba('#161c24'), outline=hex_to_rgba('#e0be5a'), width=SCALE)
    draw.ellipse(scale_rect(fcx - 8, 183, 16, 14), fill=hex_to_rgba('#2f3b4c'), outline=hex_to_rgba('#8ea2ba'))
    draw_cyan_frost_rune(draw, fcx, 190, rx=4, ry=5)
    draw_rivet(draw, fcx - 18, 190, 2)
    draw_rivet(draw, fcx + 18, 190, 2)

    # Hanging tassets with gold-trimmed hem at bottom (y=198..201)
    draw.rectangle(scale_rect(fx0, 198, 128, 4), fill=hex_to_rgba('#161e2a'))
    draw_line_aa(draw, fx0, 201, fx1, 201, '#d4af37', 1.5)

    # -------------------------------------------------------------
    # 4. TORSO BACK (Ornate Backplate, Spinal Ridge, Gold Filigree)
    # -------------------------------------------------------------
    bx0, bx1 = 425, 552
    bcx = 488
    back_pts = [(436, 88), (540, 88), (546, 169), (bcx, 173), (430, 169)]
    draw_polygon_aa(draw, back_pts, fill=hex_to_rgba('#4a5b70'), outline='#d4af37', width=2.2)
    # Spinal ridge with gold bevels
    draw.rectangle(scale_rect(bcx - 6, 88, 12, 83), fill=hex_to_rgba('#2b3644'), outline='#e0be5a')
    draw_line_aa(draw, bcx, 90, bcx, 169, '#a8bed4', 1.8)
    # Scapular articulation ridges
    draw_line_aa(draw, 440, 105, 476, 116, '#8ca0b8', 1.5)
    draw_line_aa(draw, 536, 105, 500, 116, '#8ca0b8', 1.5)
    # Back belt continuing seamlessly
    draw.rectangle(scale_rect(bx0, 183, 128, 14), fill=hex_to_rgba('#221812'))
    draw_line_aa(draw, bx0, 183, bx1, 183, '#d4af37', 1.2)
    draw_line_aa(draw, bx0, 197, bx1, 197, '#100b07', 1.2)
    draw.rectangle(scale_rect(bcx - 6, 182, 12, 16), fill=hex_to_rgba('#563e2d'), outline='#1e140d')

    # -------------------------------------------------------------
    # 5. ARMS (Left: 19..280; Right: 308..569, y=355..482)
    # -------------------------------------------------------------
    def draw_ornate_arm(island_x, is_left):
        # 1. Upper Arm (y=355..417): Midnight navy gambeson with gold seam piping & chainmail
        apply_midnight_gambeson_pattern(draw, island_x, 355, 262, 63, base_col='#121924', seam_col='#1c2637')
        up_x = 217 if is_left else 308
        apply_midnight_gambeson_pattern(draw, up_x, 290, 64, 64, base_col='#0f141d', seam_col='#18212f')

        # Gold vertical seam embroidery
        draw_line_aa(draw, island_x + 32, 355, island_x + 32, 417, '#d4af37', 1.2)
        draw_line_aa(draw, island_x + 96, 355, island_x + 96, 417, '#d4af37', 1.2)
        draw_line_aa(draw, island_x + 160, 355, island_x + 160, 417, '#d4af37', 1.2)
        draw_line_aa(draw, island_x + 224, 355, island_x + 224, 417, '#d4af37', 1.2)

        # Bicep leather harness with gold buckle at y=404..414
        draw.rectangle(scale_rect(island_x, 404, 262, 10), fill=hex_to_rgba('#281c14'))
        draw_line_aa(draw, island_x, 404, island_x + 262, 404, '#563e2d', 1)
        draw_line_aa(draw, island_x, 414, island_x + 262, 414, '#100b07', 1)
        draw_line_aa(draw, island_x, 417, island_x + 262, 417, '#e0be5a', 1.8)

        # Elbow Joint line at y=418
        draw_line_aa(draw, island_x, 418, island_x + 262, 418, '#0b0f16', 1.2)

        # 2. Lower Arm / Forearm (y=419..466):
        # Base leather wrap
        draw.rectangle(scale_rect(island_x, 419, 262, 48), fill=hex_to_rgba('#1e1610'))
        # Lacing on side/back faces
        for ly in [428, 438, 448, 458]:
            draw_line_aa(draw, island_x + 20, ly, island_x + 240, ly, '#38281d', 1)

        # Ornate Silver-Blue Steel Vambrace on FRONT face:
        # Col 3 for Left Arm (217..280); Col 0 for Right Arm (308..371)
        front_x = (island_x + 198) if is_left else island_x
        fcx = front_x + 32

        vambrace_pts = [
            (front_x + 6, 421), (front_x + 58, 421),
            (front_x + 56, 463), (fcx, 466), (front_x + 8, 463)
        ]
        draw_polygon_aa(draw, vambrace_pts, fill=hex_to_rgba('#65778e'), outline='#d4af37', width=2.0)
        # Inner metallic highlight
        inner_pts = [
            (front_x + 12, 424), (front_x + 52, 424),
            (front_x + 50, 458), (fcx, 461), (front_x + 14, 458)
        ]
        draw_polygon_aa(draw, inner_pts, fill=hex_to_rgba('#889eb7'))
        draw_line_aa(draw, fcx, 425, fcx, 459, '#dce8f5', 1.8)

        # Center glowing cyan frost rune diamond on the vambrace
        draw_cyan_frost_rune(draw, fcx, 442, rx=5, ry=7)
        # Double gold trim highlight
        draw_line_aa(draw, front_x + 10, 423, front_x + 54, 423, '#fff3c2', 1.0)
        draw_line_aa(draw, front_x + 10, 461, front_x + 54, 461, '#fff3c2', 1.0)

        # Corner rivets
        draw_rivet(draw, front_x + 12, 426, 2)
        draw_rivet(draw, front_x + 52, 426, 2)
        draw_rivet(draw, front_x + 14, 456, 2)
        draw_rivet(draw, front_x + 50, 456, 2)

        # Wrist Joint line at y=467
        draw_line_aa(draw, island_x, 467, island_x + 262, 467, '#0d121a', 1.2)

        # 3. Hand / Gauntlet (y=468..482): Heavy leather combat gauntlet with plate knuckles
        draw.rectangle(scale_rect(island_x, 468, 262, 15), fill=hex_to_rgba('#18120d'))
        draw_line_aa(draw, island_x, 468, island_x + 262, 468, '#d4af37', 1.5)
        # Silver-blue steel knuckle reinforcement plate with gold welt
        draw.rectangle(scale_rect(front_x + 8, 471, 48, 8), fill=hex_to_rgba('#5c6e84'), outline='#e0be5a')
        draw_line_aa(draw, front_x + 12, 475, front_x + 52, 475, '#cce0f2', 1.2)
        # Palm on DOWN face
        draw.rectangle(scale_rect(up_x, 485, 64, 64), fill=hex_to_rgba('#120d09'))
        draw_line_aa(draw, up_x + 10, 510, up_x + 54, 510, '#2e2017', 1.5)

    draw_ornate_arm(19, is_left=True)
    draw_ornate_arm(308, is_left=False)

    res = canvas.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
    noise = generate_metal_noise(WIDTH, HEIGHT, seed=303)
    arr = np.array(res).astype(float)
    for c in range(3):
        arr[:, :, c] = np.clip(arr[:, :, c] + noise * 12.0, 0, 255)
    return Image.fromarray(arr.astype(np.uint8))

def generate_ornate_guard_pants():
    canvas = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # -------------------------------------------------------------
    # 1. OPTIONAL PELVIS / LOWER TORSO (Matching Midnight Navy & Belt)
    # -------------------------------------------------------------
    apply_midnight_gambeson_pattern(draw, 165, 171, 388, 31, base_col='#121924', seam_col='#1c2637')
    apply_midnight_gambeson_pattern(draw, 231, 204, 128, 64, base_col='#0f141d', seam_col='#18212f')

    # Heavy Leather Belt across y=183..197
    draw.rectangle(scale_rect(165, 183, 388, 14), fill=hex_to_rgba('#221812'))
    draw_line_aa(draw, 165, 183, 552, 183, '#d4af37', 1.2)
    draw_line_aa(draw, 165, 197, 552, 197, '#100b07', 1.2)
    fcx = 295
    draw.ellipse(scale_rect(fcx - 12, 179, 24, 22), fill=hex_to_rgba('#161c24'), outline=hex_to_rgba('#e0be5a'), width=SCALE)
    draw.ellipse(scale_rect(fcx - 8, 183, 16, 14), fill=hex_to_rgba('#2f3b4c'), outline=hex_to_rgba('#8ea2ba'))
    draw_cyan_frost_rune(draw, fcx, 190, rx=4, ry=5)

    # -------------------------------------------------------------
    # 2. LEGS (Left: 19..280; Right: 308..569, y=355..482)
    # -------------------------------------------------------------
    def draw_ornate_leg(island_x, is_left):
        # 1. Upper Leg / Thigh (y=355..417): Midnight navy reinforced trousers
        apply_midnight_gambeson_pattern(draw, island_x, 355, 262, 63, base_col='#141c28', seam_col='#1e2a3c')
        up_x = 217 if is_left else 308
        apply_midnight_gambeson_pattern(draw, up_x, 290, 64, 64, base_col='#101620', seam_col='#182230')

        # Double gold outer side piping
        outer_col_x = (island_x + 4) if is_left else (island_x + 258)
        draw_line_aa(draw, outer_col_x, 355, outer_col_x, 417, '#d4af37', 2.0)
        draw_line_aa(draw, outer_col_x + (1 if is_left else -1), 355, outer_col_x + (1 if is_left else -1), 417, '#fff3c2', 0.8)

        # Leather thigh harness strap with gold buckle at y=396..405
        draw.rectangle(scale_rect(island_x, 396, 262, 9), fill=hex_to_rgba('#281c14'))
        draw_line_aa(draw, island_x, 396, island_x + 262, 396, '#563e2d', 1)
        draw_line_aa(draw, island_x, 405, island_x + 262, 405, '#100b07', 1)

        # Front thigh seam & gold rune diamond
        front_x = (island_x + 198) if is_left else island_x
        fcx = front_x + 32
        draw_line_aa(draw, fcx, 355, fcx, 410, '#8ca0b8', 1.2)
        draw_diamond_aa(draw, fcx, 385, 6, 9, fill=hex_to_rgba('#16212e'), outline='#d4af37', width=1.5)
        draw_cyan_frost_rune(draw, fcx, 385, rx=3, ry=5)

        # 2. Articulated Pointed Knee Cop / Poleyn (Spanning across y=410..428 on FRONT face)
        knee_pts = [
            (front_x + 8, 412), (fcx, 407), (front_x + 56, 412),
            (front_x + 54, 430), (fcx, 437), (front_x + 10, 430)
        ]
        draw_polygon_aa(draw, knee_pts, fill=hex_to_rgba('#65778e'), outline='#d4af37', width=2.2)
        inner_knee = [
            (front_x + 14, 415), (fcx, 411), (front_x + 50, 415),
            (front_x + 48, 427), (fcx, 433), (front_x + 16, 427)
        ]
        draw_polygon_aa(draw, inner_knee, fill=hex_to_rgba('#8ca2bd'))
        draw_line_aa(draw, fcx, 412, fcx, 433, '#e2effc', 1.8)

        # Glowing Cyan Frost Rune on the knee cop
        draw_cyan_frost_rune(draw, fcx, 422, rx=6, ry=8)
        draw_rivet(draw, front_x + 14, 416, 2)
        draw_rivet(draw, front_x + 50, 416, 2)

        # Knee Joint seam at y=418 across other faces
        draw_line_aa(draw, island_x, 418, island_x + 262, 418, '#0d121a', 1.2)

        # 3. Lower Leg / Shin & Calf (y=419..466):
        draw.rectangle(scale_rect(island_x, 419, 262, 48), fill=hex_to_rgba('#141c28'))
        for sy in [435, 447, 458]:
            draw.rectangle(scale_rect(island_x, sy, 262, 7), fill=hex_to_rgba('#281c14'))
            draw_line_aa(draw, island_x, sy, island_x + 262, sy, '#563e2d', 0.8)
            draw_line_aa(draw, island_x, sy + 7, island_x + 262, sy + 7, '#100b07', 0.8)
            draw.rectangle(scale_rect(outer_col_x - 3, sy - 1, 7, 9), fill=hex_to_rgba('#e0be5a'), outline='#3a2608')

        # Ornate Silver-Blue Steel Shin Greave on FRONT face (y=432..465)
        greave_pts = [
            (front_x + 11, 434), (front_x + 53, 434),
            (front_x + 49, 465), (fcx, 467), (front_x + 15, 465)
        ]
        draw_polygon_aa(draw, greave_pts, fill=hex_to_rgba('#5a6c82'), outline='#d4af37', width=2.0)
        inner_greave = [
            (front_x + 17, 437), (front_x + 47, 437),
            (front_x + 45, 462), (fcx, 464), (front_x + 19, 462)
        ]
        draw_polygon_aa(draw, inner_greave, fill=hex_to_rgba('#7d93ab'))
        draw_line_aa(draw, fcx, 437, fcx, 463, '#dce8f5', 1.8)

        # Glowing Cyan Frost Rune Petroglyph on Shin Greave
        draw_cyan_frost_rune(draw, fcx, 449, rx=5, ry=7)
        draw_rivet(draw, front_x + 17, 438, 2)
        draw_rivet(draw, front_x + 47, 438, 2)
        draw_rivet(draw, front_x + 19, 461, 2)
        draw_rivet(draw, front_x + 45, 461, 2)

        # Ankle Joint seam at y=467
        draw_line_aa(draw, island_x, 467, island_x + 262, 467, '#0d121a', 1.2)

        # 4. Boots / Foot (y=468..482 and DOWN y=485..548):
        draw.rectangle(scale_rect(island_x, 468, 262, 15), fill=hex_to_rgba('#18120d'))
        draw_line_aa(draw, island_x, 468, island_x + 262, 468, '#d4af37', 1.5)
        # Steel toe cap on Front face
        draw.rectangle(scale_rect(front_x + 12, 471, 40, 9), fill=hex_to_rgba('#5c6e84'), outline='#e0be5a')
        draw_line_aa(draw, front_x + 16, 475, front_x + 48, 475, '#cce0f2', 1.2)
        draw_rivet(draw, fcx, 475, 2)
        draw.rectangle(scale_rect(up_x, 485, 64, 64), fill=hex_to_rgba('#100b08'))
        for ty in range(492, 545, 10):
            draw_line_aa(draw, up_x + 8, ty, up_x + 56, ty, '#261b13', 2.0)

    draw_ornate_leg(19, is_left=True)
    draw_ornate_leg(308, is_left=False)

    res = canvas.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
    noise = generate_metal_noise(WIDTH, HEIGHT, seed=404)
    arr = np.array(res).astype(float)
    for c in range(3):
        arr[:, :, c] = np.clip(arr[:, :, c] + noise * 12.0, 0, 255)
    return Image.fromarray(arr.astype(np.uint8))

def apply_template_mask(image, template_path, is_pants=False):
    tmpl = Image.open(template_path).convert('RGB')
    arr_t = np.array(tmpl)
    
    island_mask = np.zeros((HEIGHT, WIDTH), dtype=bool)

    if not is_pants:
        island_mask[8:72, 231:359] = True      # UP
        island_mask[74:202, 165:553] = True    # Middle R, F, L, B
        island_mask[204:268, 231:359] = True   # DOWN
    else:
        island_mask[171:202, 165:553] = True   # LowerTorso
        island_mask[204:268, 231:359] = True   # DOWN

    island_mask[290:354, 217:281] = True   # UP
    island_mask[355:483, 19:281] = True    # Middle L, B, R, F
    island_mask[485:549, 217:281] = True   # DOWN

    island_mask[290:354, 308:372] = True   # UP
    island_mask[355:483, 308:570] = True   # Middle F, L, B, R
    island_mask[485:549, 308:372] = True   # DOWN

    valid_mask = island_mask
    img_arr = np.array(image)
    img_arr[~valid_mask, 3] = 0

    return Image.fromarray(img_arr)

def main():
    print("Generating Ornate Guard of Valgard Shirt v5 (EST-33 Paladin Frost standard)...")
    shirt = generate_ornate_guard_shirt()
    shirt = apply_template_mask(shirt, 'Assets/Source/References/Roblox-Classic-Clothing-Templates/Template-Shirts-R15v2.png', is_pants=False)
    shirt_out = 'Assets/Clothing/EST-52/BodySkins/Guard/guard_valgard_classic_shirt_r15_v5.png'
    shirt.save(shirt_out, 'PNG')
    print(f"Saved: {shirt_out} ({shirt.size}, mode={shirt.mode})")

    print("Generating Ornate Guard of Valgard Pants v5 (EST-33 Paladin Frost standard)...")
    pants = generate_ornate_guard_pants()
    pants = apply_template_mask(pants, 'Assets/Source/References/Roblox-Classic-Clothing-Templates/Template-Pants-R15v2.png', is_pants=True)
    pants_out = 'Assets/Clothing/EST-52/BodySkins/Guard/guard_valgard_classic_pants_r15_v5.png'
    pants.save(pants_out, 'PNG')
    print(f"Saved: {pants_out} ({pants.size}, mode={pants.mode})")

if __name__ == '__main__':
    main()
