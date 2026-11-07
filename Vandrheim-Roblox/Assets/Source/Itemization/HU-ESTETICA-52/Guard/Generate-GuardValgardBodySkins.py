"""
Generate-GuardValgardBodySkins.py
Generates the high-fidelity Guard of Valgard classic body skins (Shirt and Pants)
for Roblox R15 avatars, strictly adhering to:
1. Template-Shirts-R15v2.png and Template-Pants-R15v2.png (585x559, RGBA).
2. The high visual fidelity standard of EST-33 (brushed cold steel plates, bevelled bronze trim,
   Norse knotwork diamonds, brass rivets, quilted dark leather undertunic, utility belt with
   forged iron buckle, and realistic ambient occlusion).
3. Exact R15 cut lines:
   - Torso: UpperTorso (y=74..169), Joint seam (y=170), LowerTorso (y=171..201), DOWN (y=204..267).
   - Limbs: Upper (y=355..417), Joint seam (y=418), Lower (y=419..466), Joint seam (y=467), Hand/Foot (y=468..482).
"""

import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

WIDTH = 585
HEIGHT = 559
SCALE = 2  # 2x supersampling for crisp anti-aliased geometry and fine texture micro-detail

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
    # Contact drop shadow
    draw.ellipse([scx - sr, scy - sr + 1, scx + sr, scy + sr + 1], fill=hex_to_rgba('#140e08'))
    # Antique bronze rivet head
    draw.ellipse([scx - sr, scy - sr, scx + sr, scy + sr], fill=hex_to_rgba('#c49945'))
    # Specular glint
    glint_r = max(1, sr // 2)
    draw.ellipse([scx - glint_r, scy - glint_r, scx, scy], fill=hex_to_rgba('#fff2c2'))

def generate_metal_noise(w, h, seed=42):
    np.random.seed(seed)
    raw = np.random.normal(0, 1, (h, w))
    im_noise = Image.fromarray((raw * 40 + 128).clip(0, 255).astype(np.uint8))
    im_noise = im_noise.filter(ImageFilter.GaussianBlur(1.2))
    noise_arr = (np.array(im_noise).astype(float) - 128) / 128.0

    # Horizontal streaks (brushed steel)
    raw_s = np.random.normal(0, 1, (h, 1))
    streaks = np.repeat(raw_s, w, axis=1)
    im_s = Image.fromarray((streaks * 25 + 128).clip(0, 255).astype(np.uint8))
    im_s = im_s.filter(ImageFilter.GaussianBlur(1.8))
    streak_arr = (np.array(im_s).astype(float) - 128) / 128.0

    return (noise_arr * 0.6 + streak_arr * 0.4)

def apply_quilted_leather_pattern(draw, x, y, w, h, base_col='#1a1d24', seam_col='#242933', stitch_col='#524330'):
    sx0, sy0, sx1, sy1 = scale_rect(x, y, w, h)
    draw.rectangle([sx0, sy0, sx1, sy1], fill=hex_to_rgba(base_col))

    # Diamond quilting seams
    step = 16 * SCALE
    for d in range(sx0 - (sy1 - sy0), sx1 + (sy1 - sy0), step):
        draw.line([(d, sy0), (d + (sy1 - sy0), sy1)], fill=hex_to_rgba(seam_col), width=SCALE)
        draw.line([(d, sy1), (d + (sy1 - sy0), sy0)], fill=hex_to_rgba(seam_col), width=SCALE)

def generate_guard_shirt():
    canvas = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # -------------------------------------------------------------
    # 1. TORSO UNDERLAYER (Dark Quilted Nordic Gambeson)
    # -------------------------------------------------------------
    # Middle row faces: R(165..229), F(231..358), L(359..423), B(425..552)
    # UpperTorso: y=74..169. LowerTorso: y=171..201.
    apply_quilted_leather_pattern(draw, 165, 74, 388, 128, base_col='#1a1d24', seam_col='#242933')
    # Torso UP (neck/shoulders: 231..358, 8..71)
    apply_quilted_leather_pattern(draw, 231, 8, 128, 64, base_col='#15181f', seam_col='#20242c')
    # Torso DOWN (tunic underside: 231..358, 204..267)
    apply_quilted_leather_pattern(draw, 231, 204, 128, 64, base_col='#121419', seam_col='#191c22')

    # Side faces decorative piping and side straps (R & L)
    for side_x, side_w in [(165, 65), (359, 65)]:
        draw_line_aa(draw, side_x + 5, 74, side_x + 5, 169, '#a88338', 1.5)
        draw_line_aa(draw, side_x + side_w - 5, 74, side_x + side_w - 5, 169, '#a88338', 1.5)
        # Leather flank straps with iron buckles connecting breastplate and backplate
        for sy in [105, 140]:
            draw.rectangle(scale_rect(side_x + 6, sy, side_w - 12, 10), fill=hex_to_rgba('#2b1f17'))
            draw_line_aa(draw, side_x + 6, sy, side_x + side_w - 6, sy, '#483427', 1)
            draw_line_aa(draw, side_x + 6, sy + 10, side_x + side_w - 6, sy + 10, '#140e0a', 1)
            bcx = side_x + side_w // 2
            draw.rectangle(scale_rect(bcx - 4, sy - 2, 8, 14), fill=hex_to_rgba('#657383'), outline=hex_to_rgba('#20262d'))

    # -------------------------------------------------------------
    # 2. TORSO FRONT (Cuirass, Gorget, Norse Knotwork, Belt)
    # -------------------------------------------------------------
    fx0, fx1 = 231, 358
    fcx = 295

    # Collar / Neckline on Front Upper
    draw_polygon_aa(draw, [(250, 74), (fcx, 90), (340, 74), (325, 74), (fcx, 85), (265, 74)], fill=hex_to_rgba('#0d0f14'))
    draw_line_aa(draw, 250, 74, fcx, 90, '#b88a42', 2.0)
    draw_line_aa(draw, 340, 74, fcx, 90, '#b88a42', 2.0)

    # Main Cold Steel Breastplate (Anatomical Nordic Cuirass)
    cuirass_pts = [
        (244, 88), (346, 88),
        (355, 118), (342, 155),
        (fcx, 169),  # Point ends exactly at UpperTorso joint line y=170
        (248, 155), (235, 118)
    ]
    draw_polygon_aa(draw, cuirass_pts, fill=hex_to_rgba('#586576'), outline=hex_to_rgba('#252d37'), width=2.5)

    # Metallic specular highlights on chest plates (left and right pecs)
    pec_left = [(248, 93), (fcx - 5, 98), (fcx - 8, 145), (252, 150), (240, 119)]
    pec_right = [(342, 93), (fcx + 5, 98), (fcx + 8, 145), (338, 150), (350, 119)]
    draw_polygon_aa(draw, pec_left, fill=hex_to_rgba('#8294a8'))
    draw_polygon_aa(draw, pec_right, fill=hex_to_rgba('#748598'))

    # High specular brushed glints
    draw_line_aa(draw, 256, 102, 285, 108, '#c8d8e8', 1.5)
    draw_line_aa(draw, 334, 102, 305, 108, '#bcd0e2', 1.5)
    draw_line_aa(draw, 252, 132, 282, 140, '#424f5e', 1.5)
    draw_line_aa(draw, 338, 132, 308, 140, '#424f5e', 1.5)

    # Antique Bronze Trim around Cuirass Contour
    for i in range(len(cuirass_pts)):
        p1 = cuirass_pts[i]
        p2 = cuirass_pts[(i + 1) % len(cuirass_pts)]
        draw_line_aa(draw, p1[0], p1[1], p2[0], p2[1], '#c89e47', 2.0)
        draw_line_aa(draw, p1[0], p1[1] + 1, p2[0], p2[1] + 1, '#684d1a', 1.0)

    # Rivets along Cuirass Outer Perimeter
    rivet_pts = [(247, 95), (240, 120), (249, 150), (343, 95), (350, 120), (341, 150)]
    for rx, ry in rivet_pts:
        draw_rivet(draw, rx, ry, 2)

    # Center Gorget and Norse Knotwork Crest
    gorget_pts = [(fcx - 12, 90), (fcx + 12, 90), (fcx + 16, 135), (fcx, 158), (fcx - 16, 135)]
    draw_polygon_aa(draw, gorget_pts, fill=hex_to_rgba('#2a323d'), outline=hex_to_rgba('#d4b66b'), width=1.8)
    draw_line_aa(draw, fcx, 92, fcx, 155, '#f0d685', 1.2)
    # Knotwork diamonds
    draw_diamond_aa(draw, fcx, 112, 8, 11, fill=hex_to_rgba('#1c232c'), outline='#e8ca7b', width=1.5)
    draw_diamond_aa(draw, fcx, 112, 4, 6, fill=hex_to_rgba('#8ba4bc'), outline='#ffffff', width=1.0)
    draw_diamond_aa(draw, fcx, 135, 6, 8, fill=hex_to_rgba('#1c232c'), outline='#d4b66b', width=1.2)

    # Joint line at y=170 (Purple Seam in template v2) - dark crease
    draw_line_aa(draw, fx0, 170, fx1, 170, '#111419', 1.5)

    # -------------------------------------------------------------
    # 3. LOWER TORSO FRONT (Fauld, Heavy Utility Belt, Norse Buckle)
    # -------------------------------------------------------------
    # y=171..201 (31 px height)
    draw_polygon_aa(draw, [(246, 171), (fcx, 175), (344, 171), (348, 182), (242, 182)], fill=hex_to_rgba('#485566'), outline='#b88a42', width=1.2)
    draw_line_aa(draw, 255, 177, 335, 177, '#7b8c9f', 1.0)

    # Heavy Dark Leather Utility Belt across y=183..197 (14 px high)
    draw.rectangle(scale_rect(fx0, 183, 128, 14), fill=hex_to_rgba('#281c15'))
    draw_line_aa(draw, fx0, 183, fx1, 183, '#483427', 1.2)
    draw_line_aa(draw, fx0, 197, fx1, 197, '#140e0a', 1.2)
    draw_line_aa(draw, fx0, 185, fx1, 185, '#5a4231', 0.8)
    draw_line_aa(draw, fx0, 195, fx1, 195, '#5a4231', 0.8)

    # Ornate Norse Forged Iron & Bronze Buckle at Center (fcx=295, y=190)
    draw.rectangle(scale_rect(fcx - 14, 181, 28, 18), fill=hex_to_rgba('#1d2229'), outline=hex_to_rgba('#d4b66b'))
    draw.rectangle(scale_rect(fcx - 10, 184, 20, 12), fill=hex_to_rgba('#3c4754'), outline=hex_to_rgba('#8d9faa'))
    draw_line_aa(draw, fcx, 181, fcx, 199, '#f0d685', 2.0)
    draw_line_aa(draw, fcx - 8, 190, fcx + 8, 190, '#f0d685', 1.5)
    draw_rivet(draw, fcx - 18, 190, 2)
    draw_rivet(draw, fcx + 18, 190, 2)

    # Hanging tassets / tunic leather hem at bottom (y=198..201)
    draw.rectangle(scale_rect(fx0, 198, 128, 4), fill=hex_to_rgba('#1c2027'))
    draw_line_aa(draw, fx0, 201, fx1, 201, '#a88338', 1.2)

    # -------------------------------------------------------------
    # 4. TORSO BACK (B: 425..552, y=74..201)
    # -------------------------------------------------------------
    bx0, bx1 = 425, 552
    bcx = 488
    back_pts = [(438, 88), (538, 88), (544, 169), (bcx, 172), (432, 169)]
    draw_polygon_aa(draw, back_pts, fill=hex_to_rgba('#4a5768'), outline='#9e7e38', width=2.0)
    draw.rectangle(scale_rect(bcx - 5, 88, 10, 82), fill=hex_to_rgba('#333d49'), outline='#b88a42')
    draw_line_aa(draw, bcx, 90, bcx, 168, '#8ba0b5', 1.5)
    draw_line_aa(draw, 442, 105, 475, 115, '#75879a', 1.2)
    draw_line_aa(draw, 534, 105, 501, 115, '#75879a', 1.2)
    # Back belt continuing seamlessly
    draw.rectangle(scale_rect(bx0, 183, 128, 14), fill=hex_to_rgba('#281c15'))
    draw_line_aa(draw, bx0, 183, bx1, 183, '#483427', 1.2)
    draw_line_aa(draw, bx0, 197, bx1, 197, '#140e0a', 1.2)
    draw.rectangle(scale_rect(bcx - 6, 182, 12, 16), fill=hex_to_rgba('#483427'), outline='#1c2229')

    # -------------------------------------------------------------
    # 5. ARMS (Left Arm: 19..280; Right Arm: 308..569, y=355..482)
    # -------------------------------------------------------------
    def draw_arm(island_x, is_left):
        # 1. Upper Arm (y=355..417): Quilted dark leather sleeve
        apply_quilted_leather_pattern(draw, island_x, 355, 262, 63, base_col='#1a1d24', seam_col='#242933')
        up_x = 217 if is_left else 308
        apply_quilted_leather_pattern(draw, up_x, 290, 64, 64, base_col='#161920', seam_col='#20242d')
        # Leather bicep strap with bronze buckle at y=405..414
        draw.rectangle(scale_rect(island_x, 405, 262, 9), fill=hex_to_rgba('#2b1f17'))
        draw_line_aa(draw, island_x, 405, island_x + 262, 405, '#483427', 1)
        draw_line_aa(draw, island_x, 414, island_x + 262, 414, '#140e0a', 1)
        draw_line_aa(draw, island_x, 417, island_x + 262, 417, '#b88a42', 1.5)

        # Joint line at y=418 (Elbow)
        draw_line_aa(draw, island_x, 418, island_x + 262, 418, '#0f1217', 1.2)

        # 2. Lower Arm / Forearm (y=419..466):
        draw.rectangle(scale_rect(island_x, 419, 262, 48), fill=hex_to_rgba('#221913'))
        for ly in [428, 438, 448, 458]:
            draw_line_aa(draw, island_x + 20, ly, island_x + 240, ly, '#38271e', 1)

        # Cold Steel Vambrace / Bracer on FRONT face:
        # Col 3 for Left Arm (217..280); Col 0 for Right Arm (308..371)
        front_x = (island_x + 198) if is_left else island_x
        fcx = front_x + 32

        vambrace_pts = [
            (front_x + 6, 421), (front_x + 58, 421),
            (front_x + 56, 463), (fcx, 466), (front_x + 8, 463)
        ]
        draw_polygon_aa(draw, vambrace_pts, fill=hex_to_rgba('#627082'), outline='#b88a42', width=1.8)
        inner_pts = [
            (front_x + 12, 424), (front_x + 52, 424),
            (front_x + 50, 458), (fcx, 461), (front_x + 14, 458)
        ]
        draw_polygon_aa(draw, inner_pts, fill=hex_to_rgba('#8294a8'))
        draw_line_aa(draw, fcx, 425, fcx, 459, '#c8d8e8', 1.5)
        draw_diamond_aa(draw, fcx, 442, 6, 8, fill=hex_to_rgba('#1c232c'), outline='#e5c779', width=1.2)
        draw_rivet(draw, front_x + 12, 426, 2)
        draw_rivet(draw, front_x + 52, 426, 2)
        draw_rivet(draw, front_x + 14, 456, 2)
        draw_rivet(draw, front_x + 50, 456, 2)

        # Wrist Joint line at y=467
        draw_line_aa(draw, island_x, 467, island_x + 262, 467, '#111419', 1.2)

        # 3. Hand / Gauntlet (y=468..482): Heavy dark leather gauntlet
        draw.rectangle(scale_rect(island_x, 468, 262, 15), fill=hex_to_rgba('#1a1614'))
        draw_line_aa(draw, island_x, 468, island_x + 262, 468, '#b88a42', 1.2)
        draw.rectangle(scale_rect(front_x + 8, 471, 48, 8), fill=hex_to_rgba('#4f5b6b'), outline='#78889a')
        draw_line_aa(draw, front_x + 12, 475, front_x + 52, 475, '#a4b6c8', 1.0)
        draw.rectangle(scale_rect(up_x, 485, 64, 64), fill=hex_to_rgba('#14100e'))
        draw_line_aa(draw, up_x + 10, 510, up_x + 54, 510, '#2e2520', 1.5)

    draw_arm(19, is_left=True)
    draw_arm(308, is_left=False)

    # Downscale supersampled canvas to 585x559 with Lanczos
    res = canvas.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)

    # Apply metallic texture grain onto plates
    noise = generate_metal_noise(WIDTH, HEIGHT, seed=101)
    arr = np.array(res).astype(float)
    # Modulate RGB channels with subtle brushed noise
    for c in range(3):
        arr[:, :, c] = np.clip(arr[:, :, c] + noise * 12.0, 0, 255)
    return Image.fromarray(arr.astype(np.uint8))

def generate_guard_pants():
    canvas = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # -------------------------------------------------------------
    # 1. OPTIONAL PELVIS / LOWER TORSO (Matching Charcoal Trousers & Tassets)
    # -------------------------------------------------------------
    apply_quilted_leather_pattern(draw, 165, 171, 388, 31, base_col='#1a1d24', seam_col='#242933')
    apply_quilted_leather_pattern(draw, 231, 204, 128, 64, base_col='#14171d', seam_col='#1c2027')

    # Heavy Dark Leather Belt across y=183..197
    draw.rectangle(scale_rect(165, 183, 388, 14), fill=hex_to_rgba('#281c15'))
    draw_line_aa(draw, 165, 183, 552, 183, '#483427', 1.2)
    draw_line_aa(draw, 165, 197, 552, 197, '#140e0a', 1.2)
    fcx = 295
    draw.rectangle(scale_rect(fcx - 14, 181, 28, 18), fill=hex_to_rgba('#1d2229'), outline=hex_to_rgba('#d4b66b'))
    draw.rectangle(scale_rect(fcx - 10, 184, 20, 12), fill=hex_to_rgba('#3c4754'), outline=hex_to_rgba('#8d9faa'))
    draw_line_aa(draw, fcx, 181, fcx, 199, '#f0d685', 2.0)
    draw_line_aa(draw, fcx - 8, 190, fcx + 8, 190, '#f0d685', 1.5)

    # -------------------------------------------------------------
    # 2. LEGS (Left Leg: 19..280; Right Leg: 308..569, y=355..482)
    # -------------------------------------------------------------
    def draw_leg(island_x, is_left):
        # 1. Upper Leg / Thigh (y=355..417): Heavy reinforced charcoal wool & leather trousers
        apply_quilted_leather_pattern(draw, island_x, 355, 262, 63, base_col='#1e222a', seam_col='#282d38')
        up_x = 217 if is_left else 308
        apply_quilted_leather_pattern(draw, up_x, 290, 64, 64, base_col='#181b22', seam_col='#222730')

        # Bronze outer side seam piping
        outer_col_x = (island_x + 4) if is_left else (island_x + 258)
        draw_line_aa(draw, outer_col_x, 355, outer_col_x, 417, '#b88a42', 1.8)

        # Leather thigh harness strap with iron buckle at y=396..405
        draw.rectangle(scale_rect(island_x, 396, 262, 9), fill=hex_to_rgba('#2b1f17'))
        draw_line_aa(draw, island_x, 396, island_x + 262, 396, '#483427', 1)
        draw_line_aa(draw, island_x, 405, island_x + 262, 405, '#140e0a', 1)

        # Front thigh seam
        front_x = (island_x + 198) if is_left else island_x
        fcx = front_x + 32
        draw_line_aa(draw, fcx, 355, fcx, 410, '#75889c', 1.2)
        draw_diamond_aa(draw, fcx, 385, 5, 8, fill=hex_to_rgba('#1c232c'), outline='#b88a42', width=1.2)

        # 2. Articulated Knee Cop / Poleyn (Spanning across y=410..428 on FRONT face)
        knee_pts = [
            (front_x + 8, 412), (fcx, 408), (front_x + 56, 412),
            (front_x + 54, 430), (fcx, 436), (front_x + 10, 430)
        ]
        draw_polygon_aa(draw, knee_pts, fill=hex_to_rgba('#728092'), outline='#c89e47', width=2.0)
        inner_knee = [
            (front_x + 14, 415), (fcx, 412), (front_x + 50, 415),
            (front_x + 48, 427), (fcx, 432), (front_x + 16, 427)
        ]
        draw_polygon_aa(draw, inner_knee, fill=hex_to_rgba('#95a7bc'))
        draw_line_aa(draw, fcx, 413, fcx, 432, '#d4e4f4', 1.5)
        draw_diamond_aa(draw, fcx, 422, 6, 8, fill=hex_to_rgba('#1c232c'), outline='#faeeaa', width=1.2)
        draw_rivet(draw, front_x + 14, 416, 2)
        draw_rivet(draw, front_x + 50, 416, 2)

        # Knee Joint seam at y=418 across other faces
        draw_line_aa(draw, island_x, 418, island_x + 262, 418, '#111419', 1.2)

        # 3. Lower Leg / Shin & Calf (y=419..466):
        draw.rectangle(scale_rect(island_x, 419, 262, 48), fill=hex_to_rgba('#1c2027'))
        for sy in [435, 447, 458]:
            draw.rectangle(scale_rect(island_x, sy, 262, 7), fill=hex_to_rgba('#2b1f17'))
            draw_line_aa(draw, island_x, sy, island_x + 262, sy, '#483427', 0.8)
            draw_line_aa(draw, island_x, sy + 7, island_x + 262, sy + 7, '#140e0a', 0.8)
            draw.rectangle(scale_rect(outer_col_x - 3, sy - 1, 7, 9), fill=hex_to_rgba('#5a6776'), outline='#20262d')

        # Cold Steel Shin Greave on FRONT face (y=432..465)
        greave_pts = [
            (front_x + 12, 434), (front_x + 52, 434),
            (front_x + 48, 465), (fcx, 467), (front_x + 16, 465)
        ]
        draw_polygon_aa(draw, greave_pts, fill=hex_to_rgba('#586576'), outline='#b88a42', width=1.8)
        inner_greave = [
            (front_x + 18, 437), (front_x + 46, 437),
            (front_x + 44, 462), (fcx, 464), (front_x + 20, 462)
        ]
        draw_polygon_aa(draw, inner_greave, fill=hex_to_rgba('#7a8b9e'))
        draw_line_aa(draw, fcx, 437, fcx, 463, '#b8cadc', 1.5)
        draw_rivet(draw, front_x + 18, 438, 2)
        draw_rivet(draw, front_x + 46, 438, 2)
        draw_rivet(draw, front_x + 20, 461, 2)
        draw_rivet(draw, front_x + 44, 461, 2)

        # Ankle Joint seam at y=467
        draw_line_aa(draw, island_x, 467, island_x + 262, 467, '#111419', 1.2)

        # 4. Boots / Foot (y=468..482 and DOWN y=485..548):
        draw.rectangle(scale_rect(island_x, 468, 262, 15), fill=hex_to_rgba('#1c1714'))
        draw_line_aa(draw, island_x, 468, island_x + 262, 468, '#b88a42', 1.2)
        # Steel toe cap on Front face
        draw.rectangle(scale_rect(front_x + 12, 471, 40, 9), fill=hex_to_rgba('#525e6e'), outline='#8596a7')
        draw_line_aa(draw, front_x + 16, 475, front_x + 48, 475, '#adc1d4', 1.2)
        draw_rivet(draw, fcx, 475, 2)
        draw.rectangle(scale_rect(up_x, 485, 64, 64), fill=hex_to_rgba('#120f0d'))
        for ty in range(492, 545, 10):
            draw_line_aa(draw, up_x + 8, ty, up_x + 56, ty, '#2a221d', 2.0)

    draw_leg(19, is_left=True)
    draw_leg(308, is_left=False)

    res = canvas.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
    noise = generate_metal_noise(WIDTH, HEIGHT, seed=202)
    arr = np.array(res).astype(float)
    for c in range(3):
        arr[:, :, c] = np.clip(arr[:, :, c] + noise * 12.0, 0, 255)
    return Image.fromarray(arr.astype(np.uint8))

def apply_template_mask(image, template_path, is_pants=False):
    tmpl = Image.open(template_path).convert('RGB')
    arr_t = np.array(tmpl)
    
    island_mask = np.zeros((HEIGHT, WIDTH), dtype=bool)

    if not is_pants:
        # Torso
        island_mask[8:72, 231:359] = True      # UP
        island_mask[74:202, 165:553] = True    # Middle R, F, L, B
        island_mask[204:268, 231:359] = True   # DOWN
    else:
        # Pelvis / LowerTorso matching EST-33
        island_mask[171:202, 165:553] = True   # LowerTorso fauld/belt
        island_mask[204:268, 231:359] = True   # DOWN crotch

    # Left limb
    island_mask[290:354, 217:281] = True   # UP
    island_mask[355:483, 19:281] = True    # Middle L, B, R, F
    island_mask[485:549, 217:281] = True   # DOWN

    # Right limb
    island_mask[290:354, 308:372] = True   # UP
    island_mask[355:483, 308:570] = True   # Middle F, L, B, R
    island_mask[485:549, 308:372] = True   # DOWN

    valid_mask = island_mask
    img_arr = np.array(image)
    img_arr[~valid_mask, 3] = 0

    return Image.fromarray(img_arr)

def main():
    print("Generating Guard of Valgard Shirt v4 (Enhanced EST-33 quality)...")
    shirt = generate_guard_shirt()
    shirt = apply_template_mask(shirt, 'Assets/Source/References/Roblox-Classic-Clothing-Templates/Template-Shirts-R15v2.png', is_pants=False)
    shirt_out = 'Assets/Clothing/EST-52/BodySkins/Guard/guard_valgard_classic_shirt_r15_v4.png'
    shirt.save(shirt_out, 'PNG')
    print(f"Saved: {shirt_out} ({shirt.size}, mode={shirt.mode})")

    print("Generating Guard of Valgard Pants v4 (Enhanced EST-33 quality)...")
    pants = generate_guard_pants()
    pants = apply_template_mask(pants, 'Assets/Source/References/Roblox-Classic-Clothing-Templates/Template-Pants-R15v2.png', is_pants=True)
    pants_out = 'Assets/Clothing/EST-52/BodySkins/Guard/guard_valgard_classic_pants_r15_v4.png'
    pants.save(pants_out, 'PNG')
    print(f"Saved: {pants_out} ({pants.size}, mode={pants.mode})")

if __name__ == '__main__':
    main()
