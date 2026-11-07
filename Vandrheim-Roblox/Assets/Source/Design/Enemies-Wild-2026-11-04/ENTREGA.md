# Entrega de Assets: Bestiario Salvaje y Humanoide (Retratos + Modelado 3D)

- **Fecha:** 2026-11-04
- **Dominio:** Assets / Bestiario y Combate
- **Convención Visual:** Fantasía oscura nórdica con estilo cel-shaded semirrealista, paleta de tonos tierra, pelajes desgastados, cuero, latón/hierro y escarcha sutil.

---

## 1. Retratos UI / Nameplates (512 × 512 RGBA Transparente)
Ubicación runtime: `Assets/Images/Enemies/Portraits/`

| Archivo | Enemigo | Descripción |
|---|---|---|
| `Portrait_Enemy_WildBoar.png` | Jabalí Salvaje de la Tundra | Primer plano en 3/4 con colmillos marfil curvos con runas, ojos ámbar y pelaje erizado. |
| `Portrait_Enemy_DireWolf.png` | Lobo Feroz de las Tierras Altas | Busto en 3/4 con cicatriz en hocico, mirada predatoria ámbar y fauces entreabiertas. |
| `Portrait_Enemy_Raider.png` | Saqueador / Asaltante Nórdico | Busto con yelmo nasal cónico de hierro y latón, pintura rúnica facial y manto de pieles. |

---

## 2. Hojas de Referencia para Modelado 3D (1024 × 1024 RGBA Transparente)
Ubicación: `Assets/Images/Enemies/FullBody/`

| Archivo | Formato / Pose | Propósito de Modelado |
|---|---|---|
| `Concept_Enemy_WildBoar_FullBody.png` | Pose 3/4 neutral con proporciones completas de cuadrúpedo robusto | Modelado de anatomía, silueta de joroba, colmillos, patas y pezuñas. |
| `Concept_Enemy_DireWolf_FullBody.png` | Pose 3/4 neutral con desglose de extremidades y silueta | Modelado y rigging de cuadrúpedo ágil lupino (distinto al lobo glacial elemental). |
| `Concept_Enemy_Raider_FullBody.png` | Turnaround en pose A con vistas ortogonales y proporciones | Referencia directa para modelado R15 / custom rig con hacha de combate y armadura por capas. |

---

## 3. Fuentes y Masters
- Carpeta: `Assets/Source/Design/Enemies-Wild-2026-11-04/`
  - `Masters/`: Archivos fuente brutos generados por IA.
  - `Previews/`: Vistas previas transparentes procesadas.
