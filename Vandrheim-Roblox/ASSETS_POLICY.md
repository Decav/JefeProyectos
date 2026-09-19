# Vandrheim — Política de Assets (animaciones e iconos)

> Documento de política de recursos visuales. Complementa GDD §17 (Assets).
> Última actualización: 2026-08-23
> Decisión de producto: **gratis + placeholders + producción propia (modelos/materiales/UI/iluminación) + animaciones SOLO de la Roblox Library** (el dev no hace rigging/animaciones propias).

---

## 1. Principios

1. **Costo cero mientras sea posible:** Roblox Library gratuita + placeholders + producción propia de modelos/materiales/UI/iluminación.
2. **Animaciones NO se crean:** no hay rigging ni animación propia (capacidad del dev). Todas las animaciones vienen de la **Roblox Library / Marketplace** (gratis o compra con decisión explícita).
3. **Licencia respetada siempre:** todo asset con fuente clara; créditos al autor cuando la licencia lo pida; **prohibido** material sin licencia o "stolen".
4. **Placeholders estándar hasta que los assets reales existan:** reemplazables **solo cambiando el `id` en config** (nunca tocar código).
5. **Assets = visuales puros:** no afectan gameplay ni stats; el daño/efecto siempre es server (R3).
6. **Registro obligatorio:** todo asset real incorporado se anota en el `ASSETS_REGISTRY` (abajo).

---

## 2. Capacidad del desarrollador (confirmada 2026-08-12)

| Puede | No puede |
|-------|----------|
| Modelos | Crear/riggear animaciones |
| Materiales | Rigging de meshes |
| Colores / paletas | Edición fina de meshes |
| UI (ventanas, HUD, iconos) | — |
| Iluminación (Lighting, atmosphere, fog) | — |
| **VFX con partículas** (`ParticleEmitter`, `Beam`, `Trail`, `Attachment`, Tween de color/tamaño/transparencia/velocidad/duración) — confirmado 2026-08-26 | — |
| **Buscar/seleccionar animaciones en la Library** | — |

---

## 3. Fuentes permitidas

| Fuente | Uso | Regla |
|--------|-----|-------|
| **Roblox Library / Marketplace** | **Única fuente de animaciones** (gratis o compra) | Filtrar "Free" por defecto; registrar `rbxassetid` + autor + URL; crédito si aplica |
| Roblox Library (decals/sonidos) | Decals, sonidos gratuitos | Mismas reglas de registro |
| Animaciones default de Roblox | Base/placeholder (movimiento R15 automático) | Sin licencia pendiente (platform default) |
| Producción propia (dev) | Modelos, materiales, UI, iconos, iluminación | Capacidad confirmada; no incluye animaciones |
| Iconos generados (scripts/UI) | Placeholders "color + inicial", formas geométricas | Zero assets; reemplazables después |
| **Iconos con IA (Gemini Imagen)** | Iconos de ítems/skills reales (R8) | **PNG 512×512 con fondo negro #000000 = finales** (decisión R8, 2026-08-26; sustituye al fondo transparente del 2026-08-12); revisión de producto antes de usarse; registro en ASSETS_REGISTRY |
| Compra (futuro, presupuesto) | Paquetes premium de animación/iconos | Solo con decisión explícita de producto; registrar licencia |
| **Prohibido** | Assets de terceros no permitidos, emojis en iconos, texturas de otros juegos, animaciones "de otro juego" | — |

---

## 4. Estructura y naming

```text
ReplicatedStorage/
  Assets/
    Animations/   -- Anims_<tipo>_<skillType>  (ids de librería; solo referencia)
    Icons/        -- Icon_Skill_<id> / Icon_Item_<id> / Icon_Rarity_<nombre>
    Models/       -- Modelo_<prop|npc|mob|boss|arma>
    Materials/    -- Mat_<nombre>
    VFX/          -- (futuro, si el dev lo confirma) partículas
    SFX/          -- (futuro) sonidos
```

* Los IDs viven en **config data-driven** (`iconId`, `animationId` en SkillConfig/ItemConfig) — nunca hardcodeados en scripts.
* Una animación/icono puede compartirse entre varios ítems/skills; el registro indica reusos.

---

## 5. Placeholder estándar (hasta que existan los assets reales)

* **Animaciones:** default de Roblox (idle/walk/run automáticos del R15). Combate puede usar una animación gratuita de la librería (ej. punch/slash/cast) — no bloquea gameplay.
* **Iconos:** `Frame`/`ImageLabel` con **color de rareza + letra inicial del nombre** (ej. "C" = Consagración). El tooltip muestra el texto real.
* **Criterio:** cualquier placeholder debe poder reemplazarse cambiando un id en config, sin tocar código.

---

## 6. Plan por fase

| Fase | Animaciones | Iconos / estética |
|------|-------------|-------------------|
| R4–R7 | Default o gratuitas de librería puntuales | Placeholders color+inicial; **HU-ASSETS puede adelantar UI/iconos/modelos en paralelo** |
| **R6.1** | Animaciones R15 de caminar/correr de Library o default; registrar ids | Reutilizar SFX existentes de `FootstepSystem`, sincronizados por material y animación |
| **R8** | De la **librería** por skillType (12–18): melee slash, ranged shot, cast mágico, cast AoE, heal, shield, buff — buscadas/registradas por el dev | Iconos reales de skills (30) |
| **R8d** | — | Iconos reales de skills (30) + QA; **VFX únicos por skill integrados en cada HU de clase (R8a/b/c)** |
| R9 | Polish: feedback de hits, **VFX real** (confirmado), sonido (SFX — pendiente de confirmar) | Iconos finales de ítems + UI polish |

**Límite anti-scope-creep:** máximo **1 animación por skillType** + variantes por spec **solo si sobran sesiones** en R8. Nunca 1 animación por skill "porque queda lindo".

---

## 7. Consejos prácticos — selección de animaciones (Roblox Library)

1. **Filtrar "Free"** por defecto; verificar que sean compatibles con **R15** (nuestro avatar).
2. **Probar en Play Solo** con `AnimationController` antes de fijar el id (que no rompan la cámara R3.1 ni el auto-attack).
3. **Preferir animaciones por skillType reutilizables:** 1 melee, 1 ranged, 1 cast mágico, 1 cast AoE, 1 heal, 1 shield/buff → cubren las 30 skills con ~6 animaciones.
4. **Registrar siempre** en `ASSETS_REGISTRY` (rbxassetid, autor, licencia, crédito si aplica).
5. **Riesgo de assets que se eliminan:** guardar el `rbxassetid` + captura local; tener 1–2 alternativas por skillType.

---

## 8. Consejos prácticos — producción propia (modelos/UI/iluminación)

1. **Modelos:** partir de primitivas/bases de Roblox y ajustar en Studio; el dummy (R1), props del hub, mobs y boss del dungeon (R6–7) son los candidatos principales.
2. **Materiales:** usar `PhysicalMaterial`/`MaterialVariant` con `PBR`; paleta de "Helada" para el dungeon y tono cálido/pueblo para el hub.
3. **UI:** estilizar las ventanas existentes (inventario, skills, vendor, talentos, HUD) manteniendo **Scale + UIAspectRatioConstraint** y sin romper móvil (`TouchEnabled`).
4. **Iluminación:** presets de `Lighting` (atmosphere, fog, sun) coherentes con el tema; por Place.
5. **Iconos reales:** 512×512 PNG transparente con nombre `Icon_<skill|item>_<id>`; la UI los escala. **Gemini devuelve JPG por defecto** (sin alfa): pedir PNG transparente vía AI Studio (Imagen 4 → "Background: Transparent") o API (`imageConfig = { imageType: "PNG", imageTransparency: "TRANSPARENT" }`). Si el resultado ya es JPG, regenerar (mejor que remover fondo).

---

## 9. Registro de assets (ASSETS_REGISTRY)

Se completa a medida que se incorporan assets reales (obligatorio en DoD de HU-ASSETS / R8–R9).

| rbxassetid | Tipo | Uso (skill/ítem/UI/modelo) | Fuente | Autor | Licencia | Fecha |
|------------|------|---------------------------|--------|-------|----------|-------|
| (ej. 123456789) | Animación | cast genérico mágico | Library | UsuarioX | Free (crédito) | 2026-XX-XX |
| ... | | | | | | |

---

## 10. Riesgos

1. **Assets de librería que se eliminan** → guardar el `rbxassetid` y captura local; registrar fuente; alternativas por skillType.
2. **Scope creep** animando 1 anim por skill → límite por skillType (ver §6).
3. **Licencias ignoradas** → checklist de DoD incluye registro y estado de licencia.
4. **Placeholders que bloquean el feeling MMO** → R8 es el punto de corte; si hace falta antes, priorizar 3–4 animaciones clave de librería (melee, cast, heal, AoE).

---

## 11. Historial

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Creación de la política de assets |
| 2026-08-12 | Capacidad del dev confirmada: modelos/materiales/UI/iluminación sí; animaciones NO (solo librería). Política ajustada |
| 2026-08-12 | Iconos con IA (Gemini) habilitados: PNG 512×512 transparente; batch Paladín (armas/armaduras/pociones) en curso; catálogo completo en R8 |
| 2026-08-23 | HU-R6.1 integra los sonidos existentes de `FootstepSystem` por material; no crea nuevos paquetes SFX ni envía eventos por cada pisada |
| 2026-08-26 | **VFX con partículas confirmado** (ParticleEmitter/Beam/Trail, client-side con autoridad server). R6.8/R6.9 (VFX básico y zonas AoE) completas; **VFX únicos por skill en R8a/b/c (por clase)**; SFX/sonido → R9 |
