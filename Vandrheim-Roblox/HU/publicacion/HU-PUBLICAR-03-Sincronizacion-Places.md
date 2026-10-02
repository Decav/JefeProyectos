# HU-PUBLICAR-03: Sincronización de places (hub ↔ Dungeon_Helada) — fix inicial + proceso permanente

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Publicación / Ops (dev)
**Prioridad:** Alta (bug reportado en producción limitada)
**Estado:** Lista para implementar
**Tipo:** Mantenimiento cross-place + proceso (dev)
**Fase GDD:** Publicación (transversal)
**Depende de:** HU-PUBLICAR-02 (bootstrap del place dungeon), SKILLS_CATALOG v2.3 (Flecha venenosa/DoT), todo lo implementado desde el bootstrap del place
**Componentes observados:** `ReplicatedStorage.Config` (SkillConfig, ItemConfig, TalentConfig, EnemyConfig, LootTables, VFXConfig…), `ServerScriptService.Services` (SkillService con DoT, DungeonService, FloorService…), remotes, `StarterGui`/clientes (HUD, grimorio…), en ambos places

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que todo lo que tengo y sé en el pueblo (skills, ítems, UI) funcione igual al entrar a la dungeon,
**para** que el cambio de place sea invisible y no se me "pierdan" habilidades ni progreso.

**Como** equipo de desarrollo,
**quiero** un proceso claro para mantener **ambos places sincronizados** (el hub y `Dungeon_Helada` tienen copias independientes),
**para** que ningún cambio quede solo en uno de los dos y no vuelva a pasar.

---

### **Descripción del Requerimiento / Contexto**

**Bug reportado:** al entrar a la dungeon con el Cazador, la **Flecha venenosa desapareció** (y aplica a cualquier skill/ítem/UI agregado después del bootstrap del place).

**Causa raíz:** cada place tiene su **propio árbol** de scripts/configs/remotes/UI. El hub se actualizó (R8e: `hunter_mm_venom` en SkillConfig + SkillType `DoT` en SkillService, ITEMS-01, reskins, R6.11, etc.) pero `Dungeon_Helada` quedó con la versión del momento en que se bootstrapeó (PUBLICAR-02). El perfil viaja por DataStore (la skill está aprendida), pero la dungeon no tiene la skill en su SkillConfig ni el soporte DoT → se pierde visualmente y no castea.

Esta HU: (1) **sincroniza ahora** `Dungeon_Helada` con el hub y (2) **formaliza el proceso** para que toda implementación futura actualice ambos places.

**Criterio de hecho global:** la dungeon tiene **el mismo contenido, servicios y UI** que el hub (versiones idénticas de los módulos compartidos), el Cazador conserva la Flecha venenosa al entrar, y cada RC futuro incluye la sincronización en su DoD.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Sync inicial (fix del bug, ahora)**

Sincronizar en `Dungeon_Helada` todo lo que el hub tiene y la dungeon no (o tiene viejo). **Estrategia elegida (decisión PM 2026-09-22): copia completa del place — NO sync manual módulo por módulo.** El trabajo del dev se reduce a:

1. **Copiar el place:** guardar el hub y publicarlo **como** `Dungeon_Helada` (`File → Save As → Publish to existing place`). El place queda **idéntico al hub** (configs, servicios, remotes, UI, todo).
2. **Flag de tipo de place:** agregar `DungeonConfig.placeType = "dungeon"` (vs `"hub"`): en la dungeon el arranque **no** muestra selección de PJ/pueblo ni hub flow; arranca directo con `JoinRun` (piso 1, seed del teleport data). En el hub el comportamiento actual no cambia.
3. **Verificar publicado:** Cazador con Flecha venenosa → dungeon → skill presente y casteando; el flujo de la dungeon (pisos, HUD dungeon, exit/abandon) igual que antes.
4. **Contenido del hub presente pero inactivo en la dungeon** (vendors, pueblo, selección de PJ): bloat aceptable en MVP; no se usa por el flag de placeType (limpieza posterior si molesta).

**Verificación (checklist, ya no como trabajo manual):** al publicar, comparar que la dungeon es la copia del hub (versión del place) y probar el flujo cruzado.

#### **2. Proceso permanente (regla dura para todo RC futuro)**

* **Regla:** el desarrollo vive en el **hub**; al publicar, `Dungeon_Helada` se actualiza **copiando el place completo** (Save As → Publish to existing place). **No hay sync manual por módulo.**
* **Checklist de publicación (cada release):** (1) publicar hub, (2) publicar el mismo archivo como `Dungeon_Helada`, (3) verificar `placeType` en la dungeon, (4) probar publicado el flujo cruzado (hub → dungeon) afectado.
* Si el cambio es **solo de la dungeon** (ej. layout específico), se hace después de la copia y se documenta (se pierde al siguiente release — aceptado si es cosmético).
* **Recomendación estructural (opcional, decisión del dev):** migrar el proyecto a **Rojo** (código fuente único en archivos → ambos places se construyen del mismo src). Es la solución definitiva al problema de divergencia; con la copia completa del place ya no es urgente. Evaluar en una decisión aparte; no es requisito de esta HU.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Bug corregido**

* **GIVEN** un Cazador Puntería con Flecha venenosa aprendida
* **WHEN** entra por el portal a la dungeon
* **THEN** la skill está en su grimorio/barra y castea (DoT funcionando)
* **AND** ningún ítem/skill/UI del hub se pierde al cruzar de place

#### **Escenario 2: Configs sincronizados**

* **GIVEN** el sync inicial aplicado
* **WHEN** se comparan los módulos compartidos hub ↔ dungeon
* **THEN** SkillConfig/ItemConfig/TalentConfig/EnemyConfig/LootTables/VFXConfig/Services/remotes/UI coinciden (versiones idénticas)

#### **Escenario 3: Proceso permanente**

* **GIVEN** un RC futuro que toca módulos compartidos
* **WHEN** se revisa su DoD
* **THEN** incluye el ítem "Sync places" con la lista de módulos y la verificación publicada
* **AND** los cambios solo de hub/dungeon lo declaran explícitamente

#### **Escenario 4: Regresión cross-place**

* **GIVEN** la dungeon sincronizada
* **WHEN** se juega el flujo completo (hub → dungeon → hub, publicado)
* **THEN** no hay errores rojos y el comportamiento es idéntico al hub (skills, ítems, UI, HUD)

---

### **Comportamiento Visual / Reglas de Negocio**

* Es mantenimiento/proceso: no cambia gameplay, balance ni contenido.
* La fuente de verdad de cada módulo compartido es el **hub** (o el src único si se adopta Rojo).
* El proceso se aplica desde esta HU en adelante (los RCs ya cerrados no se reabren; se validan en el sync inicial).

---

### **Alcance**

#### Incluye

* Sync inicial completo de `Dungeon_Helada` contra el hub (configs, servicios, remotes, UI).
* Fix verificado del bug (Flecha venenosa en dungeon, DoT casteando).
* Regla "Sync places" en el DoD de los RC futuros + checklist de sync.
* Verificación publicada del flujo cruzado.

#### No incluye

* Migración a Rojo (decisión aparte del dev; opcional).
* Cambios de gameplay, balance ni contenido.
* Reabrir RCs ya cerrados.

---

### **Definition of Done (DoD)**

* [ ] `Dungeon_Helada` sincronizado con el hub (configs/servicios/remotes/UI idénticos en los módulos compartidos).
* [ ] Bug verificado publicado: Cazador conserva Flecha venenosa en la dungeon y castea DoT.
* [ ] Flujo cross-place sin errores rojos (skills, ítems, UI, HUD idénticos).
* [ ] Regla "Sync places" documentada para los RC futuros (lista de módulos + verificación).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: nota en GDD después de QA.

---

### **Decisiones por defecto PUBLICAR-03**

| Tema | Default |
|------|---------|
| Sync | **Copia completa del place** (hub → Dungeon_Helada al publicar); sin sync manual por módulo |
| Diferenciación | `DungeonConfig.placeType = "hub"/"dungeon"` (arranque distinto, mismo código) |
| Publicación | Publicar hub → publicar el mismo archivo como dungeon → verificar placeType → probar cruzado |
| Cambios solo dungeon | Permitidos tras la copia; se pierden en el siguiente release (aceptado si cosmético) |
| Rojo | Opcional/decisión aparte (ya no urgente con la copia del place) |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: sync inicial + fix verificado + proceso documentado.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-PUBLICAR-03: sincronización de places — fix del bug (Flecha venenosa ausente en la dungeon por configs desactualizadas), sync inicial hub ↔ Dungeon_Helada, y regla permanente "Sync places" en el DoD de los RC futuros; Rojo como solución estructural opcional |
| 2026-09-22 | **Cambio de estrategia (decisión PM):** el sync es **copia completa del place** (publicar el hub como Dungeon_Helada al release) + flag `placeType` para el arranque — se elimina el sync manual por módulo; la checklist queda solo como verificación de publicación |