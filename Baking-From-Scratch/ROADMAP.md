# Roadmap de Producto (Propuesta PM)

Este documento define el corte de alcance por fases para proteger el **MVP** contra el *scope creep* y asegurar que el **core loop de decoración y gestión** funcione antes de escalar a modos secundarios o automatización avanzada.

---

## Principios de Priorización Aplicados

1. **Vertical Slice primero:** Un ciclo completo jugable (recibir pedido -> preparar/decorar -> entregar -> cobrar/amortizar deuda) antes de construir sistemas de expansión.
2. **Core Loop antes que modos paralelos:** El **Modo Diario (Etapa 1)** valida el juego. **Modo Creativo** y **Modo Competitivo** quedan fuera del MVP inicial.
3. **Economía con integridad:** El servidor (o estado autoritativo) debe validar inventario, saldos, deuda y pagos para evitar exploits en Roblox antes de introducir Robux o rankings.

---

## Fase 0: Definición y Vertical Slice (Pre-MVP)

**Objetivo:** Validar la sensación táctil de decoración y el bucle básico de pedido -> entrega en Etapa 1 (solo 1 piso, red cercana, patio + cocina).

**Incluye (IN):**
- Entorno mínimo de Etapa 1: Patio (puesto improvisado + compra de insumos) y Cocina (horno inicial + mesa de preparación).
- Recepción de pedido presencial simple (1 piso, sabores básicos).
- Inventario de insumos con descuento real al preparar.
- Prototipo jugable de Decoración (corte, relleno, cobertura en base giratoria, manga pastelera básica, toppings).
- Evaluación simple de entrega (Cumplido / Parcial / Incumplido) y flujo de caja básico.

**Excluye (OUT):**
- Redes sociales, fotos y estafas.
- Averías del horno, refrigerador, contratación de personal.
- Arriendo de local comercial.
- Modo Creativo, Modo Competitivo y compras con Robux.

---

## Fase 1: MVP Jugable — Etapa 1 Completa (Modo Diario)

**Objetivo:** Experiencia completa de emprendedor inicial con tensión financiera, reputación y canal digital.

**Incluye (IN):**
- Sistema completo de Deuda del Horno (intereses por intervalo, pago/amortización, recargos y bloqueo de avance por mora).
- Averías mecánicas del horno y costos operativos básicos.
- Terminal de Redes Sociales (publicación básica de creaciones, reseñas con estrellas, encargos digitales).
- Mecánica de Estafas Financieras en RRSS (detección visual/lógica de comprobante falso vs verdadero).
- Progresión de *Expertise* y *Marketing* (desbloqueo de recetas/técnicas y mejora de velocidad).
- Hito de salida de Etapa 1: compra/desbloqueo de Horno Industrial (incluyendo opción de salto con Robux si se define monetización en esta fase).
- Persistencia de partida (`DataStore` en Roblox).

**Excluye (OUT):**
- Arriendo de local comercial independiente y expansión física.
- Contratación de empleados (recepción / mezcla).
- Refrigerador comercial y perecederos.
- Modos Creativo y Competitivo.

---

## Fase 2: Expansión del Negocio (Post-MVP 1)

**Objetivo:** Transición de puesto doméstico a local comercial y gestión de escala.

**Incluye (IN):**
- Transición a Local Comercial mediante contrato de arriendo periódico.
- Refrigerador comercial con mecánica de perecederos (descomposición/moscas).
- Contratación de personal de recepción y mezcla (con costos periódicos).
- Pasteles multipiso, clientela VIP y cadena de suministro de alta calidad.
- Expansión física de planta y múltiples estaciones de trabajo.

---

## Fase 3: Modos Secundarios y Competencia (Post-MVP 2)

**Objetivo:** Retención a largo plazo y rejugabilidad social en Roblox.

**Incluye (IN):**
- **Modo Creativo:** Sandbox sin límite de insumos ni economía.
- **Modo Competitivo:** Desafíos cronometrados / PvP de velocidad, precisión decorativa y satisfacción.
- Cadena / franquicia de pastelerías.
