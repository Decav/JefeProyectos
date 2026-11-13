"""Deriva los ciclos de strafe lateral del jugador R15 a partir del run en uso.

Fuente: Anims_player_r15_run_live_117397606531571.json (export exacto del asset
rbxassetid://117397606531571, slot `run` de AnimationRegistry, 44 frames a 60 fps).

Por qué derivar en vez de animar desde cero: el strafe se mezcla con el run
(fade 0.2 s en Animate) y debe compartir cadencia, rebote vertical, braceo y
duración (0.7333 s). Se conserva el ciclo del run y solo se reorienta:

  - LowerTorso: giro de cadera hacia el lado de avance sobre su propio eje
    (conserva la inclinación frontal del run) + leve inclinación hacia el avance.
  - Upper legs: giro adicional del plano de zancada + abducción para separar
    los apoyos (evita que la pierna de vuelo atraviese a la de apoyo).
  - Feet: compensación de la abducción para que la planta quede plana.
  - UpperTorso / Head: contragiro para que pecho y mirada sigan al frente
    (la cámara está bloqueada mientras se usa el strafe).

Convención de CFrame idéntica a Roblox: CFrame.Angles(x, y, z) = Rx * Ry * Rz,
euler extraído con ToEulerAnglesXYZ.

Uso:
  python3 derive_strafe_from_run.py            # regenera left_v2 y right_v2
"""

import json
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
LOCO = os.path.dirname(HERE)
SOURCE = os.path.join(LOCO, "Anims_player_r15_run_live_117397606531571.json")
VERSION = "v2"

PARAMS = {
    "hip_yaw_deg": 50.0,        # giro de LowerTorso hacia el avance
    "leg_yaw_deg": 40.0,        # giro adicional del plano de zancada
    "torso_counter_deg": 40.0,  # contragiro de UpperTorso (pecho al frente)
    "head_counter_deg": 6.0,    # contragiro adicional de la cabeza
    "lean_deg": 4.0,            # inclinación lateral hacia el avance
    "abduction_deg": 11.0,      # separación de apoyos
    "foot_compensation": 0.8,   # fracción de la abducción corregida en el tobillo
}


# ---------- álgebra de CFrame (rotación 3x3 + posición) ----------

def mat_mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]


def mat_vec(a, v):
    return [sum(a[i][k] * v[k] for k in range(3)) for i in range(3)]


def rx(t):
    c, s = math.cos(t), math.sin(t)
    return [[1, 0, 0], [0, c, -s], [0, s, c]]


def ry(t):
    c, s = math.cos(t), math.sin(t)
    return [[c, 0, s], [0, 1, 0], [-s, 0, c]]


def rz(t):
    c, s = math.cos(t), math.sin(t)
    return [[c, -s, 0], [s, c, 0], [0, 0, 1]]


def angles(x, y, z):
    return mat_mul(mat_mul(rx(x), ry(y)), rz(z))


def to_euler_xyz(m):
    y = math.asin(max(-1.0, min(1.0, m[0][2])))
    x = math.atan2(-m[1][2], m[2][2])
    z = math.atan2(-m[0][1], m[0][0])
    return x, y, z


class CF:
    def __init__(self, rot, pos):
        self.rot = rot
        self.pos = pos

    @staticmethod
    def from_entry(e):
        r = e["rotation"]
        p = e["position"]
        rot = angles(math.radians(r["x"]), math.radians(r["y"]), math.radians(r["z"]))
        return CF(rot, [p["x"], p["y"], p["z"]])

    @staticmethod
    def angles(x=0.0, y=0.0, z=0.0):
        return CF(angles(math.radians(x), math.radians(y), math.radians(z)), [0.0, 0.0, 0.0])

    def __mul__(self, o):
        return CF(mat_mul(self.rot, o.rot), [a + b for a, b in zip(mat_vec(self.rot, o.pos), self.pos)])

    def rotation(self):
        return CF(self.rot, [0.0, 0.0, 0.0])

    def to_entry(self, joint, frame):
        x, y, z = to_euler_xyz(self.rot)
        return {
            "joint": joint,
            "frame": frame,
            "rotation": {"x": round(math.degrees(x), 2), "y": round(math.degrees(y), 2), "z": round(math.degrees(z), 2)},
            "position": {"x": round(self.pos[0], 3), "y": round(self.pos[1], 3), "z": round(self.pos[2], 3)},
        }


def clean(v):
    return 0.0 if v == 0 else v


# ---------- derivación ----------

def derive(cf, joint, d, p):
    """d = +1 strafe derecha, -1 strafe izquierda."""
    if joint == "Root":
        yaw = CF.angles(y=-d * p["hip_yaw_deg"])
        pos = mat_vec(yaw.rot, cf.pos)
        return CF(CF.angles(z=-d * p["lean_deg"]).rot, pos) * cf.rotation() * yaw
    if joint == "LeftHip":
        return CF.angles(y=-d * p["leg_yaw_deg"]) * CF.angles(z=-p["abduction_deg"]) * cf
    if joint == "RightHip":
        return CF.angles(y=-d * p["leg_yaw_deg"]) * CF.angles(z=p["abduction_deg"]) * cf
    if joint == "LeftAnkle":
        return CF.angles(z=p["abduction_deg"] * p["foot_compensation"]) * cf
    if joint == "RightAnkle":
        return CF.angles(z=-p["abduction_deg"] * p["foot_compensation"]) * cf
    if joint == "Waist":
        return CF.angles(y=d * p["torso_counter_deg"]) * cf
    if joint == "Neck":
        return CF.angles(y=d * p["head_counter_deg"]) * cf
    return cf


def build(src, side):
    d = 1 if side == "right" else -1
    name = "player_r15_run_strafe_%s_%s" % (side, VERSION)
    lado = "derecha" if side == "right" else "izquierda"
    keyframes = []
    for e in src["keyframes"]:
        out = derive(CF.from_entry(e), e["joint"], d, PARAMS).to_entry(e["joint"], e["frame"])
        for k in ("rotation", "position"):
            out[k] = {a: clean(b) for a, b in out[k].items()}
        keyframes.append(out)
    return {
        "animation_name": name,
        "description": (
            "Carrera lateral hacia la %s para R15 con cámara bloqueada, derivada del run en uso "
            "(rbxassetid://117397606531571): misma cadencia, rebote y braceo; cadera y zancada giradas "
            "hacia el avance, pecho y mirada al frente, apoyos separados sin cruce de piernas." % lado
        ),
        "total_frames": src["total_frames"],
        "fps": src["fps"],
        "intensity": src.get("intensity", 0.85),
        "loop": True,
        "priority": "Movement",
        "source_animation": src["animation_name"],
        "derivation": dict(PARAMS),
        "keyframes": keyframes,
    }


def main():
    with open(SOURCE, encoding="utf-8") as fh:
        src = json.load(fh)
    for side in ("left", "right"):
        data = build(src, side)
        path = os.path.join(LOCO, "Anims_%s.json" % data["animation_name"])
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(data, fh, ensure_ascii=False, indent=2)
            fh.write("\n")
        print("escrito", os.path.relpath(path, LOCO), len(data["keyframes"]), "entradas")


if __name__ == "__main__":
    main()
