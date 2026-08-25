---
# Plantilla Estándar de Historia de Usuario (HU)


## HU-[Número]: [Título de la Historia de Usuario]

**Proyecto:** [Nombre del Proyecto, ej: Corcoran ventas mobile / Corcoran Config Web]  
**Épica:** [Nombre de la Épica, ej: Checkout / Autenticación / Registro]  
**Prioridad:** [Crítica / Alta / Media / Baja]  

---

### **Narrativa (INVEST)**

**Como** [Rol del usuario o actor del sistema],  
**quiero** [acción o funcionalidad deseada],  
**para** [beneficio o valor que aporta al negocio].

---

### **Descripción del Requerimiento / Contexto**

[Explicación breve del problema a resolver, antecedente del cambio o lógica
funcional general.]

---

### **Especificaciones Técnicas / Contratos de API**

_(Opcional / Si aplica)_

#### **Endpoint: [Nombre de la Integración]**

- **Ruta y Método:** `[GET / POST / PUT / DELETE]` - `/api/v1/ejemplo`
- **Acceso / Seguridad:** [Autenticado / Público]
- **Parámetros (Query / Path / Headers):**
  - `parametro_1` (tipo - Obligatorio/Opcional): Descripción.
- **Payload / Response (JSON):**
  ```json
  {
    "campo_1": "valor",
    "campo_2": 123
  }
  ```

```

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: [Nombre del escenario principal]**

* **GIVEN** [Dado que ocurre una condición o estado inicial].
* **WHEN** [Cuando el usuario realiza una acción específica].
* **THEN** [Entonces el sistema debe responder de esta forma].
* **AND** [Y además se debe cumplir este comportamiento adicional].

#### **Escenario 2: [Nombre del escenario alternativo o de error]**

* **GIVEN** [Dado un estado o condición de fallo].
* **WHEN** [Cuando el usuario ejecuta la acción].
* **THEN** [Entonces el sistema muestra este mensaje o control de error].

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **[Punto 1]:** [Instrucciones de diseño, estados de botones, colores o componentes visuales].
* **[Punto 2]:** [Reglas de oro, transformaciones de texto o validaciones locales].

---

### **Definition of Done (DoD)**

* [ ] [Criterio técnico o funcional comprobable 1]
* [ ] [Criterio técnico o funcional comprobable 2]
* [ ] [Pruebas unitarias/QA aprobadas]

```

```

```
