# Preguntas Abiertas y Decisiones Pendientes (Open Questions)

Este documento registra las ambigüedades detectadas en el GDD inicial. Ningún agente debe inventar respuestas en silencio: las decisiones aquí listadas cuentan con un **default propuesto** que aplica mientras no se indique lo contrario.

---

## 1. Decisiones Bloqueantes Resueltas

### OQ-01: Nombre oficial del proyecto y carpeta
- **Estado:** Resuelta (2026-11-14).
- **Decisión:** **Baking From Scratch** (carpeta del proyecto: `Baking-From-Scratch/`).

### OQ-02: Modelo de servidor / multijugador en Roblox
- **Estado:** Resuelta (2026-11-14).
- **Decisión:** **Single-player** (1 jugador por instancia/servidor en Modo Diario y Modo Creativo).
- **Impacto:** Simplifica la replicación de físicas/decoración de pasteles y evita conflictos de parcelas. El futuro **Modo Competitivo** (Fase 3) se resolverá mediante *leaderboards* globales/contrarreloj o teletransporte a salas de duelo dedicadas.

### OQ-03: Stack y flujo de desarrollo en Roblox
- **Estado:** Resuelta (2026-11-14).
- **Decisión:** **Roblox Studio vía MCP** (construcción y edición directa en el `.rbxl` mediante herramientas MCP de Studio, sin sincronización externa por Rojo).
- **Impacto:** Las futuras especificaciones (`SpecAgent`) y entregas (`BuilderAgent`) deben contemplar estructura de instancias dentro de Studio (`ReplicatedStorage`, `ServerScriptService`, `StarterPlayerScripts`, `StarterGui`, `Workspace`).

---

## 2. Decisiones Secundarias (Resueltas y Con Default Propuesto)

### OQ-04: Idioma principal del juego (Audiencia Roblox)
- **Estado:** Resuelta (2026-11-14).
- **Decisión:** **Inglés (`en`) como idioma base de UI y textos dentro del juego**, con arquitectura preparada mediante tabla de localización (`LocalizationTable` o módulo i18n) para traducir a español (`es`) y otros idiomas.
- **Nota:** La documentación interna del proyecto (`GDD.md`, `ROADMAP.md`, `HUs/`) se mantiene en español para el equipo. Los hashtags y términos regionales del GDD original (*manjar*, *#Pyme*) se adaptarán al inglés en el copy base (ej. *dulce de leche / caramel*, `#SmallBusiness`, `#SelfMade`) conservando su equivalente cultural en la traducción al español.

### OQ-05: Nombre de la moneda y escala numérica inicial
- **Default propuesto:** Moneda ficticia simple (`$` / *Pesos* o *Monedas*) con valores enteros pequeños en Etapa 1 (ej. ahorro inicial `$0` tras comprar insumos, deuda inicial del horno `$500`, pastel básico `$40-$70`) para facilitar lectura rápida en pantalla.

### OQ-06: Evaluación matemática de la Decoración (Paso 3)
- **Ambigüedad:** El GDD indica propina proporcional a la precisión y reseñas por calidad, pero no define cómo se puntúa la decoración libre (corte, cobertura, manga pastelera, toppings).
- **Default propuesto:** Puntaje compuesto por 4 criterios objetivos (0-100 %):
  1. Coincidencia de sabor de bizcocho y relleno (obligatorio).
  2. Cobertura aplicada (porcentaje de superficie cubierta en base giratoria).
  3. Coincidencia de color/boquilla y presencia de trazado de manga.
  4. Cantidad y ubicación válida de toppings solicitados (velas/frutas dentro del área del pastel).

### OQ-07: Verificación de comprobantes falsos (Estafas RRSS)
- **Ambigüedad:** Se menciona que los estafadores envían comprobantes falsos y ofertan pagos muy altos por pedidos sencillos, pero no cómo los detecta el jugador.
- **Default propuesto:** Mini-inspección visual en el terminal de RRSS al revisar el pedido: el comprobante tiene pistas detectables (ej. nombre del titular distinto, monto que no coincide, fecha alterada o estado "Pendiente/Rechazado" con tipografía irregular) + botón `Aceptar Pago` vs `Rechazar por Fraude`.

### OQ-08: Ciclo de tiempo del "Modo Diario" e intereses de deuda
- **Default propuesto:** Ciclo de día/noche acelerado (ej. 1 día de juego = 5 minutos reales). Los intereses de deuda y costos fijos se calculan al cierre de cada día si no se abonó el mínimo diario.
