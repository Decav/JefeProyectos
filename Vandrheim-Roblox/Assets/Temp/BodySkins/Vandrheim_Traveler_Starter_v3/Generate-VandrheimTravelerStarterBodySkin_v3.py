from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import math
import numpy as np


ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent
MASK_DIR = ROOT / "Assets" / "Clothing" / "EST-07"
SIZE = (585, 559)
S = 3

# Warm, restrained colors taken from the reference outfit and adapted to the
# project's readable, painterly Roblox clothing style.
LINEN = (211, 190, 160)
LINEN_LIGHT = (240, 225, 201)
LINEN_SHADE = (151, 127, 98)
LEATHER = (94, 45, 25)
LEATHER_LIGHT = (141, 76, 39)
LEATHER_DARK = (49, 27, 19)
STITCH = (205, 155, 95)
PANTS = (184, 154, 122)
PANTS_LIGHT = (218, 193, 161)
PANTS_SHADE = (112, 89, 67)
BOOT = (78, 49, 39)
BOOT_LIGHT = (117, 75, 54)
BOOT_SHADE = (31, 25, 24)
BRASS = (167, 113, 47)
BRASS_LIGHT = (218, 168, 87)


def rgb(hex_color: str) -> tuple[int, int, int]:
    h = hex_color.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def add_material_texture(image: Image.Image) -> Image.Image:
    """Add restrained linen weave and leather grain at final UV resolution."""
    rgba = np.asarray(image.convert("RGBA"), dtype=np.int16).copy()
    h, w = rgba.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    rng = np.random.default_rng(20261024)
    fine = rng.normal(0.0, 1.0, (h, w))
    coarse_small = rng.normal(0.0, 1.0, (max(12, h // 8), max(12, w // 8)))
    coarse = np.asarray(Image.fromarray(np.uint8(np.clip(coarse_small * 32 + 128, 0, 255)), "L").resize((w, h), Image.Resampling.BICUBIC), dtype=np.float32)
    coarse = (coarse - 128.0) / 32.0

    r, g, b = rgba[:, :, 0], rgba[:, :, 1], rgba[:, :, 2]
    fabric = (r > 135) & (g > 95) & (b > 55) & (r > g) & (g > b)
    leather = (r > 28) & (r > g * 1.18) & (g > b * 1.10) & (r < 185)

    # Linen's shallow cross-weave reads as cloth without becoming visual noise.
    weave = ((xx % 5 == 0) * 1.0) - ((yy % 7 == 0) * 0.7)
    cloth_delta = fine * 1.4 + coarse * 1.8 + weave
    leather_delta = fine * 2.6 + coarse * 3.2
    # Tiny irregular pores and worn spots, sparse enough to remain clean in-game.
    pores = (rng.random((h, w)) > 0.996) * rng.choice([-7.0, 6.0], size=(h, w))
    leather_delta += pores
    delta = np.zeros((h, w), dtype=np.float32)
    delta[fabric] = cloth_delta[fabric]
    delta[leather] = leather_delta[leather]
    for channel, factor in enumerate((1.0, 0.95, 0.88)):
        rgba[:, :, channel] = np.clip(rgba[:, :, channel] + delta * factor, 0, 255)
    return Image.fromarray(rgba.astype(np.uint8), "RGBA").copy()


class Painter:
    def __init__(self, matte=(*LINEN_LIGHT, 255)) -> None:
        # Render against an opaque matte before applying the project mask. This
        # avoids dark RGB fringes around antialiased UV island edges.
        self.im = Image.new("RGBA", (SIZE[0] * S, SIZE[1] * S), matte)
        self.d = ImageDraw.Draw(self.im)

    def box(self, xy, fill, outline=None, width=1):
        x0, y0, x1, y1 = xy
        xy = (round(x0*S), round(y0*S), round(x1*S), round(y1*S))
        self.d.rectangle(xy, fill=fill, outline=outline, width=max(1, round(width*S)) if outline else 1)

    def line(self, pts, fill, width=1):
        self.d.line([(round(x*S), round(y*S)) for x, y in pts], fill=fill, width=max(1, round(width*S)), joint="curve")

    def poly(self, pts, fill, outline=None, width=1):
        p = [(round(x*S), round(y*S)) for x, y in pts]
        self.d.polygon(p, fill=fill)
        if outline:
            self.d.line(p + [p[0]], fill=outline, width=max(1, round(width*S)), joint="curve")

    def ellipse(self, box, fill, outline=None, width=1):
        xy = tuple(round(v*S) for v in box)
        self.d.ellipse(xy, fill=fill, outline=outline, width=max(1, round(width*S)) if outline else 1)

    def gradient(self, box, top, bottom, horizontal=False):
        x0, y0, x1, y1 = box
        # Include one final source pixel at each far edge. The approved clothing
        # masks include antialiased boundary pixels there; the mask clips the
        # extra paint safely while preventing a pale matte sliver.
        w, h = max(1, round((x1-x0)*S) + S), max(1, round((y1-y0)*S) + S)
        a, b = top, bottom
        grad = Image.new("RGBA", (w, h))
        px = grad.load()
        n = w if horizontal else h
        for i in range(n):
            t = i / max(1, n-1)
            c = tuple(round(a[k] * (1-t) + b[k] * t) for k in range(3)) + (255,)
            if horizontal:
                for yy in range(h):
                    px[i, yy] = c
            else:
                for xx in range(w):
                    px[xx, i] = c
        self.im.alpha_composite(grad, (round(x0*S), round(y0*S)))
        self.d = ImageDraw.Draw(self.im)

    def save_masked(self, mask_path: Path, out_path: Path):
        mask = Image.open(mask_path).convert("RGBA")
        if mask.size != SIZE:
            raise ValueError(f"Expected {SIZE} mask, got {mask.size}: {mask_path}")
        art = self.im.resize(SIZE, Image.Resampling.LANCZOS)
        art = add_material_texture(art)
        # Give antialiased edge pixels the color of their nearest fully opaque
        # island pixel so transparent RGB cannot create a pale/dark halo.
        alpha = mask.getchannel("A")
        ap, rp = alpha.load(), art.load()
        partial = [(x, y) for y in range(SIZE[1]) for x in range(SIZE[0]) if 0 < ap[x, y] < 255]
        for x, y in partial:
            best = None
            for radius in range(1, 5):
                candidates = []
                for yy in range(max(0, y-radius), min(SIZE[1], y+radius+1)):
                    for xx in range(max(0, x-radius), min(SIZE[0], x+radius+1)):
                        if ap[xx, yy] == 255:
                            dist = (xx-x)*(xx-x) + (yy-y)*(yy-y)
                            if dist <= radius*radius:
                                candidates.append((dist, xx, yy))
                if candidates:
                    best = min(candidates)
                    break
            if best:
                _, xx, yy = best
                rp[x, y] = (*rp[xx, yy][:3], 255)
        # Copy alpha byte-for-byte from the project-approved clothing mask.
        art.putalpha(alpha)
        art.save(out_path)
        return art, mask


def seam(p: Painter, x1, y1, x2, y2, width=1.0):
    p.line([(x1, y1), (x2, y2)], LEATHER_DARK, width + 1.0)
    p.line([(x1, y1), (x2, y2)], STITCH, width)


def draw_torso(p: Painter):
    # Standard R15 shirt torso: side, front, side, back, with top and bottom caps.
    p.gradient((164, 7, 556, 264), LINEN_LIGHT, LINEN_SHADE)
    # Side UV faces: linen underlayer with narrow leather vest edges.
    for x in (165, 360):
        p.gradient((x, 73, x+65, 202), LINEN_LIGHT, LINEN_SHADE, horizontal=True)
        p.poly([(x+10, 76), (x+52, 76), (x+52, 177), (x+39, 188), (x+12, 180)], LEATHER, LEATHER_DARK, 1.2)
        p.line([(x+16, 86), (x+16, 174)], LEATHER_LIGHT, 1.5)
        p.line([(x+47, 87), (x+47, 173)], LEATHER_DARK, 1.0)
        # Belt wraps continuously around each side face.
        p.box((x, 180, x+64, 195), LEATHER_DARK)
        p.line([(x+2, 182), (x+62, 182)], LEATHER_LIGHT, 1.2)
        p.line([(x+2, 193), (x+62, 193)], STITCH, 0.8)

    # Front tunic and vest. Leave a narrow cream placket between two tailored panels.
    p.gradient((231, 73, 360, 203), LINEN_LIGHT, LINEN_SHADE)
    p.poly([(237, 83), (267, 77), (291, 88), (289, 179), (267, 186), (240, 174)], LEATHER, LEATHER_DARK, 1.4)
    p.poly([(359, 83), (329, 77), (300, 88), (302, 179), (324, 186), (351, 174)], LEATHER, LEATHER_DARK, 1.4)
    # Vest shaping highlights and edges.
    p.line([(242, 94), (269, 88), (285, 95)], LEATHER_LIGHT, 2.0)
    p.line([(355, 94), (328, 88), (305, 95)], LEATHER_LIGHT, 2.0)
    p.line([(242, 101), (250, 166)], LEATHER_LIGHT, 1.4)
    p.line([(354, 101), (346, 166)], LEATHER_LIGHT, 1.4)
    p.line([(246, 170), (266, 181), (286, 176)], LEATHER_DARK, 1.2)
    p.line([(350, 170), (330, 181), (304, 176)], LEATHER_DARK, 1.2)
    # Double-stitched panel seams and soft leather reflections echo the chest icon.
    p.line([(239, 92), (244, 112), (248, 151), (254, 169)], STITCH, 0.75)
    p.line([(353, 92), (348, 112), (344, 151), (338, 169)], STITCH, 0.75)
    p.line([(250, 106), (257, 143), (270, 164)], (174, 98, 52), 1.1)
    p.line([(342, 106), (335, 143), (322, 164)], (174, 98, 52), 1.1)
    p.line([(251, 175), (269, 183), (283, 179)], STITCH, 0.75)
    p.line([(341, 175), (323, 183), (309, 179)], STITCH, 0.75)
    # Soft folded linen V-neck and central lace-up placket.
    p.poly([(275, 74), (315, 74), (303, 93), (296, 99), (289, 93)], LINEN_LIGHT, LINEN_SHADE, 1.0)
    p.poly([(286, 91), (296, 101), (306, 91), (302, 113), (296, 119), (290, 113)], (237, 222, 193), LINEN_SHADE, 0.7)
    p.line([(296, 101), (296, 168)], (139, 105, 68), 1.2)
    # Six X-laces with brass eyelets, matching the icon's hand-laced vest.
    for y in (108, 119, 130, 141, 152, 163):
        p.ellipse((286, y-1, 289, y+2), BRASS_LIGHT)
        p.ellipse((303, y-1, 306, y+2), BRASS_LIGHT)
        p.line([(288, y), (304, y+5)], (235, 202, 148), 1.3)
        p.line([(304, y), (288, y+5)], (102, 55, 31), 1.0)
    # Belt and a small, practical brass buckle at the waist.
    p.box((231, 178, 360, 196), LEATHER_DARK)
    p.line([(232, 180), (359, 180)], LEATHER_LIGHT, 1.6)
    p.line([(232, 194), (359, 194)], STITCH, 1)
    p.box((286, 179, 306, 195), BRASS, LEATHER_DARK, 1.0)
    p.box((290, 182, 302, 192), LEATHER_DARK)
    p.box((293, 184, 299, 190), BRASS_LIGHT)
    # Belt loops, punched holes and a keeper make the belt read as leather.
    for lx in (249, 272, 322, 344):
        p.box((lx, 178, lx+4, 196), (78, 37, 22))
        p.line([(lx+1, 180), (lx+1, 194)], LEATHER_LIGHT, 0.7)
    for hx in (314, 319, 324):
        p.ellipse((hx, 185, hx+1.7, 186.7), (30, 20, 16))
    # A short tied end hangs just below the belt at the center.
    p.poly([(308, 189), (318, 193), (315, 216), (309, 224), (304, 215)], LEATHER, LEATHER_DARK, 1.0)
    p.line([(310, 197), (311, 213)], LEATHER_LIGHT, 1.1)

    # Back panel: linen underlayer and a simple continuous leather vest back.
    p.gradient((426, 73, 556, 203), LINEN_LIGHT, LINEN_SHADE)
    p.poly([(435, 81), (547, 81), (541, 177), (526, 187), (453, 187), (438, 177)], LEATHER, LEATHER_DARK, 1.4)
    p.line([(441, 90), (478, 99), (490, 104), (502, 99), (541, 90)], LEATHER_LIGHT, 1.5)
    p.line([(440, 97), (450, 170)], LEATHER_LIGHT, 1)
    p.line([(542, 97), (532, 170)], LEATHER_DARK, 1)
    p.line([(490, 105), (490, 176)], LEATHER_DARK, 1.2)
    p.line([(454, 112), (478, 118)], STITCH, 0.8)
    p.line([(502, 118), (526, 112)], STITCH, 0.8)
    p.line([(446, 101), (453, 168)], STITCH, 0.75)
    p.line([(534, 101), (527, 168)], STITCH, 0.75)
    # Gentle cloth creases remain visible at the sides and hem beneath the vest.
    p.line([(433, 146), (437, 157), (434, 170)], (231, 214, 185), 1.0)
    p.line([(548, 145), (544, 158), (548, 169)], (145, 121, 91), 1.0)
    p.box((426, 180, 556, 195), LEATHER_DARK)
    p.line([(427, 182), (555, 182)], LEATHER_LIGHT, 1.2)
    p.line([(427, 193), (555, 193)], STITCH, 0.8)
    # Top shoulder cap is linen with a subtle collar/shoulder seam.
    p.gradient((231, 7, 360, 73), LINEN_LIGHT, LINEN_SHADE)
    p.line([(238, 19), (276, 28), (296, 35), (316, 28), (353, 19)], LINEN_SHADE, 1.2)
    p.poly([(278, 8), (314, 8), (304, 26), (296, 31), (288, 26)], (236, 222, 195), LINEN_SHADE, 0.8)
    # Lower torso cap shows the tunic hem, with shadow under the belt.
    p.gradient((231, 203, 360, 264), LINEN_SHADE, (139, 119, 91))
    p.line([(236, 211), (355, 211)], (130, 108, 79), 1.2)
    p.line([(241, 218), (350, 218)], (198, 174, 137), 0.9)


def draw_arm_island(p: Painter, x: int, tile_x: int):
    # Four wrapped sleeve faces, two rows. x=15 is right arm, x=303 left arm.
    # Light shifts by face help the islands read as fabric rather than flat panels.
    face_tones = [LINEN_LIGHT, (225, 211, 183), (203, 184, 150), (231, 218, 192)]
    face_xs = [x, x + 64, x + 128, (tile_x if x == 15 else x + 200)]
    for col, tone in enumerate(face_tones):
        xx = face_xs[col]
        p.gradient((xx, 359, xx+64, 487), tone, (161, 140, 110))
        # Long soft folds along the upper sleeve and forearm.
        # Loose linen folds are broader and softer like the generated chest icon.
        p.line([(xx+7, 367), (xx+15, 374), (xx+12, 387), (xx+18, 397)], (248, 238, 219), 1.4)
        p.line([(xx+10, 373), (xx+14, 389), (xx+9, 405)], (151, 127, 98), 0.8)
        p.line([(xx+54, 364), (xx+48, 378), (xx+52, 391), (xx+45, 406)], (142, 120, 92), 1.1)
        p.line([(xx+49, 370), (xx+44, 386), (xx+49, 399)], (244, 232, 209), 0.9)
        p.line([(xx+5, 430), (xx+13, 437), (xx+9, 448), (xx+15, 458)], (246, 234, 210), 1.2)
        p.line([(xx+57, 429), (xx+51, 439), (xx+55, 450), (xx+49, 460)], (134, 113, 87), 1.0)
        p.line([(xx+20, 414), (xx+27, 419), (xx+33, 414)], (184, 160, 126), 0.8)
        # Cream linen cuff sits directly above the separate leather glove.
        p.box((xx+1, 454, xx+63, 463), (217, 199, 168))
        p.line([(xx+3, 455), (xx+61, 455)], LINEN_LIGHT, 1.0)
        p.line([(xx+3, 462), (xx+61, 462)], LINEN_SHADE, 0.8)
        # Glove leather wraps the wrist/hand area in the lower face.
        p.box((xx+1, 464, xx+63, 485), LEATHER_DARK)
        p.box((xx+3, 466, xx+61, 481), LEATHER)
        p.line([(xx+4, 468), (xx+60, 468)], LEATHER_LIGHT, 1.1)
        p.line([(xx+4, 480), (xx+60, 480)], STITCH, 0.8)
        p.line([(xx+11, 472), (xx+53, 472)], LEATHER_DARK, 0.8)
        p.line([(xx+8, 476), (xx+56, 476)], (125, 64, 36), 0.8)

    # On the front-facing arm panels, add the glove's small cuff lacing and patch.
    front_x = tile_x if x == 15 else x
    p.poly([(front_x+8, 465), (front_x+56, 465), (front_x+53, 482), (front_x+11, 482)], LEATHER_LIGHT, LEATHER_DARK, 0.8)
    for yy in (469, 475, 480):
        p.ellipse((front_x+15, yy-1, front_x+18, yy+2), BRASS)
        p.ellipse((front_x+46, yy-1, front_x+49, yy+2), BRASS)
        p.line([(front_x+17, yy), (front_x+47, yy+2)], (220, 167, 105), 0.8)

    # Small cuffs on sleeve caps/end faces, matching the wrapped cuff color.
    p.gradient((tile_x, 295, tile_x+64, 359), LINEN_LIGHT, LINEN_SHADE)
    p.line([(tile_x+8, 349), (tile_x+56, 349)], LEATHER_DARK, 2.2)
    p.line([(tile_x+10, 346), (tile_x+54, 346)], LEATHER_LIGHT, 1.1)
    p.gradient((tile_x, 488, tile_x+64, 552), LEATHER, LEATHER_DARK, horizontal=True)
    p.poly([(tile_x+8, 496), (tile_x+56, 496), (tile_x+51, 534), (tile_x+13, 534)], (91, 42, 24), LEATHER_DARK, 1)
    p.line([(tile_x+15, 502), (tile_x+48, 502)], LEATHER_LIGHT, 0.9)
    p.ellipse((tile_x+27, 509, tile_x+37, 519), BRASS, LEATHER_DARK, 1)
    p.line([(tile_x+14, 533), (tile_x+50, 533)], STITCH, 0.9)


def draw_shirt(p: Painter):
    draw_torso(p)
    draw_arm_island(p, 15, 215)
    draw_arm_island(p, 303, 303)


def draw_leg_island(p: Painter, x: int, tile_x: int):
    # Four wrapped trouser/boot faces per leg, aligned with the project's R15 UV.
    # Face four is a separate UV island, eight pixels beyond the first three.
    face_xs = [x, x + 64, x + 128, (tile_x if x == 15 else x + 200)]
    for col in range(4):
        xx = face_xs[col]
        p.gradient((xx, 359, xx+64, 435), PANTS_LIGHT, PANTS_SHADE)
        # Loose upper trousers with a restrained waist seam, folds and topstitching.
        p.box((xx+1, 359, xx+63, 365), (100, 68, 46))
        p.line([(xx+3, 361), (xx+61, 361)], (220, 174, 112), 0.7)
        p.line([(xx+10, 372), (xx+17, 380), (xx+14, 394), (xx+20, 404)], PANTS_LIGHT, 1.3)
        p.line([(xx+52, 370), (xx+47, 385), (xx+51, 399), (xx+44, 412)], PANTS_SHADE, 1.0)
        p.line([(xx+7, 414), (xx+14, 418), (xx+19, 428)], (235, 214, 183), 1.0)
        p.line([(xx+56, 411), (xx+50, 419), (xx+55, 430)], (111, 87, 65), 0.9)
        p.line([(xx+24, 431), (xx+31, 426), (xx+39, 432)], (124, 101, 75), 0.8)
        # Boot begins just below the loose trouser cuff; share the icon's leather shades.
        p.gradient((xx, 432, xx+64, 487), BOOT_LIGHT, BOOT_SHADE, horizontal=True)
        p.box((xx+2, 433, xx+62, 443), (64, 39, 31))
        p.line([(xx+4, 435), (xx+60, 435)], (157, 105, 69), 1.0)
        p.line([(xx+5, 442), (xx+59, 442)], STITCH, 0.7)
        p.line([(xx+8, 449), (xx+13, 465), (xx+10, 483)], BOOT_LIGHT, 1.3)
        p.line([(xx+56, 449), (xx+51, 465), (xx+54, 483)], BOOT_SHADE, 1.1)
        # Front-facing panel gets the icon's two restrained brass boot straps.
        is_front = (x == 15 and col == 3) or (x == 303 and col == 0)
        if is_front:
            p.poly([(xx+11, 444), (xx+53, 444), (xx+49, 480), (xx+32, 484), (xx+15, 480)], (70, 42, 34), BOOT_LIGHT, 0.9)
            p.line([(xx+32, 446), (xx+32, 479)], (139, 91, 62), 0.8)
            for yy in (453, 470):
                p.box((xx+8, yy, xx+56, yy+5), (100, 59, 39))
                p.line([(xx+9, yy), (xx+55, yy)], (160, 105, 67), 0.7)
                p.line([(xx+9, yy+4), (xx+55, yy+4)], (38, 27, 23), 0.7)
                p.box((xx+44, yy-1, xx+51, yy+6), BRASS, LEATHER_DARK, 0.7)
                p.box((xx+46, yy+1, xx+49, yy+4), (57, 35, 26))

    # Top cap = trouser cloth; bottom cap = leather sole.
    p.gradient((tile_x, 295, tile_x+64, 359), PANTS_LIGHT, PANTS_SHADE)
    p.line([(tile_x+8, 306), (tile_x+56, 306)], (109, 87, 65), 1.2)
    p.line([(tile_x+10, 351), (tile_x+54, 351)], (124, 103, 79), 1.0)
    p.gradient((tile_x, 488, tile_x+64, 552), BOOT, BOOT_SHADE, horizontal=True)
    p.poly([(tile_x+7, 494), (tile_x+57, 494), (tile_x+53, 536), (tile_x+11, 536)], BOOT_LIGHT, BOOT_SHADE, 1)
    p.line([(tile_x+11, 528), (tile_x+53, 528)], (166, 108, 67), 0.9)
    p.line([(tile_x+12, 533), (tile_x+52, 533)], BRASS, 1.0)


def draw_pants(p: Painter):
    draw_leg_island(p, 15, 215)
    draw_leg_island(p, 303, 303)


def create_contact_sheet(shirt: Image.Image, pants: Image.Image, out_path: Path):
    bg = Image.new("RGBA", (1300, 650), (40, 35, 32, 255))
    d = ImageDraw.Draw(bg)
    try:
        font = ImageFont.truetype("arial.ttf", 23)
        small = ImageFont.truetype("arial.ttf", 15)
    except OSError:
        font = ImageFont.load_default()
        small = ImageFont.load_default()
    d.text((30, 18), "VANDRHEIM · ATUENDO DE VIAJERO · UV R15", font=font, fill=(244, 228, 196, 255))
    d.text((35, 54), "CAMISA · lino + chaleco de cuero", font=small, fill=(221, 201, 164, 255))
    d.text((685, 54), "PANTALÓN · tela beige + botas altas", font=small, fill=(221, 201, 164, 255))
    # Keep native resolution so the islands remain inspectable.
    bg.alpha_composite(shirt, (35, 78))
    bg.alpha_composite(pants, (685, 78))
    bg.convert("RGB").save(out_path, quality=95)


def main():
    shirt_path = OUT / "vandrheim_traveler_starter_classic_shirt_r15_v3.png"
    pants_path = OUT / "vandrheim_traveler_starter_classic_pants_r15_v3.png"

    shirt_art = Painter((*LINEN_LIGHT, 255))
    draw_shirt(shirt_art)
    shirt, shirt_mask = shirt_art.save_masked(MASK_DIR / "hunter_classic_shirt_r15.png", shirt_path)

    pants_art = Painter((*PANTS_LIGHT, 255))
    draw_pants(pants_art)
    pants, pants_mask = pants_art.save_masked(MASK_DIR / "hunter_classic_pants_r15.png", pants_path)

    # Strict mask validation required by the project workflow.
    for name, img, mask in (("shirt", shirt, shirt_mask), ("pants", pants, pants_mask)):
        if img.size != SIZE or img.mode != "RGBA":
            raise AssertionError(f"{name}: expected RGBA {SIZE}, got {img.mode} {img.size}")
        if img.getchannel("A").tobytes() != mask.getchannel("A").tobytes():
            raise AssertionError(f"{name}: exported alpha differs from source mask")
        print(f"{name}: {img.size}, RGBA; alpha matches mask exactly")

    create_contact_sheet(shirt, pants, OUT / "Preview_UV_Maps_v3.png")
    print(f"Created: {shirt_path}")
    print(f"Created: {pants_path}")
    print(f"Created: {OUT / 'Preview_UV_Maps_v3.png'}")


if __name__ == "__main__":
    main()
