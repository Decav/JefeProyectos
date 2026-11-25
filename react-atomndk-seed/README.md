# React Atomic NDK Seed

Semilla oficial para proyectos frontend del ecosistema ACL Chile. Implementa la arquitectura **NDK React** con **Specification-Driven Development (SDD)** y asistencia de **Claude Code**.

**Stack:** React 19 · TypeScript 5.9 · Vite 8 · React Router 7 · TanStack Query 5 · Zustand 5 · Axios · React Hook Form · Zod 4 · PrimeReact 10 · Tailwind 4 · Vitest 4 · Playwright · MSW 2 · Sentry · Storybook 10

---

## Quick Start

```bash
# 1. Clonar
git clone <repo-url> mi-proyecto
cd mi-proyecto

# 2. Instalar deps y preparar .env
npm install
cp .env.example .env

# 3. Inicializar MSW (Service Worker para mocks)
npm run msw:init

# 4. (Opcional) Playwright para E2E
npx playwright install

# 5. Desarrollo
npm run dev
```

Abre [http://localhost:5151](http://localhost:5151)

Requisitos: Node.js >= 22.

---

## Desarrollo con Claude Code

Este seed está optimizado para trabajar con agentes (Claude Code, Cursor, Codex). Las reglas viven en [`AGENTS.md`](AGENTS.md) (`CLAUDE.md` apunta a él) y los datos propios de cada proyecto en [`PROJECT.md`](PROJECT.md).

```bash
# Abrir Claude Code en el proyecto
cd mi-proyecto
claude
```

### Flujo SDD — cómo se trabaja aquí

```
1. Crear RC  →  definir Requirement Contract (.claude/requirements/rc-YYYYMMDD-HHmm-<slug>.md)
2. Aprobar   →  Líder técnico revisa y aprueba
3. Implementar → Claude lee el RC y genera el código
4. Validar   →  Tests pasan + criterios del RC cumplidos
```

> **Sin RC aprobado, no hay implementación.** Claude lo bloqueará.

Plantilla de RC: [`.claude/requirements/TEMPLATE.frontend.md`](.claude/requirements/TEMPLATE.frontend.md) · Flujo completo: [`.claude/requirements/README.md`](.claude/requirements/README.md)

---

## Arquitectura NDK

Cuatro capas con dependencias estrictamente unidireccionales:

```
modules    ←  lógica de negocio + UI por dominio
   ↑
library    ←  integración HTTP, repositorios, mocks
   ↑
global     ←  componentes y utils reutilizables
   ↑
resources  ←  contratos puros (tipos, enums, schemas)
```

| Capa | Alias | Puede importar de |
|------|-------|------------------|
| `resources` | `@resources` | Nada |
| `global` | `@global` | `@resources` |
| `library` | `@library` | `@global`, `@resources` |
| `modules` | `@modules` | `@library`, `@global`, `@resources` |

### Atomic Design NDK

Los componentes usan prefijos numéricos visibles en el nombre del archivo:

| Prefijo | Nivel | Cuándo usarlo |
|---------|-------|---------------|
| `q1` | Átomo | Elemento mínimo sin lógica de negocio |
| `q2` | Molécula | Combinación de 2-3 átomos |
| `q3` | Célula | Estado local complejo |
| `q4` | Organismo | Lógica de negocio completa (formularios, tablas) |
| `q5` | Ecosistema | Guard, layout o flujo multi-pantalla |
| `pa` | Página | Destino de ruta React Router |

---

## Estructura del proyecto

```
react-atomndk-seed/
│
├── src/
│   ├── app/                        # Entry point + router + providers
│   ├── resources/                  # Capa 1: contratos puros
│   ├── global/                     # Capa 2: componentes reutilizables
│   ├── library/                    # Capa 3: integración HTTP, OIDC y mocks
│   │   ├── api/                    # backendApi + interceptores (token, refresh, error)
│   │   └── oidc/                   # oidc-spa v10: useAuthStatus, useLogoutMutation
│   └── modules/                    # Capa 4: lógica de negocio
│       ├── login/                  # Vista /login
│       └── callback/               # Vista /callback (post-OIDC)
│
├── e2e/                            # Tests end-to-end (Playwright)
├── .claude/                        # Skills, agentes, requirements (RCs)
├── AGENTS.md                       # Reglas para agentes (fuente de verdad)
├── CLAUDE.md                       # Puntero a AGENTS.md para Claude Code
├── PROJECT.md                      # Ficha del proyecto (datos a rellenar)
└── .env.example                    # Variables de entorno de ejemplo
```

---

## Comandos

```bash
# Desarrollo
npm run dev             # Servidor en http://localhost:5151
npm run build           # Build de producción
npm run preview         # Preview del build

# Tests
npm run test            # Vitest en modo watch
npm run test:ui         # Vitest con UI gráfica
npm run test:coverage   # Reporte de cobertura
npm run test:e2e        # Playwright end-to-end
npm run test:e2e:ui     # Playwright con UI gráfica

# Calidad
npm run lint            # ESLint
npx tsc --noEmit        # Type-check

# Storybook
npm run storybook       # Design system en http://localhost:6006

# Mocks
npm run msw:init        # Regenera el Service Worker de MSW
```

---

## Variables de entorno

Copia `.env.example` a `.env` y configura los valores:

| Variable | Obligatoria | Descripción |
|----------|-------------|-------------|
| `VITE_OIDC_ISSUER_URI` | sí | URI del emisor OIDC (Authentik). Debe terminar en `/`. |
| `VITE_OIDC_CLIENT_ID` | sí | Client ID registrado en Authentik. |
| `VITE_OIDC_PUBLIC_URL` | sí | URL pública de la app (base del callback OIDC). |
| `VITE_API_URL` | opcional | Base del backend propio consumido por `backendApi`. |
| `VITE_SENTRY_DSN` | opcional | DSN de Sentry (vacío deshabilita). |
| `VITE_ENABLE_MOCKS` | opcional | `true` arranca MSW en el navegador (solo en desarrollo). |

---

## Para Líderes Técnicos

### Crear un proyecto desde esta semilla

```bash
# 1. Clone la semilla
git clone <seed-url> mi-proyecto
cd mi-proyecto

# 2. Reinicializar git para historial propio
rm -rf .git && git init && git add . && git commit -m "chore: initial import from react-atomndk-seed"

# 3. Configurar .env para el entorno del proyecto
cp .env.example .env

# 4. Instalar e iniciar
npm install
npm run dev

# 5. Rellenar PROJECT.md (o pedirle al agente que ejecute la skill project-bootstrap)
# 6. Crear el primer RC siguiendo .claude/requirements/PROMPT.create.md
```

### Reglas que NO se pueden cambiar sin aprobación de Arquitectura

- Estructura de capas NDK (`resources/global/library/modules`)
- Stack de librerías autorizado
- Sistema de Atomic Design (q1-q5, pa)
- Patrones canónicos (Component → Hook → Repository → backendApi; Service solo con lógica de negocio real)
- Configuración base de TypeScript (strict: true)
