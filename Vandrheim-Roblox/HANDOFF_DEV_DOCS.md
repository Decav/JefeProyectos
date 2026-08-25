# Handoff de Documentación — Sincronización con el proyecto Roblox

> Fecha: 2026-08-12
> Remitente: PM / PO
> Destinatario: Desarrollador (dev agent)
> Propósito: documentar en el proyecto Roblox los docs canónicos nuevos/actualizados. **No es tarea de implementación.**

---

## 1. Docs entregados (3 canónicos)

| Doc | Ruta local | Estado | Qué define |
|-----|-----------|--------|------------|
| **GDD** | `Vandrheim-Roblox/GDD_ROBLOX_MVP.md` | Actualizado | Fuente de verdad del alcance MVP. Cambios recientes: fases R0–R3.1 completas, **R4 en curso**, nueva **sección §17 (Assets)**, historial y próximos pasos (§20) |
| **ASSETS_POLICY** | `Vandrheim-Roblox/ASSETS_POLICY.md` | Nuevo | Política de assets: placeholders, fuentes permitidas, licencias, estructura/naming, plan por fase, `ASSETS_REGISTRY`, consejos (Animation Editor e iconos) |
| **SKILLS_CATALOG** | `Vandrheim-Roblox/SKILLS_CATALOG.md` | Nuevo | **42 skills** (2 básicas/clase + 6/spec), 6 skillTypes, curva de unlock 1/3/5/8/12/16, fórmulas de daño/cura, amenaza (`threatMod`), seed para `SkillConfig` |

---

## 2. Acciones requeridas (documentar, no implementar)

1. **GDD:** sincronizar la copia del GDD que exista dentro del proyecto Roblox (o registrar la referencia externa). Versionar los cambios, no sobrescribir en silencio.
2. **DATA_SCHEMA:** incorporar/actualizar los esquemas de datos:
   - `SkillConfig` — campos por tipo: `Instant` / `GroundAoE` / `Heal` / `HealAoE` / `Shield` / `Buff`; `iconId`, `animationId` (nuevo), `threatMod`.
   - `ItemConfig` + **instancia de ítem** (rolls, affixes, `bindState` Free/Bound, `ownerCharacterId`).
   - `Profile` (R2): `loadout` (4 slots), `inventory` / `equipment` (R4).
3. **PROJECT_ARCHITECTURE:** crear la carpeta `ReplicatedStorage/Assets/` (`Animations/`, `Icons/`, `VFX/`, `SFX/`) y reflejar los servicios existentes (SkillService, InventoryService) con sus dependencias de Assets.
4. **PROJECT_STANDARD:** agregar:
   - Naming de assets: `Anims_<tipo>_<clase>_<spec>_<skill>` / `Icon_Skill_<id>` / `Icon_Item_<id>`.
   - Regla de placeholders: color de rareza + inicial; reemplazo **solo cambiando el id en config, nunca código**.
5. **Seed de SkillConfig:** alinear el `SkillConfig` ya existente (R3) con `SKILLS_CATALOG.md` (mismos IDs: `clase_spec_nombre`). El catálogo es el seed canónico; los números son borrador hasta R8.
6. **ASSETS_REGISTRY:** dejar la tabla creada (vacía) en el proyecto para ir registrando assets reales desde R8.

---

## 3. Contexto de fases (para ubicarte)

- **Completas:** R0 (hub/places), R1 (dummy/combate), R2 (slots/persistencia), R3 (skills data-driven), R3.1 (cámara WoW-like).
- **En curso:** R4 — Inventario + equip + BoE + rolls + rareza (`HU/HU-R4-Inventario-Equip.md`).
- HUs formales: `Vandrheim-Roblox/HU/`. RCs: los genera el dev con `RC-TEMPLATE.md` (vía DEV_PROMPT).
- Skills disponibles en R3: básicas + Spec A (debug level flag para QA de unlocks).

---

## 4. Checklist de sincronización (dev)

- [ ] Los 3 docs quedan versionados/referenciados en el repo del proyecto
- [ ] `DATA_SCHEMA` actualizado (SkillConfig, ItemConfig, Profile)
- [ ] `PROJECT_ARCHITECTURE` refleja `ReplicatedStorage/Assets` + servicios
- [ ] `PROJECT_STANDARD` incluye naming de assets y regla de placeholder
- [ ] `SkillConfig` del proyecto alineado con SKILLS_CATALOG (42 IDs)
- [ ] `ASSETS_REGISTRY` creado
- [ ] Sin implementación nueva fuera de las HU/RC vigentes (R4 es lo único en curso)

---

## 5. Notas

- El **GDD es la fuente de verdad**: si el dev detecta desvíos entre código y docs, reportarlo (no corregir en silencio).
- Licencias: todo asset real que se incorpore (R8+) pasa por el `ASSETS_REGISTRY` (fuente, autor, licencia).