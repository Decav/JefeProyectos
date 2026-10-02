## HU-ASSETS: Producción de assets estéticos (modelos, materiales, UI, iluminación + selección de animaciones de la Library)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Assets estéticos — **transversal** (no bloquea fases de gameplay)  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-12)  
**Fase GDD:** Épica transversal (GDD §17, §21; ASSETS_POLICY.md)  
**Depende de:** ASSETS_POLICY.md (reglas/naming/registro); no depende de fases de gameplay (corre en paralelo con R5–R7)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** ver un mundo, UI, modelos y efectos visuales coherentes con la fantasía de Vandrheim (pueblo + mazmorra helada), con animaciones que acompañen las acciones,  
**para** que el juego se sienta pulido y de MMO tradicional, no un placeholder gris.

---

### **Descripción del Requerimiento / Contexto**

El dev **sí produce** modelos, materiales, colores, UI e iluminación, pero **NO crea animaciones** (ni rigging ni edición fina de meshes). Las animaciones se **buscan y seleccionan en la Roblox Library/Marketplace** (gratis por defecto) y se referencian por `rbxassetid`.

Esta HU consolida la producción estética en un solo incremento, reemplazando placeholders (color + inicial, animaciones default) **solo cambiando ids en config** — sin tocar código de gameplay.

**Foco transversal:** corre en paralelo con R5–R7; los assets se integran por config (SkillConfig/ItemConfig/UI) y por Place (hub/dungeon).

---

### **Especificaciones Técnicas / Contratos de API**

#### **Capacidades confirmadas (dev)**

| Produce | No produce |
|---------|------------|
| Modelos | Animaciones (rigging) |
| Materiales | Edición fina de meshes |
| Colores/paletas | — |
| UI (ventanas, HUD, iconos) | — |
| Iluminación (Lighting) | — |
| **Busca animaciones en la Library** | — |

#### **Entregables por área**

* **Modelos:** props del hub, dummy (R1) rediseñado, mobs y boss del dungeon (R6–7), armas (visual en R15), NPCs. Paleta de "Helada" (dungeon) y tono pueblo (hub).
* **Materiales:** `MaterialVariant`/`PhysicalMaterial` con PBR; texturas propias.
* **UI:** estilizado de ventanas existentes (inventario, skills, vendor, talentos, HUD) — mantener **Scale + UIAspectRatioConstraint**, sin romper móvil (`TouchEnabled`).
* **Iluminación:** presets de `Lighting` por Place (atmosphere, fog, sun).
* **Iconos:** reales para skills (30, R8) y ítems, y para UI; 512×512 PNG transparente.
* **Animaciones:** selección en la **Roblox Library** (filtro Free) de ~6 por skillType reutilizables (melee, ranged, cast mágico, cast AoE, heal, shield/buff) + movimiento. **No crear.**

#### **Estructura y naming**

```text
ReplicatedStorage/Assets/
  Animations/   -- Anims_<tipo>_<skillType>   (ids de librería; solo referencia)
  Icons/        -- Icon_Skill_<id> / Icon_Item_<id> / Icon_Rarity_<nombre>
  Models/       -- Modelo_<prop|npc|mob|boss|arma>
  Materials/    -- Mat_<nombre>
```

IDs en **config data-driven** (`iconId`, `animationId`) — nunca hardcode.

#### **Integración**

* Los assets reemplazan placeholders **cambiando el id en config**; el gameplay (daño, cast, cámara R3.1, targeting) queda intacto.
* El `ASSETS_REGISTRY` (ASSETS_POLICY §9) se completa por cada asset real incorporado.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Hub con estética Vandrheim**

* **GIVEN** el hub existente (R0)
* **WHEN** se aplican modelos, materiales, colores e iluminación del tema
* **THEN** el pueblo se ve coherente con la fantasía (sin romper spawn, cámara ni movimiento)

#### **Escenario 2: UI estilizada sin romper gameplay**

* **GIVEN** las ventanas existentes (inventario, skills, vendor, talentos, HUD)
* **WHEN** se reemplaza la estética placeholder
* **THEN** se mantienen Scale + UIAspectRatioConstraint
* **AND** el inventario/vendor/talentos siguen funcionando (R4/R5)
* **AND** el drag de cámara se sigue pausando al abrir ventanas (R3.1)

#### **Escenario 3: Animaciones de la Library**

* **GIVEN** el dev no crea animaciones
* **WHEN** selecciona animaciones en la Roblox Library (filtro Free, R15)
* **THEN** quedan referenciadas por `animationId` en config
* **AND** están registradas en `ASSETS_REGISTRY` (rbxassetid, autor, licencia)
* **AND** probadas en Play Solo sin romper la cámara ni el auto-attack

#### **Escenario 4: Reemplazo por id (sin tocar código)**

* **GIVEN** un placeholder de icono/animación
* **WHEN** existe el asset real
* **THEN** se reemplaza cambiando el id en config (nunca código)
* **AND** el resto del sistema no cambia

#### **Escenario 5: Móvil intacto**

* **GIVEN** los cambios estéticos aplicados
* **WHEN** se testea en móvil (`TouchEnabled`)
* **THEN** la UI se ve bien y no se rompe la lógica de PC ni la móvil

#### **Escenario 6: Registro y licencias**

* **GIVEN** todo asset real incorporado
* **WHEN** se revisa el `ASSETS_REGISTRY`
* **THEN** cada asset tiene rbxassetid, fuente, autor y licencia
* **AND** no hay assets sin licencia clara

#### **Escenario 7: Sin errores**

* **GIVEN** los cambios estéticos aplicados
* **WHEN** se revisa el output
* **THEN** no hay errores rojos por assets/UI/iluminación

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **Paleta Vandrheim:** dungeon = Helada (fríos, azules, hielo); hub = pueblo cálido/oscuro de fantasía. Rarezas mantienen sus colores (Blanco/Verde/Azul/Morado).
* **Iconos:** claridad ante todo (el tooltip siempre muestra el texto real); 512×512 transparentes.
* **Animaciones:** solo librería, ~6 por skillType; nunca 1 por skill "porque queda lindo".
* **UI:** estética propia sin romper la interacción existente (ventanas pausan cámara, teclas 1–4, click derecho desequipar, etc.).
* **Placeholders:** todo asset real reemplaza al placeholder vía id en config.

---

### **Alcance**

#### Incluye

* Modelos (props hub, dummy, mobs/boss, armas, NPCs) — paleta del tema
* Materiales (PBR/MaterialVariant) + colores/paletas
* UI estilizada (HUD + ventanas existentes) + iconos reales (skills/ítems)
* Iluminación (Lighting) por Place
* Selección y registro de animaciones de la **Roblox Library** (filtro Free, R15), ~6 por skillType
* Integración vía config (ids) + `ASSETS_REGISTRY`

#### No incluye

* Crear/riggear animaciones propias, edición fina de meshes (no es capacidad del dev)
* VFX/SFX (partículas/sonido) — pendiente de confirmar capacidad
* Cambios a gameplay (daño, cast, targeting, cámara, economías)
* Assets comprados sin decisión explícita de producto
* Más de ~6 animaciones de librería en este incremento (anti-scope-creep)

---

### **Definition of Done (DoD)**

* [ ] Hub con estética Vandrheim aplicada (modelos/materiales/colores/iluminación)
* [ ] UI estilizada manteniendo Scale + UIAspectRatioConstraint y sin romper R4/R5
* [ ] Animaciones de librería seleccionadas, probadas en Play Solo y referenciadas por `animationId` (sin rigging propio)
* [ ] Iconos reales para los assets priorizados
* [ ] Todo asset en `ASSETS_REGISTRY` (id, autor, licencia)
* [ ] Reemplazo de placeholders solo vía id en config (ningún cambio de código de gameplay)
* [ ] Móvil intacto (TouchEnabled)
* [ ] Sin errores rojos en output
* [ ] Nota "HU-ASSETS completa" en GDD (§21)

---

### **Checklist Studio (referencia dev)**

* [ ] Crear `ReplicatedStorage/Assets/` (Animations/Icons/Models/Materials)
* [ ] Modelos + materiales + paleta: hub, dummy, mobs/boss, armas, NPCs
* [ ] UI estilizada (HUD, inventario, skills, vendor, talentos) + iconos reales
* [ ] Iluminación por Place (hub/dungeon)
* [ ] Buscar en Library ~6 animaciones R15 Free por skillType + registrar
* [ ] Referenciar ids en SkillConfig/ItemConfig/UI (nunca código)
* [ ] Completar `ASSETS_REGISTRY`
* [ ] Test en PC y móvil; Play Solo sin errores

---

### **Decisiones por defecto HU-ASSETS (si no se cambian)**

| Tema | Default |
|------|---------|
| Animaciones | Solo librería (Free, R15), ~6 por skillType; sin rigging propio |
| Iconos | 512×512 PNG transparente; color de rareza |
| Modelos/materiales | Tema Helada (dungeon) + pueblo (hub) |
| UI | Estilizar las ventanas existentes; Scale + ratio; sin romper móvil |
| Prioridad de integración | En paralelo con R5–R7; se integra por id en config |
| VFX/SFX | **VFX con partículas confirmado** (R8d/R9); SFX pendiente de confirmar capacidad |

---

### **Estimación (orientativa)**

2–4 sesiones (esfuerzo paralelo; no bloquea el roadmap de gameplay).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Creación HU-ASSETS tras confirmar capacidad del dev (modelos/materiales/UI/iluminación sí; animaciones solo librería) |
| 2026-08-12 | Marcada completada según reporte del equipo |
| 2026-08-25 | El equipamiento visible del avatar se separa como `HU-ESTETICA-01`; HU-ASSETS queda como base de assets/política general |
| 2026-08-26 | VFX con partículas confirmado (ParticleEmitter/Beam/Trail): pasa a R8d/R9; SFX sigue pendiente |
