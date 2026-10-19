# Vandrheim — Política de Assets (animaciones e iconos)

> Documento de política de recursos visuales. Complementa GDD §17 (Assets).
> Última actualización: 2026-10-17
> Decisión de producto: **gratis cuando sea posible + producción propia + placeholders reemplazables**. Las animaciones se producen con Moon Animator (decisión PO 2026-09-22); la Roblox Library queda como referencia/fallback.

---

## 1. Principios

1. **Costo cero mientras sea posible:** assets propios, toolbox gratuita o placeholders; compras solo por decisión explícita del PO.
2. **Animaciones:** producción propia con **Moon Animator** como método aprobado; Library/Marketplace puede servir de referencia/fallback sujeto a licencia y aprobación.
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
| **Animaciones propias (Moon Animator)** | **Fuente principal de animaciones** — jugador y enemigos (capacidad confirmada por el PO 2026-09-22; se animaron jugador y casi todos los enemigos; nada viene de la toolbox) | Crear con Moon Animator; guardar `rbxassetid`; registrar en ASSETS_REGISTRY (fuente: producción propia); **excepción a la regla vieja "no crear animaciones"** |
| **Roblox Library / Marketplace** | Referencia/fallback de animaciones (si hace falta un placeholder) | Filtrar "Free" por defecto; registrar `rbxassetid` + autor + URL; crédito si aplica |
| Roblox Library (decals/sonidos) | Decals, sonidos gratuitos | Mismas reglas de registro |
| Animaciones default de Roblox | Base/placeholder (movimiento R15 automático) | Sin licencia pendiente (platform default) |
| Producción propia (dev) | Modelos, materiales, UI, iconos, iluminación, **animaciones con Moon Animator** | Capacidad confirmada; incluye animaciones propias |
| Iconos generados (scripts/UI) | Placeholders "color + inicial", formas geométricas | Zero assets; reemplazables después |
| **Iconos con IA (Gemini Imagen)** | Iconos de ítems/skills reales | **PNG 512×512 con FONDO TRANSPARENTE = finales** (decisión 2026-09-22; reemplaza al fondo negro #000000 del 2026-08-26, que a su vez había sustituido al transparente inicial del 2026-08-12); revisión de producto antes de usarse; registro en ASSETS_REGISTRY |
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

### 4.1 Organización local del repositorio

La copia de trabajo se organiza en `Assets/` según `Assets/README.md`: iconos finales bajo `Assets/Icons/{Classes,Items,Skills,Talents,UI}`, retratos/arte bajo `Assets/Images/{Brand,Enemies/Portraits,Marketing}`, y animaciones/ropa/audio en sus carpetas de tipo. Los masters, previews, prompts, entregas y scripts de assets aprobados van a `Assets/Source/`; `Assets/Temp/` queda solo para trabajo todavía no aprobado. Las rutas locales canónicas y los IDs Roblox se mantienen en `ASSETS_LIST.md`/este registro.

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
| 89348168546122 | Icono | Icon_Skill_hunter_mm_venom (R8e) | Subida informada por el usuario | Por confirmar | Por confirmar | 2026-09-23 |
| 80809123525734 | SFX | sfx_normal_hit — golpe básico sin armas (player/mobs) | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 136755951725689 | SFX | sfx_normal_hit_2 — golpe básico sin armas (variante) | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 140462043853173 | SFX | sfx_sword_hit — impacto de espada | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 138293953015099 | SFX | sfx_sword_skill — skill de espada | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 90951132448816 | SFX | sfx_bow_shoot — disparo de arco | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 81276928984693 | SFX | sfx_magic_hit — impacto mágico | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 9116385056 | SFX | sfx_magic_skill — skill mágica | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 137545490038565 | SFX | sfx_magic_skill_2 — skill mágica (variante) | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 138498992667102 | SFX | sfx_magic_heal — cura | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 9116384757 | SFX | sfx_magic_shield — escudo/barrera | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 140728595235867 | SFX | sfx_skill_selfAOE — AoE propia | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 99963459517796 | SFX | sfx_boss_AOE — AoE del jefe | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 9125640290 | SFX | sfx_boss_skill — skill del jefe | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 138867344936809 | SFX | sfx_die — muerte de enemigo | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 140602821561280 | SFX | sfx_lvl_up — subir de nivel | Aportado por el PO (subido, `Workspace.Sounds`) | Por confirmar | Uso propio | 2026-10-12 |
| 140395633128797 | SFX | Transacciones monetarias (vendor/subasta/oro) | Aportado por el PO (subido) | Por confirmar | Uso propio | 2026-10-12 |
| 77363443690081 | Música | Vandrheim — tema del hub/pueblo | Aportado por el PO (subido) | Decavii | Uso propio | 2026-10-12 |
| 112917722141522 | Música | Vandrheim-Frost-Dungeon1-2 — pisos 1–2 | Aportado por el PO (subido) | Decavii | Uso propio | 2026-10-12 |
| 70388794256162 | Música | Vandrheim-Frost-Dungeon3-5 — pisos 3–5 (más intenso) | Aportado por el PO (subido) | Decavii | Uso propio | 2026-10-12 |
| 126551601593677 | Música | Vandrheim-Frost-JotunnBossFight — batalla del jefe final | Aportado por el PO (subido) | Decavii | Uso propio | 2026-10-12 |
| 121076782362772 | Icono | Icon_Menu_nameplates — botón toggle de nameplates (micromenú) | Aportado por el PO (subido) | Decavii | Uso propio | 2026-10-12 |

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
