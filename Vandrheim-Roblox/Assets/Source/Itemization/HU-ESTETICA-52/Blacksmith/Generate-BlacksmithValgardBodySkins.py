"""
Generate-BlacksmithValgardBodySkins.py
Generates the high-fidelity Blacksmith of Valgard classic body skins (Shirt and Pants)
for Roblox R15 avatars, strictly adhering to:
1. Template-Shirts-R15v2.png and Template-Pants-R15v2.png (585x559, RGBA).
2. The high visual fidelity standard of EST-33 (rich weathered leather grain, scorched/soot patina,
   coarse linen weave, brass rivets, forged iron buckle, crossed harness straps, tool pouches,
   and heat-resistant protective smithing gear).
3. STRICTLY NO HELMET, NO SHOULDER PADS (Blacksmith work attire only).
4. Exact R15 cut lines:
   - Torso: UpperTorso (y=74..169), Joint seam (y=170), LowerTorso (y=171..201), DOWN (y=204..267).
   - Limbs: Upper (y=355..417), Joint seam (y=418), Lower (y=419..466), Joint seam (y=467), Hand/Foot (y=468..482).
"""

import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

WIDTH = 585
HEIGHT = 559
SCALE = 2  # 2x supersampling for razor-sharp anti-aliased rasterization

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
    draw.ellipse([scx - sr, scy - sr + 1, scx + sr, scy + sr + 1], fill=hex_to_rgba('#140e08'))
    draw.ellipse([scx - sr, scy - sr, scx + sr, scy + sr], fill=hex_to_rgba('#c49945'))
    glint_r = max(1, sr // 2)
    draw.ellipse([scx - glint_r, scy - glint_r, scx, scy], fill=hex_to_rgba('#fff2c2'))

def generate_leather_noise(w, h, seed=77):
    np.random.seed(seed)
    raw = np.random.normal(0, 1, (h, w))
    im_noise = Image.fromarray((raw * 35 + 128).clip(0, 255).astype(np.uint8))
    im_noise = im_noise.filter(ImageFilter.GaussianBlur(1.0))
    noise_arr = (np.array(im_noise).astype(float) - 128) / 128.0
    return noise_arr

def apply_tunic_weave_pattern(draw, x, y, w, h, base_col='#241e1a', seam_col='#332b25'):
    sx0, sy0, sx1, sy1 = scale_rect(x, y, w, h)
    draw.rectangle([sx0, sy0, sx1, sy1], fill=hex_to_rgba(base_col))
    # Fine cloth cross-weave texture
    step = 6 * SCALE
    for d in range(sx0, sx1, step):
        draw.line([(d, sy0), (d, sy1)], fill=hex_to_rgba(seam_col), width=1)
    for d in range(sy0, sy1, step):
        draw.line([(sx0, d), (sx1, d)], fill=hex_to_rgba(seam_col), width=1)

def generate_blacksmith_shirt():
    canvas = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # -------------------------------------------------------------
    # 1. TORSO UNDERLAYER (Dark Coarse Linen/Wool Smithing Tunic)
    # -------------------------------------------------------------
    # Middle row faces: R(165..229), F(231..358), L(359..423), B(425..552)
    # UpperTorso: y=74..169. LowerTorso: y=171..201.
    apply_tunic_weave_pattern(draw, 165, 74, 388, 128, base_col='#231d19', seam_col='#312923')
    # Torso UP (neck/shoulders)
    apply_tunic_weave_pattern(draw, 231, 8, 128, 64, base_col='#1a1512', seam_col='#261f1a')
    # Torso DOWN (tunic underside)
    apply_tunic_weave_pattern(draw, 231, 204, 128, 64, base_col='#171310', seam_col='#201915')

    # Side faces (R: 165..229 & L: 359..423):
    # Shows the exposed tunic fabric, side apron ties, and leather harness straps
    for side_x, side_w in [(165, 65), (359, 65)]:
        # Apron side tie cords
        draw_line_aa(draw, side_x + 6, 125, side_x + side_w - 6, 130, '#5a4231', 1.5)
        draw_line_aa(draw, side_x + 6, 155, side_x + side_w - 6, 150, '#5a4231', 1.5)
        # Utility belt section
        draw.rectangle(scale_rect(side_x, 183, side_w, 14), fill=hex_to_rgba('#2a1a12'))
        draw_line_aa(draw, side_x, 183, side_x + side_w, 183, '#4a3224', 1)
        draw_line_aa(draw, side_x, 197, side_x + side_w, 197, '#140c08', 1)
        # Side brass tool ring for hanging hammer / tongs
        bcx = side_x + side_w // 2
        draw.ellipse(scale_rect(bcx - 5, 186, 10, 10), outline=hex_to_rgba('#c49945'), width=SCALE)

    # -------------------------------------------------------------
    # 2. TORSO FRONT (Oiled Leather Apron Bib, Tool Sling, Belt)
    # -------------------------------------------------------------
    fx0, fx1 = 231, 358
    fcx = 295

    # Open V-neck collar of the linen tunic (visible above the apron bib)
    draw_polygon_aa(draw, [(270, 74), (fcx, 92), (320, 74)], fill=hex_to_rgba('#0d0b09'))
    # Leather laces across the open collar
    draw_line_aa(draw, 276, 80, 314, 84, '#6a4d38', 1.2)
    draw_line_aa(draw, 280, 86, 310, 88, '#6a4d38', 1.2)

    # Leather Apron Harness Straps over the shoulders
    draw.rectangle(scale_rect(248, 74, 14, 25), fill=hex_to_rgba('#382216'))
    draw.rectangle(scale_rect(328, 74, 14, 25), fill=hex_to_rgba('#382216'))
    draw_line_aa(draw, 248, 74, 248, 99, '#543624', 1)
    draw_line_aa(draw, 262, 74, 262, 99, '#1a0e08', 1)
    draw_line_aa(draw, 328, 74, 328, 99, '#543624', 1)
    draw_line_aa(draw, 342, 74, 342, 99, '#1a0e08', 1)
    # Brass harness buckles
    draw.rectangle(scale_rect(246, 90, 18, 9), fill=hex_to_rgba('#c49945'), outline=hex_to_rgba('#483412'))
    draw.rectangle(scale_rect(326, 90, 18, 9), fill=hex_to_rgba('#c49945'), outline=hex_to_rgba('#483412'))

    # Heavy Oiled Leather Smithing Apron Bib (y=98..169)
    apron_bib_pts = [
        (242, 98), (348, 98),
        (352, 140), (350, 169),
        (240, 169), (238, 140)
    ]
    draw_polygon_aa(draw, apron_bib_pts, fill=hex_to_rgba('#3d271a'), outline=hex_to_rgba('#21140c'), width=2.0)
    # Apron surface leather highlight & scorch shading
    inner_bib = [(247, 102), (343, 102), (346, 138), (345, 165), (245, 165), (243, 138)]
    draw_polygon_aa(draw, inner_bib, fill=hex_to_rgba('#4a3122'))

    # Scorched ember burn gradient near bottom of apron bib
    draw.rectangle(scale_rect(244, 150, 102, 19), fill=hex_to_rgba('#22140c'))

    # Brass reinforcement rivets along apron bib perimeter
    for rx, ry in [(245, 104), (243, 130), (243, 155), (345, 104), (347, 130), (347, 155)]:
        draw_rivet(draw, rx, ry, 2)

    # Diagonal Cross-Chest Tool Sling (holds small tools)
    draw_line_aa(draw, 252, 100, 340, 165, '#28170e', 6.0)
    draw_line_aa(draw, 252, 100, 340, 165, '#563824', 2.0)
    # Tool holster / pouch on chest sling (fcx=295, y=130)
    draw.rectangle(scale_rect(280, 120, 26, 22), fill=hex_to_rgba('#2d1a10'), outline=hex_to_rgba('#5a3922'))
    draw_line_aa(draw, 280, 126, 306, 126, '#754d30', 1.2)
    # Small forge tong handles protruding from the pouch
    draw_line_aa(draw, 288, 114, 285, 124, '#6b7582', 2.0)
    draw_line_aa(draw, 294, 112, 292, 124, '#6b7582', 2.0)

    # Seam joint line at y=170 (Purple cut line in template v2)
    draw_line_aa(draw, fx0, 170, fx1, 170, '#120b07', 1.5)

    # -------------------------------------------------------------
    # 3. LOWER TORSO FRONT (Fauld Apron Body, Heavy Utility Belt)
    # -------------------------------------------------------------
    # Lower apron body spanning y=171..201
    draw.rectangle(scale_rect(238, 171, 114, 30), fill=hex_to_rgba('#3a2417'), outline=hex_to_rgba('#1e110a'))

    # Heavy Blacksmith Utility Belt across y=183..197 (14 px high)
    draw.rectangle(scale_rect(fx0, 183, 128, 14), fill=hex_to_rgba('#281a11'))
    draw_line_aa(draw, fx0, 183, fx1, 183, '#483020', 1.2)
    draw_line_aa(draw, fx0, 197, fx1, 197, '#120905', 1.2)
    draw_line_aa(draw, fx0, 185, fx1, 185, '#5c3d28', 0.8)
    draw_line_aa(draw, fx0, 195, fx1, 195, '#5c3d28', 0.8)

    # Forged Iron Work Buckle at Center (fcx=295, y=190)
    draw.rectangle(scale_rect(fcx - 13, 181, 26, 18), fill=hex_to_rgba('#1a1f26'), outline=hex_to_rgba('#7a8b9e'))
    draw.rectangle(scale_rect(fcx - 9, 184, 18, 12), fill=hex_to_rgba('#38424e'), outline=hex_to_rgba('#95a7bc'))
    draw_line_aa(draw, fcx, 181, fcx, 199, '#c8d8e8', 2.0)
    draw_rivet(draw, fcx - 18, 190, 2)
    draw_rivet(draw, fcx + 18, 190, 2)

    # Lower Apron Hem at bottom (y=198..201)
    draw_line_aa(draw, 238, 201, 352, 201, '#1e110a', 1.5)

    # -------------------------------------------------------------
    # 4. TORSO BACK (Coarse Tunic, Crossed Apron Straps)
    # -------------------------------------------------------------
    bx0, bx1 = 425, 552
    bcx = 488

    # Crossed Leather Harness Straps (X-pattern) across back
    draw_line_aa(draw, 440, 74, 538, 180, '#382216', 5.0)
    draw_line_aa(draw, 440, 74, 538, 180, '#523422', 1.8)
    draw_line_aa(draw, 538, 74, 440, 180, '#382216', 5.0)
    draw_line_aa(draw, 538, 74, 440, 180, '#523422', 1.8)
    # Center junction brass ring
    draw.ellipse(scale_rect(bcx - 6, 122, 12, 12), outline=hex_to_rgba('#c49945'), width=SCALE)

    # Belt continuing seamlessly around back at y=183..197
    draw.rectangle(scale_rect(bx0, 183, 128, 14), fill=hex_to_rgba('#281a11'))
    draw_line_aa(draw, bx0, 183, bx1, 183, '#483020', 1.2)
    draw_line_aa(draw, bx0, 197, bx1, 197, '#120905', 1.2)
    # Back strap keeper
    draw.rectangle(scale_rect(bcx - 6, 182, 12, 16), fill=hex_to_rgba('#483020'), outline='#1e110a')

    # -------------------------------------------------------------
    # 5. ARMS (Left: 19..280; Right: 308..569, y=355..482)
    # -------------------------------------------------------------
    # No armor! Rolled linen sleeves, muscular forearms with heat wraps, smithing gloves
    def draw_smith_arm(island_x, is_left):
        # 1. Upper Arm (y=355..417): Rolled coarse linen work sleeve
        apply_tunic_weave_pattern(draw, island_x, 355, 262, 48, base_col='#231d19', seam_col='#312923')
        # UP shoulder face
        up_x = 217 if is_left else 308
        apply_tunic_weave_pattern(draw, up_x, 290, 64, 64, base_col='#1a1512', seam_col='#261f1a')

        # Rolled-up sleeve cuff at y=403..414
        draw.rectangle(scale_rect(island_x, 403, 262, 11), fill=hex_to_rgba('#382f28'))
        draw_line_aa(draw, island_x, 403, island_x + 262, 403, '#54463c', 1.2)
        draw_line_aa(draw, island_x, 414, island_x + 262, 414, '#181310', 1.2)

        # Exposed bare forearm skin just above elbow (y=415..417)
        draw.rectangle(scale_rect(island_x, 415, 262, 3), fill=hex_to_rgba('#7d563e'))

        # Elbow Joint line at y=418
        draw_line_aa(draw, island_x, 418, island_x + 262, 418, '#120c08', 1.2)

        # 2. Lower Arm / Forearm (y=419..466):
        # Heat-resistant split-leather forge forearm wraps & spats
        draw.rectangle(scale_rect(island_x, 419, 262, 48), fill=hex_to_rgba('#362216'))
        # Leather strapping across forearm with buckles
        for sy in [428, 442, 456]:
            draw.rectangle(scale_rect(island_x, sy, 262, 6), fill=hex_to_rgba('#24150c'))
            draw_line_aa(draw, island_x, sy, island_x + 262, sy, '#482d1c', 0.8)
            draw_line_aa(draw, island_x, sy + 6, island_x + 262, sy + 6, '#140a05', 0.8)
            # Small brass buckles on outer arm
            front_x = (island_x + 198) if is_left else island_x
            draw.rectangle(scale_rect(front_x + 8, sy - 1, 7, 8), fill=hex_to_rgba('#c49945'), outline='#3a2608')

        # Wrist Joint line at y=467
        draw_line_aa(draw, island_x, 467, island_x + 262, 467, '#140c07', 1.2)

        # 3. Hand / Gloves (y=468..482): Fingerless dark leather smithing gloves
        draw.rectangle(scale_rect(island_x, 468, 262, 15), fill=hex_to_rgba('#21150f'))
        draw_line_aa(draw, island_x, 468, island_x + 262, 468, '#4a3020', 1.2)
        # Suede grip reinforcement on palm/down face
        draw.rectangle(scale_rect(up_x, 485, 64, 64), fill=hex_to_rgba('#180f0a'))
        draw_line_aa(draw, up_x + 12, 510, up_x + 52, 510, '#362217', 2.0)

    draw_smith_arm(19, is_left=True)
    draw_smith_arm(308, is_left=False)

    res = canvas.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
    noise = generate_leather_noise(WIDTH, HEIGHT, seed=55)
    arr = np.array(res).astype(float)
    for c in range(3):
        arr[:, :, c] = np.clip(arr[:, :, c] + noise * 10.0, 0, 255)
    return Image.fromarray(arr.astype(np.uint8))

def generate_blacksmith_pants():
    canvas = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # -------------------------------------------------------------
    # 1. OPTIONAL PELVIS / LOWER TORSO (Matching Work Trousers & Belt)
    # -------------------------------------------------------------
    apply_tunic_weave_pattern(draw, 165, 171, 388, 31, base_col='#1e2127', seam_col='#2a2e36')
    apply_tunic_weave_pattern(draw, 231, 204, 128, 64, base_col='#17191d', seam_col='#21242a')

    # Matching Leather Belt across y=183..197
    draw.rectangle(scale_rect(165, 183, 388, 14), fill=hex_to_rgba('#281a11'))
    draw_line_aa(draw, 165, 183, 552, 183, '#483020', 1.2)
    draw_line_aa(draw, 165, 197, 552, 197, '#120905', 1.2)
    fcx = 295
    draw.rectangle(scale_rect(fcx - 13, 181, 26, 18), fill=hex_to_rgba('#1a1f26'), outline=hex_to_rgba('#7a8b9e'))
    draw.rectangle(scale_rect(fcx - 9, 184, 18, 12), fill=hex_to_rgba('#38424e'), outline=hex_to_rgba('#95a7bc'))
    draw_line_aa(draw, fcx, 181, fcx, 199, '#c8d8e8', 2.0)

    # -------------------------------------------------------------
    # 2. LEGS (Left: 19..280; Right: 308..569, y=355..482)
    # -------------------------------------------------------------
    def draw_smith_leg(island_x, is_left):
        # 1. Upper Leg / Thigh (y=355..417): Heavy charcoal work trousers
        apply_tunic_weave_pattern(draw, island_x, 355, 262, 63, base_col='#1e2127', seam_col='#2a2e36')
        up_x = 217 if is_left else 308
        apply_tunic_weave_pattern(draw, up_x, 290, 64, 64, base_col='#181a1f', seam_col='#22252c')

        # Thigh leather tool strap with forged iron hammer ring
        draw.rectangle(scale_rect(island_x, 394, 262, 9), fill=hex_to_rgba('#2b1a10'))
        draw_line_aa(draw, island_x, 394, island_x + 262, 394, '#482d1c', 1)
        draw_line_aa(draw, island_x, 403, island_x + 262, 403, '#140c07', 1)
        # Hammer ring on the front panel
        front_x = (island_x + 198) if is_left else island_x
        fcx = front_x + 32
        draw.ellipse(scale_rect(fcx - 6, 397, 12, 12), outline=hex_to_rgba('#7a8b9e'), width=SCALE)

        # 2. Heavy Leather Knee Protector Patch (Spanning across y=410..428 on FRONT face)
        knee_pts = [
            (front_x + 10, 412), (fcx, 409), (front_x + 54, 412),
            (front_x + 52, 429), (fcx, 432), (front_x + 12, 429)
        ]
        draw_polygon_aa(draw, knee_pts, fill=hex_to_rgba('#3c271a'), outline='#1e120b', width=1.8)
        inner_knee = [
            (front_x + 14, 415), (fcx, 412), (front_x + 50, 415),
            (front_x + 48, 426), (fcx, 429), (front_x + 16, 426)
        ]
        draw_polygon_aa(draw, inner_knee, fill=hex_to_rgba('#4e3424'))
        draw_rivet(draw, front_x + 14, 415, 2)
        draw_rivet(draw, front_x + 50, 415, 2)
        draw_rivet(draw, front_x + 16, 426, 2)
        draw_rivet(draw, front_x + 48, 426, 2)

        # Knee Joint seam at y=418
        draw_line_aa(draw, island_x, 418, island_x + 262, 418, '#120d09', 1.2)

        # 3. Lower Leg / Shin & Calf (y=419..466):
        # Heavy heat-resistant split-leather forge gaiters / spats
        draw.rectangle(scale_rect(island_x, 419, 262, 48), fill=hex_to_rgba('#2b1b11'))
        # 3 horizontal straps with iron buckles
        for sy in [432, 445, 458]:
            draw.rectangle(scale_rect(island_x, sy, 262, 7), fill=hex_to_rgba('#1e120a'))
            draw_line_aa(draw, island_x, sy, island_x + 262, sy, '#3c2415', 0.8)
            draw_line_aa(draw, island_x, sy + 7, island_x + 262, sy + 7, '#0e0804', 0.8)
            # Buckle on front panel
            draw.rectangle(scale_rect(front_x + 10, sy - 1, 8, 9), fill=hex_to_rgba('#637080'), outline='#21262d')

        # Ankle Joint seam at y=467
        draw_line_aa(draw, island_x, 467, island_x + 262, 467, '#120d09', 1.2)

        # 4. Boots / Foot (y=468..482 and DOWN y=485..548):
        # Square-toed heavy oiled leather blacksmith boots with steel safety caps
        draw.rectangle(scale_rect(island_x, 468, 262, 15), fill=hex_to_rgba('#1b1410'))
        draw_line_aa(draw, island_x, 468, island_x + 262, 468, '#3d2b20', 1.2)
        # Steel protective toe cap on Front face
        draw.rectangle(scale_rect(front_x + 10, 471, 44, 9), fill=hex_to_rgba('#485464'), outline='#7a8a9c')
        draw_line_aa(draw, front_x + 14, 475, front_x + 50, 475, '#9fb0c2', 1.2)
        draw_rivet(draw, fcx, 475, 2)
        # Heavy lugged sole on DOWN face
        draw.rectangle(scale_rect(up_x, 485, 64, 64), fill=hex_to_rgba('#100b08'))
        for ty in range(492, 545, 10):
            draw_line_aa(draw, up_x + 8, ty, up_x + 56, ty, '#221812', 2.0)

    draw_smith_leg(19, is_left=True)
    draw_smith_leg(308, is_left=False)

    res = canvas.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
    noise = generate_leather_noise(WIDTH, HEIGHT, seed=88)
    arr = np.array(res).astype(float)
    for c in range(3):
        arr[:, :, c] = np.clip(arr[:, :, c] + noise * 10.0, 0, 255)
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
    print("Generating Blacksmith of Valgard Shirt v3 (High Detail EST-33 quality)...")
    shirt = generate_blacksmith_shirt()
    shirt = apply_template_mask(shirt, 'Assets/Source/References/Roblox-Classic-Clothing-Templates/Template-Shirts-R15v2.png', is_pants=False)
    shirt_out = 'Assets/Clothing/EST-52/BodySkins/Blacksmith/blacksmith_assistant_classic_shirt_r15_v3.png'
    shirt.save(shirt_out, 'PNG')
    # Also save to Guard folder if HTTP server is serving Guard folder
    shirt.save('Assets/Clothing/EST-52/BodySkins/Guard/blacksmith_assistant_classic_shirt_r15_v3.png', 'PNG')
    print(f"Saved: {shirt_out} ({shirt.size}, mode={shirt.mode})")

    print("Generating Blacksmith of Valgard Pants v3 (High Detail EST-33 quality)...")
    pants = generate_blacksmith_pants()
    pants = apply_template_mask(pants, 'Assets/Source/References/Roblox-Classic-Clothing-Templates/Template-Pants-R15v2.png', is_pants=True)
    pants_out = 'Assets/Clothing/EST-52/BodySkins/Blacksmith/blacksmith_assistant_classic_pants_r15_v3.png'
    pants.save(pants_out, 'PNG')
    pants.save('Assets/Clothing/EST-52/BodySkins/Guard/blacksmith_assistant_classic_pants_r15_v3.png', 'PNG')
    print(f"Saved: {pants_out} ({pants.size}, mode={pants.mode})")

if __name__ == '__main__':
    main()
