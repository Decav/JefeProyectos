"""
Generate-TavernkeeperValgardBodySkins.py
Generates the high-fidelity Nordic Tavernkeeper classic body skins (Shirt and Pants)
for Roblox R15 avatars, strictly adhering to:
1. Template-Shirts-R15v2.png and Template-Pants-R15v2.png (585x559, RGBA).
2. The high visual fidelity standard of EST-33 (rich organic textures, linen weave,
   leather vest grain, bone/horn buttons, brass buckles, cellar keys, service towel).
3. STRICTLY CIVILIAN INNKEEPER ATTIRE: ZERO combat armor, ZERO plate mail, ZERO frost crystals.
4. Exact R15 cut lines:
   - Torso: UpperTorso (y=74..169), Joint seam (y=170), LowerTorso (y=171..201), DOWN (y=204..267).
   - Limbs: Upper (y=355..417), Joint seam (y=418), Lower (y=419..466), Joint seam (y=467), Hand/Foot (y=468..482).
"""

import math
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

WIDTH = 585
HEIGHT = 559
SCALE = 2  # 2x supersampling

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

def draw_rivet(draw, cx, cy, radius=2, col='#c49945', rim='#1a1208'):
    scx, scy = scale_pt((cx, cy))
    sr = radius * SCALE
    draw.ellipse([scx - sr, scy - sr + 1, scx + sr, scy + sr + 1], fill=hex_to_rgba(rim))
    draw.ellipse([scx - sr, scy - sr, scx + sr, scy + sr], fill=hex_to_rgba(col))
    glint_r = max(1, sr // 2)
    draw.ellipse([scx - glint_r, scy - glint_r, scx, scy], fill=hex_to_rgba('#fff6d8'))

def draw_horn_button(draw, cx, cy, radius=3):
    scx, scy = scale_pt((cx, cy))
    sr = radius * SCALE
    draw.ellipse([scx - sr, scy - sr + 1, scx + sr, scy + sr + 1], fill=hex_to_rgba('#100c08'))
    draw.ellipse([scx - sr, scy - sr, scx + sr, scy + sr], fill=hex_to_rgba('#d9cbba'))
    # Button thread holes
    th_r = max(1, SCALE)
    draw.ellipse([scx - th_r - 1, scy - th_r, scx - 1, scy + th_r], fill=hex_to_rgba('#3d281a'))
    draw.ellipse([scx + 1, scy - th_r, scx + th_r + 1, scy + th_r], fill=hex_to_rgba('#3d281a'))

def apply_fabric_pattern(draw, x, y, w, h, base_col='#c2b49d', seam_col='#b3a48c', step_px=4):
    sx0, sy0, sx1, sy1 = scale_rect(x, y, w, h)
    draw.rectangle([sx0, sy0, sx1, sy1], fill=hex_to_rgba(base_col))
    step = step_px * SCALE
    for d in range(sx0, sx1, step):
        draw.line([(d, sy0), (d, sy1)], fill=hex_to_rgba(seam_col), width=1)
    for d in range(sy0, sy1, step):
        draw.line([(sx0, d), (sx1, d)], fill=hex_to_rgba(seam_col), width=1)

def apply_leather_pattern(draw, x, y, w, h, base_col='#3a2518', seam_col='#4a3222', step_px=6):
    sx0, sy0, sx1, sy1 = scale_rect(x, y, w, h)
    draw.rectangle([sx0, sy0, sx1, sy1], fill=hex_to_rgba(base_col))
    step = step_px * SCALE
    for d in range(sx0, sx1, step):
        draw.line([(d, sy0), (d, sy1)], fill=hex_to_rgba(seam_col), width=1)

def generate_tavernkeeper_shirt():
    canvas = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # -------------------------------------------------------------
    # 1. TORSO UNDERLAYER (Warm Coarse Linen/Wool Tunic)
    # -------------------------------------------------------------
    # Middle row faces: R(165..229), F(231..358), L(359..423), B(425..552)
    # UpperTorso: y=74..169. LowerTorso: y=171..201.
    apply_fabric_pattern(draw, 165, 74, 388, 128, base_col='#baa891', seam_col='#aa9881', step_px=4)
    # Torso UP (neck/shoulders)
    apply_fabric_pattern(draw, 231, 8, 128, 64, base_col='#a89780', seam_col='#988770', step_px=4)
    # Torso DOWN (tunic hem bottom)
    apply_fabric_pattern(draw, 231, 204, 128, 64, base_col='#8e7e6a', seam_col='#7d6e5a', step_px=4)

    # -------------------------------------------------------------
    # 2. TORSO FRONT: Dark Leather Vest over Tunic
    # -------------------------------------------------------------
    fx0, fx1 = 231, 358
    fcx = 295

    # Open collar of linen tunic visible at chest
    draw_polygon_aa(draw, [(270, 74), (fcx, 105), (320, 74)], fill=hex_to_rgba('#e0d5c3'))
    # Inner neck shadows & laces
    draw_polygon_aa(draw, [(280, 74), (fcx, 92), (310, 74)], fill=hex_to_rgba('#2a1e16'))
    draw_line_aa(draw, 278, 80, 312, 84, '#5e3e2b', 1.5)
    draw_line_aa(draw, 282, 88, 308, 92, '#5e3e2b', 1.5)

    # Left & Right Vest Panels (Chest vest covering y=74..190)
    # Right panel (viewer left): x=231..288
    vest_left = [
        (231, 74), (270, 74),
        (fcx - 7, 105), (fcx - 7, 185),
        (231, 185)
    ]
    draw_polygon_aa(draw, vest_left, fill=hex_to_rgba('#3c2619'), outline=hex_to_rgba('#22140a'), width=2.0)
    draw_polygon_aa(draw, [(234, 77), (266, 77), (fcx - 10, 107), (fcx - 10, 182), (234, 182)], fill=hex_to_rgba('#482f20'))

    # Left panel (viewer right): x=302..358
    vest_right = [
        (320, 74), (358, 74),
        (358, 185), (fcx + 7, 185),
        (fcx + 7, 105)
    ]
    draw_polygon_aa(draw, vest_right, fill=hex_to_rgba('#3c2619'), outline=hex_to_rgba('#22140a'), width=2.0)
    draw_polygon_aa(draw, [(324, 77), (355, 77), (355, 182), (fcx + 10, 182), (fcx + 10, 107)], fill=hex_to_rgba('#482f20'))

    # Carved Horn/Bone Buttons down the vest edge
    for by in [115, 133, 151, 169]:
        draw_horn_button(draw, fcx - 10, by, 3)
        # Button loops on opposite side
        draw_line_aa(draw, fcx - 6, by, fcx + 6, by, '#26180f', 1.5)

    # Vest lower hem detail
    draw_line_aa(draw, 231, 185, fcx - 7, 185, '#22140a', 2.0)
    draw_line_aa(draw, fcx + 7, 185, 358, 185, '#22140a', 2.0)

    # -------------------------------------------------------------
    # 3. SERVICE TOWEL / RAG TUCKED IN BELT
    # -------------------------------------------------------------
    # Folded tavern towel hanging on left side (x=332..356, y=175..201)
    towel_pts = [
        (332, 175), (356, 175),
        (354, 201), (334, 201)
    ]
    draw_polygon_aa(draw, towel_pts, fill=hex_to_rgba('#dfd7cb'), outline=hex_to_rgba('#9e9382'), width=1.5)
    # Towel vertical fold lines
    draw_line_aa(draw, 340, 175, 339, 201, '#b5aa99', 1.2)
    draw_line_aa(draw, 348, 175, 347, 201, '#b5aa99', 1.2)

    # -------------------------------------------------------------
    # 4. LOWER TORSO FRONT: Tunic Hem & Belt
    # -------------------------------------------------------------
    # Exposed linen tunic hem spanning y=185..201
    draw.rectangle(scale_rect(231, 185, 101, 16), fill=hex_to_rgba('#baa891'))
    # Leather Belt spanning y=183..197
    draw.rectangle(scale_rect(fx0, 183, 128, 13), fill=hex_to_rgba('#2b1a10'))
    draw_line_aa(draw, fx0, 183, fx1, 183, '#4a3020', 1.2)
    draw_line_aa(draw, fx0, 196, fx1, 196, '#150c07', 1.2)
    # Belt loop & Brass Buckle (fcx=295)
    draw.rectangle(scale_rect(fcx - 11, 181, 22, 17), fill=hex_to_rgba('#b88e36'), outline=hex_to_rgba('#483610'))
    draw.rectangle(scale_rect(fcx - 7, 184, 14, 11), fill=hex_to_rgba('#2b1a10'))
    draw_line_aa(draw, fcx, 181, fcx, 197, '#fad668', 2.0)

    # Seam joint line at y=170
    draw_line_aa(draw, fx0, 170, fx1, 170, '#1a100a', 1.0)

    # -------------------------------------------------------------
    # 5. TORSO SIDES (R: 165..229 & L: 359..423)
    # -------------------------------------------------------------
    for side_x, side_w in [(165, 65), (359, 65)]:
        # Leather vest continues on sides
        draw.rectangle(scale_rect(side_x, 74, side_w, 111), fill=hex_to_rgba('#3c2619'))
        draw.rectangle(scale_rect(side_x + 3, 77, side_w - 6, 105), fill=hex_to_rgba('#482f20'))
        # Exposed linen tunic at bottom
        draw.rectangle(scale_rect(side_x, 185, side_w, 16), fill=hex_to_rgba('#baa891'))
        # Belt on sides
        draw.rectangle(scale_rect(side_x, 183, side_w, 13), fill=hex_to_rgba('#2b1a10'))
        draw_line_aa(draw, side_x, 183, side_x + side_w, 183, '#4a3020', 1.0)
        draw_line_aa(draw, side_x, 196, side_x + side_w, 196, '#150c07', 1.0)

        # On left side (359): continue towel
        if side_x == 359:
            draw.rectangle(scale_rect(359, 175, 14, 26), fill=hex_to_rgba('#dfd7cb'), outline=hex_to_rgba('#9e9382'))
            draw_line_aa(draw, 365, 175, 365, 201, '#b5aa99', 1.2)

    # -------------------------------------------------------------
    # 6. TORSO BACK (425..552): Vest back with brass cinch
    # -------------------------------------------------------------
    bx0, bx1 = 425, 552
    bcx = 488
    # Vest covers y=74..185
    draw.rectangle(scale_rect(bx0, 74, 128, 111), fill=hex_to_rgba('#3c2619'))
    draw.rectangle(scale_rect(bx0 + 4, 77, 120, 105), fill=hex_to_rgba('#482f20'))
    # Linen showing at neck
    draw_polygon_aa(draw, [(470, 74), (bcx, 84), (506, 74)], fill=hex_to_rgba('#baa891'))
    # Back cinch straps and small buckle
    draw.rectangle(scale_rect(bcx - 30, 150, 60, 8), fill=hex_to_rgba('#28180e'))
    draw.rectangle(scale_rect(bcx - 6, 148, 12, 12), fill=hex_to_rgba('#b88e36'), outline=hex_to_rgba('#483610'))
    # Belt and exposed tunic at bottom
    draw.rectangle(scale_rect(bx0, 185, 128, 16), fill=hex_to_rgba('#baa891'))
    draw.rectangle(scale_rect(bx0, 183, 128, 13), fill=hex_to_rgba('#2b1a10'))
    draw_line_aa(draw, bx0, 183, bx1, 183, '#4a3020', 1.0)
    draw_line_aa(draw, bx0, 196, bx1, 196, '#150c07', 1.0)

    # -------------------------------------------------------------
    # 7. ARMS (ROLLED SLEEVES & CIVILIAN WRISTS)
    # -------------------------------------------------------------
    # Right Arm: x=0..128. Left Arm: x=457..585.
    # Upper row (y=355..417): Linen sleeve
    # Lower row (y=419..466): Rolled cuff at top, exposed bare forearm/linen wrap below
    # Hand row (y=468..482): Bare hands or light cloth wraps (NO GAUNTLETS)

    for arm_x0, arm_w in [(0, 128), (457, 128)]:
        # Upper Arm: Cream linen tunic sleeve
        apply_fabric_pattern(draw, arm_x0, 355, arm_w, 63, base_col='#baa891', seam_col='#aa9881', step_px=4)
        # Arm UP face (shoulder cap)
        apply_fabric_pattern(draw, arm_x0 + 32, 289, 64, 64, base_col='#a89780', seam_col='#988770', step_px=4)

        # Lower Arm (y=419..466):
        # 1. Rolled cuff fold (y=419..434)
        draw.rectangle(scale_rect(arm_x0, 419, arm_w, 15), fill=hex_to_rgba('#dfd7cb'), outline=hex_to_rgba('#a69c8c'))
        for fx in range(arm_x0, arm_x0 + arm_w, 8):
            draw_line_aa(draw, fx, 419, fx, 434, '#c2b7a5', 1.0)

        # 2. Exposed forearm / skin or coarse under-wrap (y=435..466)
        # Using a rugged tanned skin tone with light arm hair / shadow
        draw.rectangle(scale_rect(arm_x0, 435, arm_w, 32), fill=hex_to_rgba('#cfa584'))
        draw_line_aa(draw, arm_x0, 435, arm_x0 + arm_w, 435, '#8c684d', 1.5)

        # 3. Simple leather wrist cord / band at y=460..465
        draw.rectangle(scale_rect(arm_x0, 460, arm_w, 6), fill=hex_to_rgba('#3c2619'))
        draw_line_aa(draw, arm_x0, 460, arm_x0 + arm_w, 460, '#5a3b26', 1.0)

        # Hand row (y=468..482): Clean tanned hands (civilian, no armor)
        draw.rectangle(scale_rect(arm_x0, 468, arm_w, 15), fill=hex_to_rgba('#cfa584'))
        # Arm DOWN face (palm/hand bottom)
        draw.rectangle(scale_rect(arm_x0 + 32, 485, 64, 64), fill=hex_to_rgba('#b89172'))

    # Downsample supersampled canvas to 585x559
    shirt_final = canvas.resize((WIDTH, HEIGHT), Image.LANCZOS)
    return shirt_final

def generate_tavernkeeper_pants():
    canvas = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # -------------------------------------------------------------
    # 1. PELVIS / LOWER TORSO (y=171..201): Trousers waist, belt, cellar keys
    # -------------------------------------------------------------
    # Pants template requires Torso block for pelvis/hip connection:
    # Middle row: R(165..229), F(231..358), L(359..423), B(425..552)
    # Dark peat-wool trousers fabric
    apply_fabric_pattern(draw, 165, 171, 388, 31, base_col='#352f2a', seam_col='#2b2520', step_px=5)
    # Torso DOWN (crotch area)
    apply_fabric_pattern(draw, 231, 204, 128, 64, base_col='#2b2520', seam_col='#201c18', step_px=5)

    # Leather utility belt along top of pants (y=183..197)
    draw.rectangle(scale_rect(165, 183, 388, 14), fill=hex_to_rgba('#2b1a10'))
    draw_line_aa(draw, 165, 183, 553, 183, '#4a3020', 1.2)
    draw_line_aa(draw, 165, 197, 553, 197, '#150c07', 1.2)

    fcx = 295
    # Brass buckle front
    draw.rectangle(scale_rect(fcx - 11, 181, 22, 17), fill=hex_to_rgba('#b88e36'), outline=hex_to_rgba('#483610'))
    draw.rectangle(scale_rect(fcx - 7, 184, 14, 11), fill=hex_to_rgba('#2b1a10'))
    draw_line_aa(draw, fcx, 181, fcx, 197, '#fad668', 2.0)

    # Cellar Brass Key Ring hanging on right hip (x=252, y=197..215)
    draw.ellipse(scale_rect(248, 196, 10, 10), outline=hex_to_rgba('#b88e36'), width=int(1.5 * SCALE))
    # Brass keys
    draw_line_aa(draw, 250, 204, 248, 216, '#fad668', 2.0)
    draw_line_aa(draw, 254, 204, 256, 218, '#d4af37', 2.0)
    # Key bit teeth
    draw_line_aa(draw, 248, 214, 245, 214, '#fad668', 1.5)
    draw_line_aa(draw, 256, 215, 259, 215, '#d4af37', 1.5)

    # Tankard hook / strap on left hip (x=335, y=197..212)
    draw.rectangle(scale_rect(333, 197, 7, 14), fill=hex_to_rgba('#4a3020'), outline=hex_to_rgba('#1a100a'))
    draw.ellipse(scale_rect(334, 208, 6, 6), outline=hex_to_rgba('#b88e36'), width=int(1.2 * SCALE))

    # Trousers fly seam down center front (y=197..201)
    draw_line_aa(draw, fcx, 197, fcx, 201, '#1c1612', 2.0)

    # -------------------------------------------------------------
    # 2. LEGS: Peat-Wool Trousers with Stitched Knee Patches & Work Boots
    # -------------------------------------------------------------
    # Right Leg: x=0..128. Left Leg: x=457..585.
    # Upper Leg (y=355..417): Wool trousers
    # Lower Leg (y=419..466): Trousers tucked into dark leather work boots
    # Foot (y=468..482): Sturdy leather boots
    # Foot DOWN (y=485..549): Thick boot treads / soles

    for leg_x0, leg_w in [(0, 128), (457, 128)]:
        # Upper leg: Peat wool trousers
        apply_fabric_pattern(draw, leg_x0, 355, leg_w, 63, base_col='#352f2a', seam_col='#2b2520', step_px=5)
        # Leg UP face
        apply_fabric_pattern(draw, leg_x0 + 32, 289, 64, 64, base_col='#2b2520', seam_col='#201c18', step_px=5)

        # Stitched Leather Knee Patches across the front and sides (centered around y=405..430)
        # In template: Front face of limb is at specific offset.
        # Right limb (x=0..128): R=0..31, B=32..63, L=64..95, F=96..127
        # Left limb (x=457..585): F=457..488, L=489..520, B=521..552, R=553..584
        for face_off in [0, 32, 64, 96]:
            fx = leg_x0 + face_off
            # Stitched oval/rect knee patch on front-facing sections
            draw.rectangle(scale_rect(fx + 4, 400, 24, 22), fill=hex_to_rgba('#281c14'), outline=hex_to_rgba('#150e0a'))
            # Visible rough stitches around patch
            for sx in range(fx + 6, fx + 26, 4):
                draw_line_aa(draw, sx, 399, sx + 2, 401, '#8c684d', 1.0)
                draw_line_aa(draw, sx, 421, sx + 2, 423, '#8c684d', 1.0)

        # Lower leg: Trousers tucking into heavy oiled work boots (y=428..466)
        draw.rectangle(scale_rect(leg_x0, 428, leg_w, 39), fill=hex_to_rgba('#22160e'))
        # Fur / shearling collar at boot rim (y=428..434)
        draw.rectangle(scale_rect(leg_x0, 428, leg_w, 6), fill=hex_to_rgba('#baa891'), outline=hex_to_rgba('#8c7b67'))

        # Crossed leather laces down the front of the boots
        for lace_y in [438, 446, 454, 462]:
            for face_off in [0, 32, 64, 96]:
                fx = leg_x0 + face_off
                draw_line_aa(draw, fx + 6, lace_y, fx + 26, lace_y + 4, '#5e3e2b', 1.5)
                draw_line_aa(draw, fx + 26, lace_y, fx + 6, lace_y + 4, '#5e3e2b', 1.5)

        # Foot (y=468..482): Oiled work boot foot
        draw.rectangle(scale_rect(leg_x0, 468, leg_w, 15), fill=hex_to_rgba('#1a100a'))
        # Boot toe cap reinforcement
        for face_off in [0, 32, 64, 96]:
            fx = leg_x0 + face_off
            draw_line_aa(draw, fx + 2, 478, fx + 30, 478, '#3d2516', 2.0)

        # Foot DOWN face: Heavy treaded boot sole
        draw.rectangle(scale_rect(leg_x0 + 32, 485, 64, 64), fill=hex_to_rgba('#120a06'))
        # Tread marks
        for ty in range(490, 545, 8):
            draw_line_aa(draw, leg_x0 + 36, ty, leg_x0 + 92, ty, '#2a1a10', 2.0)

    # Downsample supersampled canvas to 585x559
    pants_final = canvas.resize((WIDTH, HEIGHT), Image.LANCZOS)
    return pants_final

def generate_tavernkeeper_icons(shirt_img, pants_img):
    # Generates 512x512 master item icons
    icon_chest = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
    d_c = ImageDraw.Draw(icon_chest)
    # Background radial glow
    for r in range(240, 0, -8):
        alpha = int(120 * (1 - r / 240))
        d_c.ellipse([256 - r, 256 - r, 256 + r, 256 + r], fill=(45, 32, 22, alpha))

    # Crop Torso Front from shirt (x=231, y=74, w=128, h=128)
    front_crop = shirt_img.crop((231, 74, 231 + 128, 74 + 128))
    front_crop = front_crop.resize((360, 360), Image.LANCZOS)
    icon_chest.paste(front_crop, (76, 76), front_crop)

    icon_legs = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
    d_l = ImageDraw.Draw(icon_legs)
    for r in range(240, 0, -8):
        alpha = int(120 * (1 - r / 240))
        d_l.ellipse([256 - r, 256 - r, 256 + r, 256 + r], fill=(35, 28, 22, alpha))

    # Crop Pelvis + Leg
    pelvis_crop = pants_img.crop((231, 171, 359, 202))
    pelvis_crop = pelvis_crop.resize((320, 78), Image.LANCZOS)
    leg_crop = pants_img.crop((96, 355, 128, 482))
    leg_crop = leg_crop.resize((120, 280), Image.LANCZOS)

    icon_legs.paste(pelvis_crop, (96, 80), pelvis_crop)
    icon_legs.paste(leg_crop, (120, 150), leg_crop)
    icon_legs.paste(leg_crop.transpose(Image.FLIP_LEFT_RIGHT), (272, 150), leg_crop.transpose(Image.FLIP_LEFT_RIGHT))

    return icon_chest, icon_legs

def main():
    print("Generating Nordic Tavernkeeper body skins...")
    shirt = generate_tavernkeeper_shirt()
    pants = generate_tavernkeeper_pants()

    # Paths
    base_dir = r"C:\Users\Diego\Desktop\Proyectos\JefeProyectos\Vandrheim-Roblox"
    t_body_dir = os.path.join(base_dir, r"Assets\Clothing\EST-52\BodySkins\Tavern")
    t_item_dir = os.path.join(base_dir, r"Assets\Source\Itemization\HU-ESTETICA-52\Tavernkeeper")
    t_icon_dir = os.path.join(base_dir, r"Assets\Icons\Items\Armor\Tavernkeeper")

    os.makedirs(t_body_dir, exist_ok=True)
    os.makedirs(t_item_dir, exist_ok=True)
    os.makedirs(t_icon_dir, exist_ok=True)

    shirt_path = os.path.join(t_body_dir, "tavernkeeper_valgard_classic_shirt_r15_v1.png")
    pants_path = os.path.join(t_body_dir, "tavernkeeper_valgard_classic_pants_r15_v1.png")

    shirt.save(shirt_path, "PNG")
    pants.save(pants_path, "PNG")
    print(f"Saved: {shirt_path}")
    print(f"Saved: {pants_path}")

    # Also save to Itemization directory
    shirt.save(os.path.join(t_item_dir, "tavernkeeper_valgard_classic_shirt_r15_v1.png"), "PNG")
    pants.save(os.path.join(t_item_dir, "tavernkeeper_valgard_classic_pants_r15_v1.png"), "PNG")

    # Icons
    icon_chest, icon_legs = generate_tavernkeeper_icons(shirt, pants)
    icon_c_path = os.path.join(t_icon_dir, "Icon_Item_tavernkeeper_valgard_chest.png")
    icon_l_path = os.path.join(t_icon_dir, "Icon_Item_tavernkeeper_valgard_legs.png")
    icon_chest.save(icon_c_path, "PNG")
    icon_legs.save(icon_l_path, "PNG")
    print(f"Saved: {icon_c_path}")
    print(f"Saved: {icon_l_path}")

    print("Generation complete!")

if __name__ == "__main__":
    main()
