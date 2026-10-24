from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import math


ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent
MASK_DIR = ROOT / "Assets" / "Clothing" / "EST-07"
SIZE = (585, 559)
S = 3

# Warm, restrained colors taken from the reference outfit and adapted to the
# project's readable, painterly Roblox clothing style.
LINEN = (224, 208, 178)
LINEN_LIGHT = (242, 230, 204)
LINEN_SHADE = (167, 145, 111)
LEATHER = (112, 59, 31)
LEATHER_LIGHT = (157, 91, 49)
LEATHER_DARK = (65, 36, 25)
STITCH = (204, 157, 98)
PANTS = (167, 145, 114)
PANTS_LIGHT = (197, 175, 141)
PANTS_SHADE = (113, 94, 75)
BOOT = (45, 38, 43)
BOOT_LIGHT = (83, 62, 55)
BOOT_SHADE = (24, 23, 29)
BRASS = (179, 131, 57)
BRASS_LIGHT = (231, 190, 108)


def rgb(hex_color: str) -> tuple[int, int, int]:
    h = hex_color.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


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
        w, h = max(1, round((x1-x0)*S)), max(1, round((y1-y0)*S))
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
    # Soft folded linen V-neck and central lace-up placket.
    p.poly([(275, 74), (315, 74), (303, 93), (296, 99), (289, 93)], LINEN_LIGHT, LINEN_SHADE, 1.0)
    p.poly([(286, 91), (296, 101), (306, 91), (302, 113), (296, 119), (290, 113)], (237, 222, 193), LINEN_SHADE, 0.7)
    p.line([(296, 101), (296, 168)], (139, 105, 68), 1.2)
    # Five simple X laces; broad enough to read at avatar size.
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
    for col, tone in enumerate(face_tones):
        xx = x + col * 64
        p.gradient((xx, 359, xx+64, 487), tone, (161, 140, 110))
        # Long soft folds along the upper sleeve and forearm.
        p.line([(xx+8, 365), (xx+14, 388), (xx+10, 411)], (248, 238, 216), 1.4)
        p.line([(xx+54, 366), (xx+48, 390), (xx+52, 410)], LINEN_SHADE, 1.0)
        p.line([(xx+5, 431), (xx+12, 447), (xx+9, 460)], (240, 227, 201), 1.2)
        p.line([(xx+57, 429), (xx+50, 446), (xx+54, 459)], LINEN_SHADE, 1.0)
        p.line([(xx+15, 401), (xx+20, 407)], (189, 167, 132), 0.8)
        p.line([(xx+43, 395), (xx+38, 403)], (189, 167, 132), 0.8)
        # Narrow leather cuff at the wrist on every wrapped face.
        p.box((xx+1, 464, xx+63, 484), LEATHER_DARK)
        p.box((xx+2, 467, xx+62, 480), LEATHER)
        p.line([(xx+3, 468), (xx+61, 468)], LEATHER_LIGHT, 1.2)
        p.line([(xx+3, 480), (xx+61, 480)], STITCH, 0.8)
        p.line([(xx+15, 472), (xx+48, 472)], LEATHER_DARK, 0.7)

    # Small cuffs on sleeve caps/end faces, matching the wrapped cuff color.
    p.gradient((tile_x, 295, tile_x+64, 359), LINEN_LIGHT, LINEN_SHADE)
    p.line([(tile_x+8, 349), (tile_x+56, 349)], LEATHER_DARK, 2.2)
    p.line([(tile_x+10, 346), (tile_x+54, 346)], LEATHER_LIGHT, 1.1)
    p.gradient((tile_x, 488, tile_x+64, 552), LEATHER_DARK, LEATHER)
    p.ellipse((tile_x+27, 509, tile_x+37, 519), BRASS, LEATHER_DARK, 1)
    p.line([(tile_x+17, 527), (tile_x+47, 527)], STITCH, 0.9)


def draw_shirt(p: Painter):
    draw_torso(p)
    draw_arm_island(p, 15, 215)
    draw_arm_island(p, 303, 303)


def draw_leg_island(p: Painter, x: int, tile_x: int):
    # Four wrapped trouser/boot faces per leg, aligned with the project's R15 UV.
    for col in range(4):
        xx = x + col * 64
        p.gradient((xx, 359, xx+64, 423), PANTS_LIGHT, PANTS_SHADE)
        # waistband and trouser upper panels
        p.box((xx+1, 359, xx+63, 367), (98, 72, 54))
        p.line([(xx+3, 361), (xx+61, 361)], STITCH, 0.8)
        p.line([(xx+12, 375), (xx+18, 386), (xx+14, 405)], PANTS_LIGHT, 1.3)
        p.line([(xx+53, 374), (xx+47, 388), (xx+50, 405)], PANTS_SHADE, 1.0)
        p.line([(xx+24, 411), (xx+31, 405), (xx+39, 411)], (124, 104, 81), 1.0)
        # Tall dark boots on the lower-leg row.
        p.gradient((xx, 423, xx+64, 487), BOOT_LIGHT, BOOT_SHADE, horizontal=True)
        p.box((xx+2, 425, xx+62, 437), BOOT)
        p.line([(xx+4, 428), (xx+60, 428)], (127, 95, 72), 1.1)
        p.line([(xx+7, 433), (xx+57, 433)], STITCH, 0.8)
        p.line([(xx+9, 440), (xx+13, 463), (xx+10, 483)], BOOT_LIGHT, 1.3)
        p.line([(xx+55, 440), (xx+51, 463), (xx+54, 483)], BOOT_SHADE, 1.1)
        # Front-facing panel gets quiet, functional lace/strap detail.
        front_x = xx
        is_front = (x == 15 and col == 3) or (x == 303 and col == 0)
        if is_front:
            p.poly([(xx+13, 438), (xx+51, 438), (xx+47, 479), (xx+32, 484), (xx+17, 479)], BOOT, BOOT_LIGHT, 0.9)
            p.line([(xx+32, 440), (xx+32, 478)], BOOT_LIGHT, 1.0)
            for yy in (444, 452, 460, 468, 476):
                p.ellipse((xx+21, yy-1, xx+24, yy+2), BRASS)
                p.ellipse((xx+40, yy-1, xx+43, yy+2), BRASS)
                p.line([(xx+23, yy), (xx+41, yy+3)], (188, 146, 99), 0.8)
                p.line([(xx+41, yy), (xx+23, yy+3)], (29, 26, 28), 0.7)

    # Top cap = trouser cloth; bottom cap = leather sole.
    p.gradient((tile_x, 295, tile_x+64, 359), PANTS_LIGHT, PANTS_SHADE)
    p.line([(tile_x+8, 306), (tile_x+56, 306)], (109, 87, 65), 1.2)
    p.line([(tile_x+10, 351), (tile_x+54, 351)], (124, 103, 79), 1.0)
    p.gradient((tile_x, 488, tile_x+64, 552), BOOT, BOOT_SHADE)
    p.poly([(tile_x+7, 494), (tile_x+57, 494), (tile_x+53, 536), (tile_x+11, 536)], BOOT_LIGHT, BOOT_SHADE, 1)
    p.line([(tile_x+12, 532), (tile_x+52, 532)], BRASS, 1.0)


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
    shirt_path = OUT / "vandrheim_traveler_starter_classic_shirt_r15_v1.png"
    pants_path = OUT / "vandrheim_traveler_starter_classic_pants_r15_v1.png"

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

    create_contact_sheet(shirt, pants, OUT / "Preview_UV_Maps.png")
    print(f"Created: {shirt_path}")
    print(f"Created: {pants_path}")
    print(f"Created: {OUT / 'Preview_UV_Maps.png'}")


if __name__ == "__main__":
    main()
