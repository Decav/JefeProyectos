## HU-ESTETICA-05: Arco del Cazador — modelo 3D + integración como ítem

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Assets / Ítems / EST-05  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Tipo:** Item de prueba para el Cazador (modelo + integración)  
**Fase GDD:** Épica transversal `EST-05` (paralela a R8b; no bloquea la implementación del Cazador)  
**Rol A — Diseñador:** crea el modelo 3D del arco (solo modelos, sin scripts).  
**Rol B — Dev:** integra el modelo como ítem (config + wiring visual), usando el pipeline de EST-01.  
**Depende de:** HU-ESTETICA-01 (pipeline de equipamiento visual R15), HU-R4 (ItemConfig/inventario), HU-R5 (debug grant), HU-R8b (Cazador en implementación)

---

### **Narrativa (INVEST)**

**Como** jugador de Cazador,  
**quiero** poder equipar un arco que se vea en el personaje y aporte stats,  
**para** probar la build de Puntería (ranged) en Play Solo.

**Como** equipo,  
**quiero** validar el flujo completo "modelo del diseñador → config del dev → equipado visible y funcional",  
**para** confirmar que el pipeline de EST-01 funciona con una clase nueva.

---

### **Descripción del Requerimiento / Contexto**

El Cazador (R8b) se está implementando, pero no tiene arma visual de prueba: las skills ranged existen, pero no hay un arco equipable. Esta HU entrega el **primer ítem visual de otra clase** usando el pipeline ya construido:

1. **Diseñador:** modelo 3D `hunter_bow` (arco nórdico de cazador) en la estructura estándar.
2. **Dev:** entrada en `ItemConfig`, wiring visual (EST-01), icono pendiente (Gemini), inclusión en debug grant y loot de prueba.

El pipeline visual de EST-01 ya está implementado: el dev solo agrega el modelo y la config.

---

### **Especificaciones Técnicas / Contratos**

#### **Parte A — Diseñador (modelo 3D)**

* Crear el modelo **`hunter_bow`** en `ReplicatedStorage.Assets.Models.Equipment.Hunter`.
* Estética: arco nórdico de cazador — madera oscura curvada, refuerzos de cuero/hierro, cuerda tensa; paleta Vandrheim (madera, acero frío, cuero).
* Estructura compatible con el pipeline de EST-01:
  * Model con `PrimaryPart` (o Handle) y attachments para la mano.
  * Arco = arma visual 2H simplificada: se une a la mano principal (sin IK de dos manos, igual que el espadón del Paladín).
  * `Anchored=false`, piezas decorativas `CanCollide=false`/`CanTouch=false`/`CanQuery=false`/`Massless=true`.
  * **Sin scripts**, sin sonidos, sin partículas.
* Entregar con notas: nombre, ubicación, attachment/offset sugerido.

#### **Parte B — Dev (integración como ítem)**

**ItemConfig — entrada nueva:**

```luau
["hunter_bow"] = {
  name = "Arco del cazador",
  slot = "MainHand",
  stackable = false,
  maxStack = 1,
  rarity = "Common",
  levelReq = 1,
  stats = { ATK = { base = 7, roll = 2 } },
  affixes = {},
  weaponAffinity = { "Hunter_Assault", "Hunter_Punteria" },
  unique = false,
  iconId = "rbxassetid://0",        -- pendiente: icono Gemini (Icon_Item_bow)
  visualModelId = "hunter_bow",
  visualType = "HandModel",
  attachTo = "RightHand",
  description = "Un arco de madera y cuero para el cazador.",
}
```

* `visualModelId`/`visualType`/`attachTo`: ya soportados por EST-01; el arco debe aparecer en la mano al equipar.
* `weaponAffinity`: Puntería y Asalto (bonus, no hard-lock — GDD).
* **Debug grant (R5):** agregar `hunter_bow` a la lista de `GrantItem` del cliente (tecla G) para probarlo en Studio.
* **Loot de prueba:** agregar `hunter_bow` a `dummy_test` (y opcionalmente `floor_1`) con peso bajo, para probar el drop.
* Icono: queda `rbxassetid://0` hasta que se suba el PNG de Gemini (reemplazo por config, ASSETS_POLICY).

#### **Integración visual (EST-01)**

* Al equipar: el modelo se une a `RightHand` y sigue al personaje en idle/walk/run/combate.
* Al desequipar/reemplazar: el visual anterior se limpia (sin duplicados).
* Reconstrucción al spawn/respawn/rejoin (pipeline existente).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Modelo entregado**

* **GIVEN** el diseñador entrega `hunter_bow`
* **WHEN** se inspecciona `ReplicatedStorage.Assets.Models.Equipment.Hunter`
* **THEN** existe el modelo con estructura válida y sin scripts

#### **Escenario 2: Ítem configurado**

* **GIVEN** `hunter_bow` en `ItemConfig`
* **WHEN** se revisa la entrada
* **THEN** tiene slot, stats, levelReq, affinity y `visualModelId` correctos

#### **Escenario 3: Equipar en un Cazador**

* **GIVEN** un Cazador con el arco en la bolsa
* **WHEN** lo equipa
* **THEN** el arco aparece en la mano derecha
* **AND** las stats del PJ se recalculan (ATK)
* **AND** el tooltip muestra nombre/stats/rareza

#### **Escenario 4: Affinity**

* **GIVEN** un Puntería o Asalto equipa el arco
* **WHEN** se recalculan stats
* **THEN** aplica el bonus de afinidad (+10%)
* **AND** otra clase lo equipa sin bonus (no hard-lock)

#### **Escenario 5: Desequipar/limpiar**

* **GIVEN** el arco equipado
* **WHEN** se desequipa o se reemplaza
* **THEN** el visual desaparece
* **AND** no quedan modelos duplicados

#### **Escenario 6: Persistencia**

* **GIVEN** un Cazador con el arco equipado
* **WHEN** respawnea o vuelve a entrar
* **THEN** el arco sigue equipado y visible

#### **Escenario 7: Debug grant**

* **GIVEN** el juego en Studio
* **WHEN** se usa la tecla G para grant
* **THEN** `hunter_bow` aparece en la bolsa del Cazador

#### **Escenario 8: Sin errores**

* **GIVEN** el flujo completo
* **WHEN** se revisa el output
* **THEN** no hay errores rojos en equipar → moverse → combatir → respawn

---

### **Alcance**

#### Incluye

* Modelo 3D `hunter_bow` (diseñador).
* Entrada `hunter_bow` en `ItemConfig` (dev).
* Wiring visual con EST-01 (dev).
* Debug grant + loot de prueba (dev).
* Icono pendiente documentado (`Icon_Item_bow` para Gemini).

#### No incluye

* Animaciones de arco (R6.6 ya reproduce por skillType; sin animación especial de arco en esta HU).
* Proyectiles especiales (VFX de R6.8/R8b ya cubre).
* IK de dos manos para el arco.
* Balance de stats del arco (R8d).
* Modelos de armas para otras clases en esta HU.

---

### **Definition of Done (DoD)**

* [ ] `hunter_bow` existe como modelo en Equipment/Hunter (sin scripts).
* [ ] `ItemConfig.hunter_bow` con slot/stats/affinity/visualModelId.
* [ ] Al equipar en un Cazador, el arco se ve en la mano y aplica stats.
* [ ] Desequipar/reemplazar limpia el visual; persiste en respawn/rejoin.
* [ ] GrantItem (tecla G) y `dummy_test` incluyen el arco.
* [ ] Sin errores rojos en el flujo de prueba.
* [ ] Icono `Icon_Item_bow` pendiente en ASSETS_LIST (Gemini).
* [ ] Nota `EST-05 completo` en GDD tras verificar.

---

### **Estimación (orientativa)**

Diseñador: 1 sesión (modelo de arco). Dev: 1 sesión (config + wiring + test).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-ESTETICA-05: arco del Cazador (modelo del diseñador + integración del dev con el pipeline EST-01) |