## HU-R5.1: Talentos v2 — árbol WoW + ventana de habilidades (reajuste de R5)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Progresión / Talentos / R5.1 (reajuste del sistema implementado en
R5)  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-22)  
**Fase GDD:** R5 (reemplaza el sistema de talentos de R5; vendors/economía de R5
quedan intactos)  
**Depende de:** R5 (oro/respec base), R3 (loadout/skills), SKILLS_CATALOG v2

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** aprender habilidades de mi spec a medida que subo de nivel y a través
de un **árbol de talentos tipo WoW** (con ramas, prerequisitos y gates por
puntos y nivel), y poder armar mi barra desde una ventana de habilidades,  
**para** tener builds con progresión real y decisiones significativas que se
puedan corregir con respec.

---

### **Descripción del Requerimiento / Contexto**

Reajuste del sistema de talentos implementado en R5 (6 nodos planos sin prereqs)
a un **árbol WoW**: 3 ramas, prerequisitos en cadena, gates por puntos
invertidos y por nivel, nodos que **enseñan skills**, y **ventana de
habilidades** (spellbook) para armar la barra de 4.

Además cambia el modelo de skills (SKILLS_CATALOG v2): **2 básicas + 2 por
nivel + 2 por talento** por spec.

**No rehace** vendors, oro ni el costo de respec (R5 se mantiene).

---

### **Especificaciones Técnicas / Contratos de API**

#### **Nuevo modelo de skills (SKILLS_CATALOG v2)**

| Capa            | Obtención                             | Cantidad |
| --------------- | ------------------------------------- | -------- |
| Básica de clase | Automática (lvl 1)                    | 2        |
| Nivel (spec)    | Automática lvl 1 y lvl 5              | 2        |
| Talento (spec)  | Nodo del árbol (1 medio + 1 profundo) | 2        |

- Al aprender una skill por talento → aparece en la **ventana de habilidades** y
  puede asignarse a la barra.
- **Respec revoca las skills de talento** (hay que volver a tomarlas); las de
  nivel se conservan.
- Spec única activa; no mezclar skills de ambas specs (GDD).

#### **TalentConfig v2 (ReplicatedStorage/Config — data-driven)**

```luau
{
  ["Paladin_Protector"] = {
    specId = "Paladin_Protector",
    branches = {
      ["vida"] = {
        name = "Vida/Defensa",
        nodes = {
          { id="fortaleza", name="Fortaleza", type="Passive", maxRank=2,
            levelReq=2, prereqs={}, pointsRequired=0,
            perRank={ MaxHPMult=0.05 } },
          { id="sacred_wall", name="Muro sagrado", type="Skill", skillId="paladin_prot_sacred_wall",
            maxRank=1, levelReq=8, prereqs={"fortaleza"}, pointsRequired=4 },
          { id="unbreakable_faith", name="Fe inquebrantable", type="Passive", maxRank=1,
            levelReq=16, prereqs={"sacred_wall"}, pointsRequired=8,
            perRank={ CooldownReduction=0.04 } },
        },
      },
      -- ...ramas "amenaza" y "utilidad"
    },
  },
  -- ...resto de specs (nodos genéricos hasta R8; solo Protector con contenido final)
}
```

- **Ramas:** 3 por spec (ej. Protector: Vida/Defensa, Amenaza, Utilidad).
- **Prereqs directos:** `prereqs` = nodos anteriores con ≥1 rank.
- **Gates:** `pointsRequired` (4 tier 2, 8 capstone) + `levelReq` (8 / 16).
- **Tipos de nodo:** `Passive` (efectos de stats) | `Skill` (enseña `skillId`).
- **Ranks:** maxRank 2; capstone rank 1.

#### **Lógica de gasto (server)**

- Puntos: `floor(nivel/2)` (1 cada 2 niveles; ~10 a lvl 20).
- Primer punto → elige spec (como R5).
- `RequestSpendTalentPoint{nodeId}` valida: spec activa, puntos disponibles,
  `prereqs` (≥1 rank), `pointsRequired` (total invertido en el árbol),
  `levelReq`, rank < maxRank.
- `RequestRespec` (R5): devuelve todos los puntos + revoca skills de talento (se
  quitan del spellbook/loadout); oro + spec (opcional) como R5.

#### **Ventana de habilidades (spellbook)**

- Lista de skills **aprendidas**: básicas + spec (nivel + talento).
- Asignar/desasignar a los **4 slots de la barra** (reemplaza/amplía el loadout
  UI de R3).
- Las skills de talento aparecen al aprenderlas; al respec, desaparecen (y se
  quitan de la barra si estaban).

#### **UI del árbol de talentos**

- 3 ramas visibles; nodos con estado: **bloqueado / desbloqueable / aprendido
  (rank)**.
- **Conexiones visuales** entre nodos (líneas de prerequisito).
- Tooltip: efecto por rank, requisitos faltantes (prereq, puntos, nivel).
- Botón **Respec** (confirmación + costo oro R5).
- Ventana con cursor normal (pausa drag de cámara R3.1).

#### **Remotes**

| Remote                            | Dir | Payload                   | Validación server                                |
| --------------------------------- | --- | ------------------------- | ------------------------------------------------ |
| `RequestTalentTree`               | C→S | —                         | Estado del árbol del PJ                          |
| `RequestSpendTalentPoint`         | C→S | `{ nodeId }`              | Spec, puntos, prereqs, gates, rank               |
| `RequestRespec`                   | C→S | `{ newSpecId? }`          | Pueblo, oro suficiente; revoca skills de talento |
| `RequestAssignBarSlot`            | C→S | `{ slotIndex, skillId? }` | Skill aprendida y de su spec                     |
| (R3 existente) `RequestCastSkill` | C→S | —                         | Solo skills en la barra (aprendidas)             |

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Árbol con 3 ramas**

- **GIVEN** un PJ con spec elegida
- **WHEN** abre la ventana de talentos
- **THEN** ve 3 ramas con nodos y sus conexiones
- **AND** cada nodo muestra estado (bloqueado/desbloqueable/aprendido)

#### **Escenario 2: Prerequisito directo**

- **GIVEN** un nodo con prerequisito (nodo anterior de la rama)
- **WHEN** el prerequisito no tiene ningún rank
- **THEN** el nodo está bloqueado (no se puede gastar punto)
- **AND** el tooltip indica el requisito

#### **Escenario 3: Gate por puntos en el árbol**

- **GIVEN** un nodo tier 2 con `pointsRequired=4`
- **WHEN** el jugador tiene < 4 puntos invertidos en el árbol
- **THEN** el nodo está bloqueado
- **AND** al llegar a 4+ puntos invertidos (con prereqs y nivel OK) se
  desbloquea

#### **Escenario 4: Gate por nivel**

- **GIVEN** un nodo con `levelReq=8`
- **WHEN** el nivel del PJ es menor
- **THEN** el nodo está bloqueado indicando el nivel requerido

#### **Escenario 5: Nodo skill enseña la habilidad**

- **GIVEN** un nodo tipo `Skill` (ej. Muro sagrado)
- **WHEN** el jugador gasta el punto y aprende el nodo
- **THEN** la skill aparece en la **ventana de habilidades**
- **AND** puede asignarse a la barra y castearse (R3)

#### **Escenario 6: Ranks y capstone**

- **GIVEN** un nodo con maxRank 2
- **WHEN** se invierten 2 puntos
- **THEN** llega a rank 2 y deja de aceptar puntos
- **AND** un capstone (rank 1) solo acepta 1 punto

#### **Escenario 7: Respec revoca skills de talento**

- **GIVEN** un PJ con skills aprendidas por talento
- **WHEN** hace respec (paga oro, R5)
- **THEN** todos los puntos se devuelven
- **AND** las skills de talento desaparecen del spellbook y de la barra
- **AND** las skills de nivel y básicas se conservan

#### **Escenario 8: Ventana de habilidades arma la barra**

- **GIVEN** un PJ con skills aprendidas
- **WHEN** abre la ventana de habilidades y asigna slots
- **THEN** la barra de 4 muestra la selección
- **AND** el cast usa la skill asignada (R3)

#### **Escenario 9: Skills por nivel**

- **GIVEN** un PJ de spec X
- **WHEN** alcanza lvl 1 y lvl 5
- **THEN** aprende las 2 skills por nivel de su spec automáticamente
- **AND** aparecen en el spellbook (nunca se revocan)

#### **Escenario 10: Anti-exploit y estabilidad**

- **GIVEN** un cliente intenta gastar puntos sin prereqs/gates, asignar skills
  no aprendidas o castear skills fuera de la barra
- **WHEN** solo manipula estado local
- **THEN** el server rechaza
- **AND** el flujo árbol → aprender → asignar barra → respec no produce errores
  rojos

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

- **Árbol:** 3 ramas con conexiones; estados visibles
  (bloqueado/desbloqueable/aprendido + rank).
- **Tooltip de nodo:** efecto por rank + requisitos faltantes (prereq, puntos,
  nivel).
- **Spellbook:** lista de aprendidas; clic asigna/desasigna slots; skills de
  talento con marca.
- **Respec:** confirmación fuerte (costo oro, revoca skills de talento).
- **Ventanas (árbol/spellbook):** pausan drag de cámara (R3.1); cursor normal.
- PC primero; móvil básico (Scale).

---

### **Alcance**

#### Incluye

- TalentConfig v2 (3 ramas, prereqs, pointsRequired, levelReq, nodos
  Passive/Skill)
- Lógica de gasto con gates (server)
- Ventana de habilidades (spellbook) + asignación a la barra (reemplaza loadout
  R3)
- Skills aprendidas por nivel (lvl 1 y 5) y por talento (SKILLS_CATALOG v2)
- Respec revoca skills de talento (mantiene oro/costo R5)
- UI del árbol (ramas, conexiones, estados, tooltips)
- Contenido final de nodos: **Paladín Protector**; resto genérico hasta R8

#### No incluye

- Vendors / oro / economía (R5 se mantiene)
- Contenido final de nodos de las otras 5 specs (R8)
- Más skills de las definidas en SKILLS_CATALOG v2 (30)
- Prerequisitos múltiples complejos / builds duales (post-MVP)
- Reforjar árboles por spec con más ramas (post-MVP)

---

### **Definition of Done (DoD)**

- [ ] Árbol 3 ramas con prereqs, gates por puntos y nivel (funciona en server)
- [ ] Nodos Skill enseñan skills → aparecen en spellbook → asignables a la barra
- [ ] Skills por nivel (lvl 1/5) se aprenden solas y nunca se revocan
- [ ] Respec devuelve puntos, revoca skills de talento y quita de la barra
- [ ] Ventana de habilidades reemplaza loadout y funciona con R3
- [ ] UI del árbol con conexiones, estados y tooltips
- [ ] Cliente no puede saltar gates ni castear skills no aprendidas
- [ ] Sin errores rojos en el flujo completo
- [ ] Nota "R5.1 completo" en GDD

---

### **Checklist Studio (referencia dev)**

- [ ] TalentConfig v2 (3 ramas × nodos; Protector con contenido final)
- [ ] Server: validación de prereqs/points/level + gasto de puntos
- [ ] Nodos Skill → aprendizaje + spellbook + asignación de barra
- [ ] Skills por nivel (lvl 1/5) automáticas
- [ ] Respec: devuelve puntos + revoca talent-skills (oro/spec de R5)
- [ ] UI árbol (ramas, conexiones, estados, tooltip) + spellbook
- [ ] Compatibilidad con R3 (cast solo skills aprendidas y en barra)
- [ ] Anti-exploit + sin errores

---

### **Decisiones por defecto R5.1 (si no se cambian)**

| Tema               | Default                                                  |
| ------------------ | -------------------------------------------------------- |
| Skills por nivel   | lvl 1 y lvl 5 (spec)                                     |
| Skills por talento | 1 nodo tier 2 + 1 nodo profundo (capstone) por spec      |
| Árbol              | 3 ramas × ~3 nodos; prereqs directos                     |
| Gates              | tier 2: ≥4 puntos + lvl 8 · capstone: ≥8 puntos + lvl 16 |
| Ranks              | maxRank 2; capstone 1                                    |
| Respec             | Oro R5 (100); revoca talent-skills                       |
| Contenido nodos    | Final solo Paladín Protector; resto genérico hasta R8    |

---

### **Estimación (orientativa)**

3–5 sesiones (árbol + gates + spellbook + integración con R3/R5).

---

### **Historial**

| Fecha      | Cambio                                                                                                |
| ---------- | ----------------------------------------------------------------------------------------------------- |
| 2026-08-12 | Creación HU-R5.1: árbol WoW + ventana de habilidades + modelo v2 de skills (reemplaza talentos de R5) |
| 2026-08-22 | Marcada completada según reporte del equipo |
