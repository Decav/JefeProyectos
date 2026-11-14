# Documento de Diseño de Videojuego (GDD) — Baking From Scratch

**Nombre del proyecto:** Baking From Scratch  
**Plataforma:** Roblox (Single-player en Modo Diario; integración directa en Studio vía MCP)  
**Género:** Simulación de gestión gastronómica, economía y decoración interactiva  
**Idioma base in-game:** Inglés (`en`), con soporte de localización multi-idioma (español y otros)  
**Versión:** 1.2 (Definiciones técnicas y de idioma base confirmadas)  
**Estado:** Canónico para Fase 0 / MVP (restan defaults no bloqueantes en [OPEN_QUESTIONS.md](./OPEN_QUESTIONS.md))

---

## 1. Visión General y Pilares

El proyecto simula la trayectoria completa de un emprendedor repostero en Roblox: desde operar en condiciones precarias dentro de la propiedad familiar, con capital agotado y endeudamiento inicial, hasta consolidar una pastelería comercial de gran escala.

### Pilares de Experiencia

1. **Tensión económica real desde el minuto cero:** Insumos limitados, deuda activa con intereses y riesgo de fraude financiero.
2. **Decoración táctil como núcleo jugable:** El ensamblaje, corte, relleno, cobertura y trazado libre con manga pastelera constituyen la mecánica principal de diversión y diferenciación.
3. **Progresión física y digital:** Crecimiento paralelo entre equipamiento/local (patio/cocina hacia cadena comercial) y marca digital (redes sociales, reseñas y clientela VIP).

---

## 2. Modos de Juego

| Modo | Descripción | Rol en el Producto |
| :--- | :--- | :--- |
| **Modo Diario (Historia)** | Modo principal. Progresión completa desde cero con gestión de deuda, inventario, atención de encargos, redes sociales y expansión del negocio. | Modo principal / Core del MVP |
| **Modo Creativo** | Espacio libre para hornear y decorar pasteles sin restricciones de insumos, tiempo ni costos financieros. | Secundario (post-MVP propuesto) |
| **Modo Competitivo** | Desafíos contra reloj o entre jugadores evaluando velocidad, precisión de decoración y satisfacción del cliente. | Secundario (post-MVP propuesto) |

---

## 3. Modo Diario: Etapa 1 — Inicio del Emprendimiento

### 3.1 Contexto Narrativo Inicial

1. El jugador invierte la totalidad de sus ahorros para iniciar su emprendimiento sin conocimientos técnicos previos ni local comercial.
2. **Infraestructura precaria:** Recolecta cajas y tablas de madera de la basura para montar un puesto improvisado en el patio familiar.
3. **Agotamiento de capital:** Los ahorros iniciales se consumen en insumos básicos y utensilios menores (`-$$$`).
4. **Endeudamiento obligatorio:** Adquiere un crédito inicial para comprar el horno más pequeño y económico disponible (`-$$$`).

### 3.2 Estado Inicial del Jugador

| Parámetro | Condición Inicial | Impacto Jugable |
| :--- | :--- | :--- |
| **Insumos** | Estrictamente limitados | Requiere reposición constante y planificación |
| **Capacidad de horneado** | Solo pasteles de 1 piso (pequeños / 5 personas) | Limita los tipos de pedidos aceptables |
| **Velocidad de trabajo** | Tiempo de elaboración prolongado | Alta probabilidad de acumular retrasos |
| **Clientela** | Red cercana (familiares, vecinas, amigas de la madre) | Flujo bajo de ingresos por encargo |
| **Posicionamiento de marca** | `#SoyMiPropioJefe`, `#Emprendedor`, `#Pyme` | Marca personal en etapa germinal |

---

## 4. Arquitectura del Espacio (Etapa 1)

En la fase inicial, la operación se divide en dos zonas dentro de la propiedad familiar:

### 4.1 Sitio de Atención y Entrega (Patio de la casa)
- Atención presencial de clientes y cobro de pedidos.
- Punto de entrega de productos terminados.
- Compra y reposición de materia prima.
- Terminal de administración de Redes Sociales (RRSS) y recepción de encargos digitales.

### 4.2 Sitio de Preparación (Cocina interior)
- Consulta y ejecución de recetas.
- Control de tiempos de horneado.
- Mesa de ensamblaje, decoración y embalaje final.

---

## 5. Core Loop y Flujo Operativo

```text
[ Recepción del Encargo ] -> [ Dosificación e Ingredientes ] -> [ Horneado, Ensamblaje y Decoración ] -> [ Entrega, Cobro y Reseña ]
```

### Paso 1: Recepción del Encargo (Patio / RRSS)
- **Decisión:** Aceptar o Rechazar el pedido.
- **Parámetros del encargo:** Sabor del bizcocho, tamaño/cantidad de pisos, paleta de colores y detalles de decoración.
- **Regla de reputación:** Rechazar encargos de forma continua reduce la puntuación general del negocio.

### Paso 2: Dosificación e Ingredientes
- Interfaz interactiva con botones ágiles que muestran la receta requerida y el stock disponible en tiempo real.
- **Insumos base de referencia:** Manjar (`u`), Huevos, Azúcar (`kg`), Harina (`kg`), Chocolate, Vainilla.
- El uso de cada ingrediente descuenta automáticamente las existencias del inventario general.

### Paso 3: Preparación y Decoración (Mecánica Core)
Constituye el núcleo principal de entretenimiento y se divide en tres subfases:
1. **Corte del bizcocho:** Control manual del cuchillo para realizar cortes horizontales por capas.
2. **Relleno y apilado:** Uso de espátula para aplicar rellenos según stock disponible (*Chocolate*, *Manjar*, *Durazno*, *Mora*) y apilar capas.
3. **Cobertura y acabados:**
   - **Cubrimiento:** Rotación de base giratoria mientras se alisa/aplica crema con espátula.
   - **Manga pastelera:** Selección de boquillas/duyas y trazado libre sobre la superficie del pastel.
   - **Toppings finales:** Arrastre y posicionamiento de velas (estándar o numéricas) y frutas frescas (piña, guindas, entre otras).

**Balance de etapa temprana:** La escasez de insumos impide satisfacer el 100 % de los requerimientos en los primeros encargos, manteniendo márgenes de ganancia reducidos pero progresivos.

### Paso 4: Entrega, Valoración, RRSS y Fraude

#### Evaluación de Entrega
| Resultado | Efecto Económico |
| :--- | :--- |
| **Pedido Cumplido (100 %)** | Pago total del pedido (`$$`) más propina proporcional a la precisión. |
| **Pedido Parcial** | Ingresos reducidos o mínimos (`+$ / -$`). |
| **Pedido Incumplido** | Pérdida del costo de insumos (`-$$`) más reembolso obligatorio al cliente. |

#### Sistema de Reseñas y Marketing Digital (RRSS)
- El jugador administra perfiles digitales, fotografía sus creaciones y las publica para atraer audiencia y encargos.
- Algunos clientes publican reseñas en RRSS con puntuación por estrellas y foto del producto entregado (ej. *"Marta — 2/5 estrellas: La decoración era bonita, pero encontré un pelo en el relleno."*).
- El desarrollo de técnicas de decoración incrementa el alcance de marketing; descubrir y dominar recetas aumenta el *expertise* general.

#### Mecánica de Estafas Financieras (Solo RRSS)
- En pedidos originados por Redes Sociales existe riesgo de fraude mediante **comprobantes de transferencia falsos**.
- **Indicador de riesgo:** Ofertas de pago desproporcionadamente altas para pedidos sencillos actúan como señal de alerta.
- **Penalización:** Aceptar un comprobante falso implica pérdida total de insumos utilizados (`-$$$`) y ganancia `$0`.

---

## 6. Economía y Sistema de Deuda

### 6.1 Deuda del Horno e Intereses
- El jugador comienza con una deuda activa por el horno inicial.
- Si no genera ingresos constantes para amortizarla, el saldo adeudado aumenta automáticamente un porcentaje (`%`) en intervalos fijos de tiempo (ej. cada 5 minutos o por ciclo diario de juego).
- La acumulación de mora y recargos bloquea o retrasa la transición hacia un local comercial independiente.

### 6.2 Factores de Riesgo que Incrementan la Deuda
- Capital insuficiente para cubrir reembolsos por pedidos fallidos.
- Falta de liquidez para reponer insumos básicos.
- Averías mecánicas del horno que exigen reparación de emergencia o sustitución.
- Incapacidad para cubrir el costo operativo del espacio de trabajo.

---

## 7. Progresión y Escalabilidad a Largo Plazo

### 7.1 Evolución del Negocio

```text
[ Puesto Improvisado (Patio) ] -> [ Arriendo de Local ] -> [ Expansión de Planta ] -> [ Cadena / Pastelería Grande ]
```

- **Transición a Local Comercial:** Adquisición de contrato de arriendo (`-$$` operativo periódico), habilitando expansiones físicas.
- **Escalabilidad de Plantilla:** Contratación múltiple para elevar la producción por minuto.
- **Cadena de Suministro:** Acceso a insumos de alta calidad que incrementan el valor final del producto.
- **Clientela VIP y Alta Dificultad:** Encargos con mayor cantidad de pisos, complejidad estructural y exigencia decorativa.

### 7.2 Catálogo de Mejoras

| Mejora / Recurso | Función | Notas de Reglas / Monetización |
| :--- | :--- | :--- |
| **Hornos Industriales** | Hito principal de progresión que determina la fase de desarrollo del negocio. | Incluye opción de desbloqueo/salto anticipado mediante **Robux**. |
| **Personal de Recepción** | Automatiza atención al cliente y cobros. | Costo operativo periódico (`-$$`). |
| **Personal de Mezcla** | Automatiza la preparación de masa base. | Costo operativo periódico (`-$$`). |
| **Mejora de Expertise** | Capacitaciones permanentes para reducir el tiempo de elaboración. | Progresión de habilidad del jugador. |
| **Refrigerador Comercial** | Permite almacenar bizcochos pre-horneados. | **Mecánica de perecederos:** si permanece almacenado en exceso, se descompone y queda inservible (aparición de moscas). |

---

## 8. Historial de Cambios del GDD

| Fecha | Versión | Autor | Resumen |
| :--- | :--- | :--- | :--- |
| 2026-11-14 | 1.0 | PM Agent | Estructuración inicial del GDD base aportado por el usuario sin alterar el alcance original. |
| 2026-11-14 | 1.1 | PM Agent | Se fija **Baking From Scratch** como nombre oficial del proyecto (OQ-01 resuelta). |
| 2026-11-14 | 1.2 | PM Agent | Se confirma modelo **single-player** (OQ-02), flujo en **Roblox Studio vía MCP** (OQ-03) e idioma base in-game en **inglés con localización** (OQ-04). |
