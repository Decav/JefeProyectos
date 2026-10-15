# MONETIZATION.md — catálogo de monetización de Vandrheim (decisión PO 2026-10-12)

**Principios:** nada de pay-to-win (sin stats, gear con poder ni boosts que rompan balance/XP). Solo **conveniencia + cosmética**. Consumibles baratos (50–100 R$), permanentes medios (150–300 R$).
**Modelo (decisión PO 2026-10-12): TODO DEV PRODUCT, sin Game Passes** — modelo PLEX/Bond (HU-ECONOMIA-04): la compra con Robux otorga un **token** (Dev Product repetible) que se **canjea** por el perk permanente o se **vende por oro** (tradeo/subasta) — los F2P acceden sin pagar.

---

## FASE 1 — con sistemas existentes

### 1. Revivir en Mazmorra — Dev Product · 50 R$

- **Estado:** implementado (R6.28). **ProductId `3717359753`.**
- Revive al instante con 0 resurrecciones gratis restantes (conveniencia acotada a la run).

### 2. Pase: Tercer Personaje — Dev Product · 299 R$ (precio a confirmar)

- **Estado:** HU-R2.1 (vía token `token_slot3`, HU-ECONOMIA-04); pendiente ID del Dev Product del PO. **Sin Game Pass.**
- **Nombre en tienda:** `Tercer Personaje` (aplica al token).
- **Descripción en tienda:**
  > Desbloquea una tercera ranura de personaje **para siempre**. Canjea la ficha y crea un tercer aventurero sin borrar a los que ya tienes: prueba otra clase, otra spec, otra historia. ¿No la quieres usar? Véndela por oro en la subasta. (El juego se completa con 2 personajes.)
- Canje: `perks.slot3 = true` → `maxSlots = 3`.

### 3. Pase: Mochila Ampliada — Dev Product · 199 R$

- **Estado:** HU pendiente (crear).
- **Nombre en tienda:** `Mochila Ampliada` (aplica al token `token_bag`).
- **Descripción en tienda:**
  > +10 espacios permanentes en tu mochila (de 20 a 30). Canjea la ficha y lleva más botín por run, menos viajes al vendedor. ¿No la quieres usar? Véndela por oro en la subasta.
- Canje: `perks.bagPlus10 = true` → `bagSlots = 30` (reusa sistema de bolsa).

### 4. Pase: Subasta Ampliada — Dev Product · 149 R$

- **Estado:** HU pendiente (crear; **requiere ECON-02 implementada** — se activa con la economía).
- **Nombre en tienda:** `Puesto de Subasta Ampliado` (aplica al token `token_auction`).
- **Descripción en tienda:**
  > Publica hasta 20 anuncios a la vez en la subasta global (en vez de 10). Canjea la ficha y vende más a la vez, con más oro circulando. ¿No la quieres usar? Véndela por oro en la subasta.
- Canje: `perks.auctionPlus10 = true` → `maxListings = 20` (reusa `AuctionConfig`).

### 5. Pergamino de Renombre — Dev Product · 99 R$

- **Estado:** HU pendiente (crear).
- **Nombre en tienda:** `Cambio de Nombre` (aplica al token `token_rename`).
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