# Backlog de Historias de Usuario — Baking From Scratch

Todas las HUs deben seguir estrictamente la plantilla oficial [../../HU-TEMPLATE.md](../../HU-TEMPLATE.md), con criterios de aceptación verificables en formato Gherkin.

## Orden de Prioridad (Vertical Slice -> MVP Etapa 1)

### Fase 0: Vertical Slice (Core Loop Jugable)
| ID | Título propuesto | Estado | Dependencias |
| :--- | :--- | :--- | :--- |
| `HU-01` | Escenario base Etapa 1 (Patio y Cocina) + estado inicial y HUD económico | Pendiente de redacción | Ninguna |
| `HU-02` | Recepción presencial de encargos (1 piso) y reputación básica | Pendiente de redacción | `HU-01` |
| `HU-03` | Inventario de insumos, compra de reposición y dosificación por receta | Pendiente de redacción | `HU-01` |
| `HU-04` | Estación de horneado inicial (1 piso, tiempos de cocción) | Pendiente de redacción | `HU-03` |
| `HU-05` | Estación de decoración core (corte, relleno, base giratoria, manga y toppings) | Pendiente de redacción | `HU-04` |
| `HU-06` | Entrega, evaluación de calidad (100 % / Parcial / Incumplido) y flujo de caja | Pendiente de redacción | `HU-02`, `HU-05` |

### Fase 1: MVP Completo (Etapa 1)
| ID | Título propuesto | Estado | Dependencias |
| :--- | :--- | :--- | :--- |
| `HU-07` | Sistema de deuda del horno, intereses periódicos y recargos por mora | Pendiente de redacción | `HU-06` |
| `HU-08` | Averías mecánicas del horno y costos operativos | Pendiente de redacción | `HU-07` |
| `HU-09` | Terminal RRSS: publicación de creaciones, reseñas y encargos digitales | Pendiente de redacción | `HU-06` |
| `HU-10` | Mecánica de estafas financieras en encargos de RRSS | Pendiente de redacción | `HU-09` |
| `HU-11` | Progresión de Expertise, Marketing y hito de Horno Industrial (incl. salto Robux) | Pendiente de redacción | `HU-07`, `HU-09` |
| `HU-12` | Persistencia de partida (`DataStore`) y sistema de localización (`en` base + `es`) | Pendiente de redacción | `HU-01`..`HU-11` |
