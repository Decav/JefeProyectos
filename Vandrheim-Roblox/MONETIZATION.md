# MONETIZATION.md — catálogo de monetización de Vandrheim (actualizado 2026-10-19)

**Principios:** nada de pay-to-win (sin stats, gear con poder ni boosts que rompan balance/XP). Solo **conveniencia + cosmética**. Precios vigentes de Fase 1 aprobados por el PO el 2026-10-19; reemplazan los valores iniciales registrados el 2026-10-12.
**Modelo (decisión PO 2026-10-12): TODO DEV PRODUCT, sin Game Passes** — modelo PLEX/Bond (HU-ECONOMIA-04): la compra con Robux crea un grant idempotente en el **buzón de la cuenta**; el jugador reclama el token en un personaje existente y lo **canjea** por el perk permanente o lo **vende por oro** (tradeo/subasta) — los F2P acceden sin pagar.

---

## FASE 1 — con sistemas existentes

### 1. Revivir en Mazmorra — Dev Product · 49 R$

- **Nombre en Dashboard:** `Vandrheim Token - Revivir en Mazmorra` (producto de revive; no es una de las cuatro fichas de ECON-04).
- **Estado:** implementado (R6.28). **ProductId `3717359753`. Precio actual: 49 R$.**
- Revive al instante con 0 resurrecciones gratis restantes (conveniencia acotada a la run).

### 2. Pase: Tercer Personaje — Dev Product · 149 R$

- **Estado:** Developer Product creado; implementación del token pendiente (HU-ECONOMIA-04/HU-R2.1). **ProductId `3718622291`. Sin Game Pass.**
- **Nombre en Dashboard:** `Vandrheim Token - Tercer slot de personaje` (aplica al token `token_slot3`).
- **Ámbito del canje:** cuenta completa (el slot adicional se comparte entre sus PJs).
- **Descripción en tienda:**
  > Desbloquea una tercera ranura de personaje **para siempre**. Canjea la ficha y crea un tercer aventurero sin borrar a los que ya tienes: prueba otra clase, otra spec, otra historia. ¿No la quieres usar? Véndela por oro en la subasta. (El juego se completa con 2 personajes.)
- Canje: `perks.slot3 = true` → `maxSlots = 3`.

### 3. Pase: Mochila Ampliada — Dev Product · 99 R$

- **Estado:** Developer Product creado; implementación del token pendiente (HU-ECONOMIA-04). **ProductId `3720053583`.**
- **Nombre en Dashboard:** `Vandrheim Token - Mochila ampliada` (aplica al token `token_bag`).
- **Descripción en tienda:**
  > +10 espacios permanentes en la mochila de este personaje (de 20 a 30). Canjea la ficha con el aventurero al que quieras ampliar la bolsa y lleva más botín por run. ¿No la quieres usar? Véndela por oro en la subasta.
- **Ámbito del canje:** solo el personaje que canjea la ficha; se necesita otra ficha para ampliar la mochila de otro PJ.
- Canje: `perks.bagPlus10 = true` → `bagSlots = 30` en el perfil de ese personaje (reusa sistema de bolsa).

### 4. Pase: Subasta Ampliada — Dev Product · 79 R$

- **Estado:** Developer Product creado; implementación del token pendiente (HU-ECONOMIA-04; **requiere ECON-02 implementada** para activar el perk). **ProductId `3720054258`.**
- **Nombre en Dashboard:** `Vandrheim Token - Mejora de subasta` (aplica al token `token_auction`).
- **Ámbito del canje:** cuenta (`UserId`), de acuerdo con el límite de anuncios por jugador de ECON-02.
- **Descripción en tienda:**
  > Publica hasta 20 anuncios a la vez en la subasta global (en vez de 10). Canjea la ficha y vende más a la vez, con más oro circulando. ¿No la quieres usar? Véndela por oro en la subasta.
- Canje: `perks.auctionPlus10 = true` → `maxListings = 20` (reusa `AuctionConfig`).

### 5. Pergamino de Renombre — Dev Product · 49 R$

- **Estado:** Developer Product creado; implementación del token pendiente (HU-ECONOMIA-04). **ProductId `3720053841`.**
- **Nombre en Dashboard:** `Vandrheim Token - Renombrar personaje` (aplica al token `token_rename`).
- **Ámbito del canje:** solo el personaje cuyo flujo de cambio de nombre se completa.
- **Descripción en tienda:**
  > Cambia el nombre de tu personaje cuando quieras (con las reglas de nombres del juego). Canjea el pergamino y elige tu nuevo nombre. ¿No lo quieres usar? Véndelo por oro en la subasta.
- Canje: abre el flujo de cambio de nombre (validación R2) y se consume al aplicar.

---

## FASE 2 — requieren sistemas nuevos (post-MVP, en evaluación)

| Producto | Tipo | Notas |
|----------|------|-------|
| Transmog / skins de sets (solo visual) | Dev Product + token | Requiere sistema de transmog (no existe) |
| Mascotas cosméticas (acompañan, sin stats) | Dev Product + token | Requiere sistema de mascotas (no existe) |
| Títulos, colores de nombre, auras, emotes | Dev Product + token | Requiere sistema cosmético (no existe) |

## Ingreso pasivo

- **Premium Payouts:** activar en el Dashboard (Roblox paga por tiempo de juego de usuarios Premium; $0 esfuerzo). Tarea de publicación.

## Assets pendientes (diseñador)

- **Icono de tienda 512×512 por cada token** (slot 3, mochila, subasta, renombre). Fondo transparente (estándar vigente).

---

## Historial

| Fecha | Cambio |
|-------|--------|
| 2026-10-12 | Creación del catálogo: 5 productos Fase 1 (revive 50 · slot 3 299 · mochila +10 199 · subasta +10 149 · nombre 99) + Fase 2 en evaluación + Premium Payouts; descripción de tienda del pase de slot 3 |
| 2026-10-12 | **Todo Dev Product, sin Game Passes (modelo PLEX/Bond, HU-ECONOMIA-04):** los 4 perks van por **token** (`token_slot3`/`token_bag`/`token_auction`/`token_rename`) — compra Robux o compra con oro → canje permanente o venta; R2.1 migrada a token |
| 2026-10-19 | **IDs y precios confirmados por el PO:** revive 3717359753/49 R$; `token_slot3` 3718622291/149 R$; `token_bag` 3720053583/99 R$; `token_auction` 3720054258/79 R$; `token_rename` 3720053841/49 R$. Los productos ya existen en el Dashboard; la implementación de tokens sigue pendiente |
