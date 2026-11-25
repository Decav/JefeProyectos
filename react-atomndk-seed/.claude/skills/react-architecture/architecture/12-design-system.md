# ACL Design System — Estándar de Diseño

**Versión:** 1.0
**Stack:** React 19 · PrimeReact 10.9.7 (tema base `lara-light-indigo` + overrides en `theme.css`) · Tailwind CSS 4.2.2 · Poppins (Google Fonts, default de la semilla)

> **Estructura fija, valores por proyecto.** La **estructura** de este design system es parte de la arquitectura y no cambia entre proyectos sin ADR: tokens CSS `--acl-*` en `src/styles/theme.css`, clases utilitarias `.acl-*` (`.acl-card`, `.acl-badge-*`, `.acl-btn-*`, `.acl-kpi-card`, etc.), overrides de PrimeReact vía CSS variables y dark mode por `data-theme` (con fallback a `prefers-color-scheme`). Los **valores de marca** citados en este documento (`#E31D4A`, `#5135A1`, gradiente, fuente Poppins, logos en `public/`) son los **defaults de la semilla ACL**: cada proyecto los reemplaza con los de `PROJECT.md` (sección 5, Marca) al crearse. El prefijo `--acl-` se mantiene en todos los proyectos para que los componentes de la semilla sigan funcionando.

---

## 1. Introducción y Filosofía

El ACL Design System define el lenguaje visual unificado para todos los proyectos creados desde la semilla. Su objetivo es garantizar consistencia visual, eficiencia de desarrollo y mantenibilidad a largo plazo.

### Principios

1. **Variables primero:** Todos los valores de diseño (colores, radios, sombras) viven como CSS custom properties en `theme.css`. Ningún valor se hardcodea en componentes.
2. **Dark mode nativo:** El sistema soporta dark mode desde el arranque mediante el atributo `data-theme="dark"` en `<html>`. No hay dos hojas de estilo separadas.
3. **PrimeReact + Tailwind, no uno u otro:** PrimeReact provee componentes complejos (DataTable, Dialog, Calendar). Tailwind provee utilidades de layout, spacing y flexbox. Las clases ACL (`acl-*`) puentes el gap.
4. **Accesibilidad obligatoria:** Todos los componentes deben cumplir WCAG AA (contraste mínimo 4.5:1 en texto, 3:1 en elementos UI). Los focus states son visibles y usan el color brand.
5. **Sin magic numbers:** Spacing, radios y z-index se toman de las variables `--acl-*`. Nada de `margin: 13px` hardcodeado.
6. **Consistencia mediante clases ACL:** Para patrones recurrentes (badges, KPI cards, sidebar items) se usan las clases utility del design system, no se reinventa cada vez.

---

## 2. Tokens de Diseño

### 2.1 Colores — Brand (valores por proyecto)

| Variable CSS | Valor por defecto (semilla ACL) | Uso |
|---|---|---|
| `--acl-brand-primary` | `#E31D4A` | CTAs principales, íconos activos, highlights |
| `--acl-brand-secondary` | `#5135A1` | Elementos secundarios, botones outline |
| `--acl-brand-gradient` | `linear-gradient(90deg, #E31D4A, #d31b45)` | Botón primario, KPI card headers, topbar brand |
| `--acl-brand-primary-rgb` | `227, 29, 74` | Para `rgba(var(--acl-brand-primary-rgb), α)` |
| `--acl-brand-secondary-rgb` | `81, 53, 161` | Para `rgba(var(--acl-brand-secondary-rgb), α)` |
| `--acl-font-family` | `"Poppins", system-ui, -apple-system, sans-serif` | Tipografía base (la fuente se carga en `index.html`) |

Los colores brand **no cambian** entre light y dark mode.

**Al personalizar un proyecto** (valores de `PROJECT.md` → Marca): además de los tokens de esta tabla, `theme.css` repite hoy el hex/RGB del primario y secundario en otros tokens y overrides (`--acl-sidebar-active`, `--acl-border-focus`, `--acl-shadow-brand`, `--acl-info*`, `--acl-pink*`, la escala `--p-primary-*`, `--primary-color`, `--p-focus-ring-*`, `--focus-ring`, `--highlight-bg` y algunas reglas de componentes). Buscar y reemplazar todas las apariciones, tanto en `:root` como en los bloques dark. Recalcular también la tabla de contraste de la sección 11.1.

### 2.2 Colores — Sidebar (siempre dark)

| Variable CSS | Valor | Uso |
|---|---|---|
| `--acl-sidebar-bg` | `#1F1D2C` | Fondo principal del sidebar |
| `--acl-sidebar-bg2` | `#2A2840` | Secciones/grupos dentro del sidebar |
| `--acl-sidebar-bg3` | `#343250` | Hover secundario, separadores |
| `--acl-sidebar-text` | `#E2E0F0` | Texto de items activos |
| `--acl-sidebar-text-muted` | `#9B98B8` | Texto de items inactivos |
| `--acl-sidebar-active` | `rgba(227,29,74,0.18)` | Background del item activo |
| `--acl-sidebar-hover` | `rgba(255,255,255,0.06)` | Hover sobre items |
| `--acl-sidebar-border` | `rgba(255,255,255,0.06)` | Separador entre sidebar y main |
| `--acl-sidebar-width` | `280px` | Ancho fijo del sidebar |

### 2.3 Colores — Surface y Card (adaptan en dark)

| Variable CSS | Light | Dark | Uso |
|---|---|---|---|
| `--acl-surface` | `#F9FAFB` | `#13111E` | Fondo del área de contenido principal |
| `--acl-surface-alt` | `#F3F4F6` | `#1A1828` | Fondos alternativos, cebrado de tabla |
| `--acl-card` | `#FFFFFF` | `#1F1D2C` | Fondo de cards, dialogs, dropdowns |
| `--acl-card-hover` | `#FAFAFA` | `#252338` | Hover sobre cards interactivas |
| `--acl-topbar-bg` | `#FFFFFF` | `#1F1D2C` | Fondo del topbar |

### 2.4 Colores — Texto (adaptan en dark)

| Variable CSS | Light | Dark | Uso |
|---|---|---|---|
| `--acl-text-primary` | `#111827` | `#F3F4F6` | Texto principal, títulos |
| `--acl-text-secondary` | `#6B7280` | `#9CA3AF` | Subtítulos, labels, metadatos |
| `--acl-text-tertiary` | `#9CA3AF` | `#6B7280` | Placeholders, texto deshabilitado |
| `--acl-text-disabled` | `#D1D5DB` | `#4B5563` | Elementos deshabilitados |
| `--acl-text-inverse` | `#FFFFFF` | `#111827` | Texto sobre fondos oscuros/claros |
| `--acl-text-on-brand` | `#FFFFFF` | `#FFFFFF` | Texto sobre gradiente brand |

### 2.5 Colores — Bordes (adaptan en dark)

| Variable CSS | Light | Dark | Uso |
|---|---|---|---|
| `--acl-border` | `#E5E7EB` | `rgba(255,255,255,0.08)` | Bordes generales, separadores |
| `--acl-border-strong` | `#D1D5DB` | `rgba(255,255,255,0.14)` | Bordes de inputs, cards enfatizadas |
| `--acl-border-focus` | `#E31D4A` | `#E31D4A` | Borde en estado focus |

### 2.6 Colores — Semánticos

#### Success (Verde)
| Variable | Light | Dark |
|---|---|---|
| `--acl-success` | `#059669` | `#10B981` |
| `--acl-success-bg` | `#ECFDF5` | `rgba(5,150,105,0.15)` |
| `--acl-success-border` | `#A7F3D0` | `rgba(5,150,105,0.3)` |
| `--acl-success-text` | `#065F46` | `#6EE7B7` |

#### Warning (Ámbar)
| Variable | Light | Dark |
|---|---|---|
| `--acl-warning` | `#D97706` | `#FBBF24` |
| `--acl-warning-bg` | `#FFFBEB` | `rgba(217,119,6,0.15)` |
| `--acl-warning-border` | `#FCD34D` | `rgba(217,119,6,0.3)` |
| `--acl-warning-text` | `#92400E` | `#FCD34D` |

#### Danger (Rojo)
| Variable | Light | Dark |
|---|---|---|
| `--acl-danger` | `#DC2626` | `#F87171` |
| `--acl-danger-bg` | `#FEF2F2` | `rgba(220,38,38,0.15)` |
| `--acl-danger-border` | `#FECACA` | `rgba(220,38,38,0.3)` |
| `--acl-danger-text` | `#991B1B` | `#FCA5A5` |

#### Info (Morado)
| Variable | Light | Dark |
|---|---|---|
| `--acl-info` | `#5135A1` | `#A78BFA` |
| `--acl-info-bg` | `#EDE9FE` | `rgba(81,53,161,0.2)` |
| `--acl-info-border` | `#C4B5FD` | `rgba(81,53,161,0.35)` |
| `--acl-info-text` | `#5135A1` | `#C4B5FD` |

#### Pink (Accent brand)
| Variable | Light | Dark |
|---|---|---|
| `--acl-pink` | `#E31D4A` | `#FB7185` |
| `--acl-pink-bg` | `#FFF0F4` | `rgba(227,29,74,0.15)` |
| `--acl-pink-border` | `#FBCFE8` | `rgba(227,29,74,0.3)` |
| `--acl-pink-text` | `#C01040` | `#FDA4AF` |

### 2.7 Escala Tipográfica

| Variable | Tamaño | px | Uso |
|---|---|---|---|
| `--acl-text-xs` | `0.75rem` | 12px | Badges, labels, notas pie |
| `--acl-text-sm` | `0.875rem` | 14px | Texto de UI, inputs, tabla cells |
| `--acl-text-base` | `1rem` | 16px | Texto de párrafos, body |
| `--acl-text-lg` | `1.125rem` | 18px | Subtítulos secundarios |
| `--acl-text-xl` | `1.25rem` | 20px | Títulos de sección, card titles |
| `--acl-text-2xl` | `1.5rem` | 24px | Títulos de página |
| `--acl-text-3xl` | `1.875rem` | 30px | KPI values, números grandes |
| `--acl-text-4xl` | `2.25rem` | 36px | Hero headings |

#### Font weights

| Variable | Valor | Uso |
|---|---|---|
| `--acl-font-light` | `300` | Texto decorativo, taglines |
| `--acl-font-normal` | `400` | Texto body, párrafos |
| `--acl-font-medium` | `500` | Labels, metadatos |
| `--acl-font-semibold` | `600` | Títulos, botones, headings |
| `--acl-font-bold` | `700` | Números KPI, títulos primarios |

#### Line heights

| Variable | Valor | Uso |
|---|---|---|
| `--acl-leading-tight` | `1.25` | Headings, títulos |
| `--acl-leading-snug` | `1.375` | Subtítulos |
| `--acl-leading-normal` | `1.5` | Texto de UI |
| `--acl-leading-relaxed` | `1.625` | Párrafos largos |

### 2.8 Escala de Espaciado

| Variable | Valor | Uso |
|---|---|---|
| `--acl-spacing-1` | `4px` | Gaps internos mínimos |
| `--acl-spacing-2` | `8px` | Gap entre icono y texto |
| `--acl-spacing-3` | `12px` | Padding de items compactos |
| `--acl-spacing-4` | `16px` | Padding estándar de componentes |
| `--acl-spacing-5` | `20px` | Padding de secciones |
| `--acl-spacing-6` | `24px` | Padding de página, gap de grid |
| `--acl-spacing-8` | `32px` | Separación entre secciones |
| `--acl-spacing-10` | `40px` | Margins grandes |
| `--acl-spacing-12` | `48px` | Secciones de formulario |
| `--acl-spacing-16` | `64px` | Empty states, heroes |

### 2.9 Border Radius

| Variable | Valor | Uso |
|---|---|---|
| `--acl-radius-xs` | `4px` | Badges pequeños, tags compactos |
| `--acl-radius-sm` | `6px` | Botones pequeños, chips |
| `--acl-radius` | `8px` | Inputs, botones, elementos estándar |
| `--acl-radius-md` | `12px` | Dropdowns, popovers, menús |
| `--acl-radius-lg` | `16px` | Cards, panels, contenedores |
| `--acl-radius-xl` | `24px` | Dialogs, modales |
| `--acl-radius-2xl` | `32px` | Secciones hero, banners |
| `--acl-radius-full` | `9999px` | Badges pill, avatares, toggle |

### 2.10 Sombras

| Variable | Valor | Uso |
|---|---|---|
| `--acl-shadow-sm` | `0 1px 3px rgba(0,0,0,.08)` | Cards en reposo, inputs |
| `--acl-shadow-md` | `0 4px 16px rgba(0,0,0,.10)` | Cards en hover, dropdowns |
| `--acl-shadow-lg` | `0 8px 32px rgba(0,0,0,.12)` | Dialogs, modales, drawers |
| `--acl-shadow-brand` | `0 4px 16px rgba(227,29,74,.25)` | Botón primario en hover |

### 2.11 Z-Index Layers

| Variable | Valor | Uso |
|---|---|---|
| `--acl-z-base` | `0` | Contenido estático |
| `--acl-z-dropdown` | `10` | Dropdowns inline |
| `--acl-z-sticky` | `20` | Headers sticky de tabla |
| `--acl-z-fixed` | `30` | Topbar fijo |
| `--acl-z-sidebar` | `50` | Sidebar de navegación |
| `--acl-z-overlay` | `100` | Overlays de fondo |
| `--acl-z-modal` | `200` | Dialogs, modales, drawers |
| `--acl-z-toast` | `300` | Notificaciones toast |
| `--acl-z-tooltip` | `400` | Tooltips (siempre encima de todo) |

---

## 3. Dark / Light Mode

### 3.1 Implementación via CSS Variables

El sistema usa CSS custom properties redefinidas según el atributo `data-theme` del elemento `<html>`. Sin atributo, el tema sigue la preferencia del sistema operativo (`prefers-color-scheme`). Esto permite que todos los componentes, sin excepción, cambien de tema con un solo cambio de atributo.

```css
/* En theme.css (extracto) */
:root {
  --acl-surface: #F9FAFB;
  --acl-text-primary: #111827;
}

/* SO en dark y sin forzar light → dark automático */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --acl-surface: #13111E;
    --acl-text-primary: #F3F4F6;
  }
}

/* Forzado por la app */
[data-theme="dark"] {
  --acl-surface: #13111E;
  --acl-text-primary: #F3F4F6;
}
```

| `data-theme` en `<html>` | Resultado |
|---|---|
| (sin atributo) | Sigue al sistema operativo |
| `"dark"` | Dark forzado |
| `"light"` | Light forzado aunque el SO esté en dark |

Los componentes **no** manipulan el atributo directamente: usan `setTheme` de `useUiStore` (sección 3.2).

### 3.2 Estado del tema en `useUiStore`

No existe un hook `useTheme` ni un provider/contexto de tema. El tema vive en el store global de UI: `src/global/store/ui.store.ts`.

```ts
// src/global/store/ui.store.ts (extracto)
type Theme = 'system' | 'light' | 'dark';

function applyTheme(theme: Theme) {
  if (theme === 'system') {
    document.documentElement.removeAttribute('data-theme');
  } else {
    document.documentElement.setAttribute('data-theme', theme);
  }
}

// Estado inicial: lee localStorage('acl-theme'); si no hay valor → 'system'.
// setTheme(theme): aplica data-theme, persiste en localStorage('acl-theme') y actualiza el estado.
```

| Miembro | Tipo | Descripción |
|---|---|---|
| `theme` | `'system' \| 'light' \| 'dark'` | Tema elegido por el usuario (`'system'` = seguir al SO) |
| `setTheme(theme)` | `(theme) => void` | Aplica `data-theme` en `<html>` (o lo quita con `'system'`) y lo persiste en `localStorage` bajo la clave `acl-theme` |

El store aplica el tema guardado al crearse, así que no hace falta ningún provider en `app-providers.tsx`.

### 3.3 Toggle de tema en componentes

```tsx
import { useUiStore } from '@global/store/ui.store';

export function Q1ThemeToggle() {
  const theme = useUiStore((s) => s.theme);
  const setTheme = useUiStore((s) => s.setTheme);
  const isDark = theme === 'dark';

  return (
    <button
      className="acl-btn acl-btn-ghost"
      onClick={() => setTheme(isDark ? 'light' : 'dark')}
      aria-label={isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'}
    >
      <i className={`pi ${isDark ? 'pi-sun' : 'pi-moon'}`} aria-hidden="true" />
    </button>
  );
}
```

> `Q1ThemeToggle` es un ejemplo: la semilla no lo incluye. Con `theme === 'system'` el ejemplo asume light; si el proyecto necesita reflejar el tema efectivo del SO, leer `window.matchMedia('(prefers-color-scheme: dark)')`. Para inyectarlo en el layout, pasarlo por `topbarActions` de `Q3AppShell` (sección 13).

### 3.4 PrimeReact Dark Mode Integration

La semilla carga el tema base `lara-light-indigo` de PrimeReact (ver sección 14) y `theme.css` sobrescribe sus CSS variables. Al redefinir `--p-surface-*`, `--surface-*` y `--text-color` en los bloques dark (`[data-theme="dark"]` y `@media (prefers-color-scheme: dark)`), PrimeReact adopta automáticamente el dark theme.

Las variables clave que PrimeReact respeta (ya definidas en `theme.css`):

```css
[data-theme="dark"] {
  --surface-a: #1F1D2C;      /* fondo de componentes */
  --surface-b: #13111E;      /* fondo de la página */
  --surface-c: rgba(255,255,255,0.06);  /* hover */
  --surface-e: #1F1D2C;      /* overlay */
  --text-color: #F3F4F6;     /* texto principal */
  --text-color-secondary: #9CA3AF;
  --surface-card: #1F1D2C;   /* fondo de card */
  --surface-border: rgba(255,255,255,0.08);
}
```

---

## 4. Responsive Design

### 4.1 Breakpoints (Tailwind 4)

| Breakpoint | Min-width | Uso típico |
|---|---|---|
| `sm` | `640px` | Teléfonos landscape |
| `md` | `768px` | Tablets |
| `lg` | `1024px` | Laptops pequeñas |
| `xl` | `1280px` | Desktops |
| `2xl` | `1536px` | Pantallas grandes |

### 4.2 Estrategia Mobile-First

Todos los estilos se escriben para mobile primero y se expanden con prefijos Tailwind:

```tsx
// Correcto: mobile-first
<div className="flex flex-col gap-4 lg:flex-row lg:gap-6">

// Incorrecto: desktop-first
<div className="flex-row gap-6 max-lg:flex-col max-lg:gap-4">
```

### 4.3 Sidebar Responsive

En pantallas menores a `lg` (1024px) el sidebar fijo se oculta y la navegación se muestra en un drawer. Así lo resuelve `Q3AppShell` (`src/global/components/q3-app-shell/`, ver sección 13):

- **Desktop (`lg+`):** `<aside className="acl-sidebar hidden lg:flex flex-col">` siempre visible; el área principal se desplaza con `lg:ml-[var(--acl-sidebar-width)]`.
- **Mobile:** `Sidebar` de PrimeReact (`position="left"`, ancho 280px, fondo `var(--acl-sidebar-bg)` vía `pt`) controlado por `sidebarOpen` / `setSidebarOpen` de `useUiStore`.
- **Hamburguesa:** botón `lg:hidden` en el topbar que llama `setSidebarOpen(true)`; al navegar, el drawer se cierra con `setSidebarOpen(false)`.

```tsx
// Extracto de Q3AppShell
const sidebarOpen = useUiStore((s) => s.sidebarOpen);
const setSidebarOpen = useUiStore((s) => s.setSidebarOpen);

<aside className="acl-sidebar hidden lg:flex flex-col" data-testid="sidebar">…</aside>

<Sidebar visible={sidebarOpen} onHide={() => setSidebarOpen(false)} position="left">…</Sidebar>
```

### 4.4 Grid System

Se usa el grid de Tailwind para layouts de página (PrimeFlex no está instalado en la semilla):

```tsx
// Grid de 4 columnas en desktop, 2 en tablet, 1 en mobile
<div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
  <div className="acl-kpi-card">...</div>
  <div className="acl-kpi-card">...</div>
  <div className="acl-kpi-card">...</div>
  <div className="acl-kpi-card">...</div>
</div>
```

---

## 5. Layout Architecture

### 5.1 AppShell Pattern

La arquitectura de layout de todos los proyectos ACL sigue el patrón AppShell:

```
┌─────────────────────────────────────────────────────────────┐
│  SIDEBAR (280px, dark, fixed, z-50)                         │
│  ┌──────────┐  ┌────────────────────────────────────────┐  │
│  │  Logo    │  │  TOPBAR (64px, sticky, z-30)           │  │
│  │  ------- │  └────────────────────────────────────────┘  │
│  │  Nav     │  ┌────────────────────────────────────────┐  │
│  │  items   │  │  CONTENT AREA (flex-1, bg: --surface)  │  │
│  │  ...     │  │                                        │  │
│  │          │  │  <Outlet /> / {children}               │  │
│  │  ------- │  │                                        │  │
│  │  User    │  │                                        │  │
│  └──────────┘  └────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Implementación del Layout

La implementación de referencia es `Q3AppShell` (`src/global/components/q3-app-shell/q3-app-shell.tsx`), documentada en la sección 13. Puntos clave:

- Recibe `appName`, `navItems: NavItem[]` y `topbarActions?: ReactNode` (slot para acciones del topbar, p. ej. un toggle de tema como el de la sección 3.3).
- Lee el usuario con `useAuthStatus()` (`@global/hooks`) y cierra sesión con `useLogoutMutation()` (OIDC).
- El estado del drawer mobile vive en `useUiStore` (`sidebarOpen`), no en estado local.
- Renderiza el contenido de cada ruta con `<Outlet />` dentro de `<main className="acl-content">`.

No crear otro AppShell por proyecto: personalizar `Q3AppShell` (logo, nombre, acciones) o proponer un ADR si se necesita otro layout.

### 5.3 Variantes de Layout

| Variante | Uso | Cómo |
|---|---|---|
| Con sidebar (default) | Apps autenticadas | `Q3AppShell` como `element` padre de las rutas (sección 13.3) |
| Sin sidebar (full-width) | Login, landing pública | `<main className="min-h-screen">` sin `acl-main` |
| Sidebar colapsado | Modo compacto | Añadir clase `acl-sidebar-collapsed` al sidebar |

---

## 6. Componentes PrimeReact con Estilo ACL

### 6.1 Configuración del Preset

PrimeReact 10 se inicializa en `app-providers.tsx` con `<PrimeReactProvider>` **sin props**. El tema base `lara-light-indigo` se importa en `main.tsx` y `theme.css` sobrescribe sus CSS variables con los valores de marca (sección 14). No se pasa ningún objeto de tema al Provider.

```tsx
// src/app/providers/app-providers.tsx (extracto)
import { PrimeReactProvider } from 'primereact/api';

<PrimeReactProvider>
  {/* QueryClientProvider, Q1GlobalToast, RouterProvider */}
</PrimeReactProvider>
```

`@primereact/themes` / `definePreset` **no** está instalado en la semilla. El siguiente ejemplo solo aplica si un proyecto aprueba un ADR para un override profundo de tokens JS-level:

```ts
// src/library/theme/acl-preset.ts
import { definePreset } from '@primereact/themes';
import Aura from '@primereact/themes/aura';

export const AclPreset = definePreset(Aura, {
  semantic: {
    primary: {
      50: '#FFF0F4',
      100: '#FFD6E2',
      200: '#FFA8C0',
      300: '#F77098',
      400: '#EF4070',
      500: '#E31D4A',
      600: '#C0103A',
      700: '#9A0A2C',
      800: '#72061F',
      900: '#4C0214',
      950: '#2A0009',
    },
  },
});
```

Y usar en el provider:
```tsx
<PrimeReactProvider value={{ ripple: true, theme: { preset: AclPreset } }}>
```

### 6.2 Button

```tsx
import { Button } from 'primereact/button';

// Primario — gradiente brand (override via theme.css)
<Button label="Guardar" icon="pi pi-check" />

// Secundario — outline morado
<Button label="Cancelar" outlined severity="secondary" />

// Ghost / texto
<Button label="Ver más" text />

// Peligro
<Button label="Eliminar" severity="danger" icon="pi pi-trash" />

// Cargando
<Button label="Guardando..." loading={isPending} disabled={isPending} />

// Con clases ACL directas
<button className="acl-btn acl-btn-primary">
  <i className="pi pi-check" />
  Guardar
</button>
```

### 6.3 InputText

```tsx
import { InputText } from 'primereact/inputtext';

// Estándar
<InputText
  id="username"
  placeholder="Ingrese usuario"
  className="w-full"
  aria-label="Usuario"
/>

// Con icono izquierdo
<span className="p-input-icon-left w-full">
  <i className="pi pi-search" />
  <InputText placeholder="Buscar..." className="w-full" />
</span>

// Con error (clase p-invalid)
<InputText
  id="email"
  className={`w-full ${errors.email ? 'p-invalid' : ''}`}
  aria-describedby="email-error"
/>
{errors.email && (
  <small id="email-error" className="acl-form-error">
    <i className="pi pi-exclamation-circle" />
    {errors.email.message}
  </small>
)}
```

### 6.4 Dropdown y MultiSelect

```tsx
import { Dropdown } from 'primereact/dropdown';
import { MultiSelect } from 'primereact/multiselect';

const statusOptions = [
  { label: 'Activo', value: 'active' },
  { label: 'Inactivo', value: 'inactive' },
  { label: 'Pendiente', value: 'pending' },
];

// Dropdown simple
<Dropdown
  value={status}
  options={statusOptions}
  onChange={(e) => setStatus(e.value)}
  placeholder="Seleccionar estado"
  className="w-full"
/>

// MultiSelect con búsqueda
<MultiSelect
  value={selectedRoles}
  options={roleOptions}
  onChange={(e) => setSelectedRoles(e.value)}
  placeholder="Seleccionar roles"
  filter
  className="w-full"
  display="chip"
/>
```

### 6.5 DataTable

```tsx
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Skeleton } from 'primereact/skeleton';

interface User { id: string; name: string; email: string; status: string; }

function Q4UsersTable({ data, isLoading }: { data?: User[]; isLoading: boolean }) {
  if (isLoading) {
    return (
      <div className="acl-card">
        <div className="flex flex-col gap-3">
          <Skeleton height="3rem" borderRadius="8px" />
          {Array.from({ length: 5 }).map((_, i) => (
            <Skeleton key={i} height="3rem" borderRadius="8px" />
          ))}
        </div>
      </div>
    );
  }

  const statusBodyTemplate = (row: User) => {
    const variant = row.status === 'active' ? 'success' : row.status === 'pending' ? 'warning' : 'neutral';
    return <span className={`acl-badge acl-badge-${variant}`}>{row.status}</span>;
  };

  const actionsBodyTemplate = (row: User) => (
    <div className="flex items-center gap-2">
      <button className="acl-btn acl-btn-ghost p-1" title="Editar">
        <i className="pi pi-pencil text-sm" />
      </button>
      <button className="acl-btn acl-btn-ghost p-1 text-red-500" title="Eliminar">
        <i className="pi pi-trash text-sm" />
      </button>
    </div>
  );

  return (
    <div className="acl-card" style={{ padding: 0, overflow: 'hidden' }}>
      <DataTable
        value={data}
        dataKey="id"
        stripedRows
        paginator
        rows={10}
        rowsPerPageOptions={[10, 25, 50]}
        emptyMessage={
          <div className="acl-empty-state">
            <i className="pi pi-inbox acl-empty-state__icon" />
            <p className="acl-empty-state__title">Sin resultados</p>
            <p className="acl-empty-state__description">No se encontraron registros.</p>
          </div>
        }
      >
        <Column field="name" header="Nombre" sortable />
        <Column field="email" header="Email" sortable />
        <Column field="status" header="Estado" body={statusBodyTemplate} />
        <Column header="Acciones" body={actionsBodyTemplate} style={{ width: '8rem' }} />
      </DataTable>
    </div>
  );
}
```

### 6.6 Dialog / Drawer

```tsx
import { Dialog } from 'primereact/dialog';
import { Sidebar } from 'primereact/sidebar';

// Dialog (modal centrado)
<Dialog
  visible={visible}
  onHide={() => setVisible(false)}
  header="Crear usuario"
  style={{ width: '520px' }}
  modal
  draggable={false}
  resizable={false}
>
  <div className="flex flex-col gap-4 pt-2">
    <Q2InputField label="Nombre" id="name" />
    <Q2InputField label="Email" id="email" />
  </div>
  <div className="flex justify-end gap-3 mt-6">
    <button className="acl-btn acl-btn-ghost" onClick={() => setVisible(false)}>
      Cancelar
    </button>
    <button className="acl-btn acl-btn-primary">
      <i className="pi pi-check" />
      Guardar
    </button>
  </div>
</Dialog>

// Sidebar / Drawer (desde la derecha)
<Sidebar
  visible={drawerVisible}
  onHide={() => setDrawerVisible(false)}
  position="right"
  style={{ width: '480px' }}
  header="Editar usuario"
>
  <div className="flex flex-col gap-4">
    {/* Formulario */}
  </div>
</Sidebar>
```

### 6.7 Toast

```tsx
import { Toast } from 'primereact/toast';
import { useRef } from 'react';

function MyComponent() {
  const toast = useRef<Toast>(null);

  const showSuccess = () => {
    toast.current?.show({
      severity: 'success',
      summary: 'Guardado',
      detail: 'El registro fue guardado correctamente.',
      life: 4000,
    });
  };

  const showError = () => {
    toast.current?.show({
      severity: 'error',
      summary: 'Error',
      detail: 'Ocurrió un error al guardar.',
      life: 6000,
    });
  };

  return (
    <>
      <Toast ref={toast} position="top-right" />
      <button className="acl-btn acl-btn-primary" onClick={showSuccess}>
        Guardar
      </button>
    </>
  );
}
```

Para uso global, la semilla ya incluye `Q1GlobalToast` (montado en `app-providers.tsx`), que registra su ref en `useUiStore`. Desde cualquier componente: `useUiStore.getState().showSuccess(summary, detail)` / `showError(summary, detail)` (o los selectores equivalentes). No crear otro `<Toast>` global.

### 6.8 Badge / Tag

```tsx
import { Tag } from 'primereact/tag';

// Via PrimeReact Tag (override via theme.css)
<Tag severity="success" value="Activo" />
<Tag severity="warning" value="Pendiente" />
<Tag severity="danger" value="Inactivo" />
<Tag severity="info" value="En revisión" />

// Via clases ACL (más control visual)
<span className="acl-badge acl-badge-success">Activo</span>
<span className="acl-badge acl-badge-warning">Pendiente</span>
<span className="acl-badge acl-badge-danger">Rechazado</span>
<span className="acl-badge acl-badge-info">En revisión</span>
<span className="acl-badge acl-badge-pink">Nuevo</span>
```

### 6.9 Skeleton

Ver [11-http-error-handling.md](11-http-error-handling.md). Siempre usar `<Skeleton>` de PrimeReact en `isLoading`.

```tsx
import { Skeleton } from 'primereact/skeleton';

// Card skeleton
<div className="acl-card">
  <Skeleton height="1.5rem" width="60%" className="mb-3" />
  <Skeleton height="1rem" className="mb-2" />
  <Skeleton height="1rem" width="80%" />
</div>

// Lista skeleton
{Array.from({ length: 5 }).map((_, i) => (
  <Skeleton key={i} height="3.5rem" borderRadius="8px" />
))}

// KPI card skeleton
<div className="acl-kpi-card">
  <Skeleton height="3.5rem" style={{ borderRadius: '16px 16px 0 0' }} />
  <div className="p-5">
    <Skeleton height="2.5rem" width="40%" className="mb-2" />
    <Skeleton height="1rem" width="60%" />
  </div>
</div>
```

---

## 7. Atomic Design con PrimeReact

### 7.1 Átomos (q1) — Wrappers de PrimeReact

Los átomos envuelven componentes PrimeReact añadiendo las convenciones ACL: accesibilidad, tokens de diseño, props tipadas.

```tsx
// src/global/components/q1-button/q1-button.tsx (incluido en la semilla)
import { Button, type ButtonProps } from 'primereact/button';

type Variant = 'primary' | 'secondary' | 'danger' | 'ghost';

interface Props extends Omit<ButtonProps, 'severity'> {
  variant?: Variant;
}

const variantMap: Record<Variant, ButtonProps['severity']> = {
  primary: undefined,
  secondary: 'secondary',
  danger: 'danger',
  ghost: 'help',
};

export function Q1Button({ variant = 'primary', ...props }: Props) {
  return <Button severity={variantMap[variant]} {...props} />;
}
```

Otros átomos incluidos: `Q1LoadingSpinner` (`size?: 'sm' | 'md' | 'lg'`, `label?`) y `Q1GlobalToast`. Para estados de carga de datos se usa `<Skeleton>`, no `Q1LoadingSpinner` (ver sección 6.9).

### 7.2 Moléculas (q2) — Combinaciones con propósito

```tsx
// src/global/components/q2-badge/q2-badge.tsx (incluido en la semilla)
type Status = 'success' | 'warning' | 'danger' | 'info' | 'neutral';

interface Props {
  label: string;
  status?: Status; // default 'neutral'
}

// Renderiza <span className="acl-badge acl-badge-{status}">{label}</span>
export function Q2Badge({ label, status = 'neutral' }: Props) { /* … */ }
```

Otras moléculas incluidas: `Q2Forbidden` (sección 8.6) y `Q2ErrorFallback` (fallback del `Sentry.ErrorBoundary`). Los ejemplos siguientes (`Q2InputField`, `Q2SearchBar`) **no** vienen en la semilla; son patrones sugeridos para cuando un proyecto los necesite.

```tsx
// Ejemplo (no incluido en la semilla): src/global/components/q2-input-field/q2-input-field.tsx
import { forwardRef } from 'react';
import { InputText, type InputTextProps } from 'primereact/inputtext';

interface Q2InputFieldProps extends InputTextProps {
  label: string;
  error?: string;
  hint?: string;
  required?: boolean;
}

export const Q2InputField = forwardRef<HTMLInputElement, Q2InputFieldProps>(
  ({ label, error, hint, required, id, className = '', ...props }, ref) => {
    return (
      <div className="acl-form-group">
        <label htmlFor={id} className="acl-form-label">
          {label}
          {required && <span className="text-red-500 ml-1" aria-hidden="true">*</span>}
        </label>
        <InputText
          ref={ref}
          id={id}
          className={`w-full ${error ? 'p-invalid' : ''} ${className}`}
          aria-invalid={!!error}
          aria-describedby={error ? `${id}-error` : hint ? `${id}-hint` : undefined}
          {...props}
        />
        {error && (
          <span id={`${id}-error`} className="acl-form-error" role="alert">
            <i className="pi pi-exclamation-circle" style={{ fontSize: '0.7rem' }} />
            {error}
          </span>
        )}
        {hint && !error && (
          <span id={`${id}-hint`} className="acl-form-hint">
            {hint}
          </span>
        )}
      </div>
    );
  }
);

Q2InputField.displayName = 'Q2InputField';
```

```tsx
// Ejemplo (no incluido en la semilla): src/global/components/q2-search-bar/q2-search-bar.tsx
import { useRef } from 'react';
import { InputText } from 'primereact/inputtext';

interface Q2SearchBarProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  onSearch?: (value: string) => void;
}

export function Q2SearchBar({ value, onChange, placeholder = 'Buscar...', onSearch }: Q2SearchBarProps) {
  const inputRef = useRef<HTMLInputElement>(null);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && onSearch) {
      onSearch(value);
    }
    if (e.key === 'Escape') {
      onChange('');
      inputRef.current?.blur();
    }
  };

  return (
    <div className="p-input-icon-left flex-1 max-w-xs">
      <i className="pi pi-search" style={{ color: 'var(--acl-text-tertiary)' }} />
      <InputText
        ref={inputRef}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        className="w-full"
        aria-label="Campo de búsqueda"
      />
    </div>
  );
}
```

### 7.3 Células (q3) — Estado local complejo

`Q3StatCard` (incluido en la semilla) tiene esta firma:

```tsx
// src/global/components/q3-stat-card/q3-stat-card.tsx
interface Props {
  title: string;
  value: string | number;
  icon?: string;                       // clase PrimeIcons completa, ej: 'pi pi-users'
  trend?: 'up' | 'down' | 'neutral';   // default 'neutral'
}
export function Q3StatCard({ title, value, icon, trend = 'neutral' }: Props) { /* … */ }
```

Para KPIs con header en gradiente y delta porcentual, usar las clases `.acl-kpi-card*` de `theme.css`. Ejemplo (no incluido en la semilla):

```tsx
// Ejemplo: src/global/components/q3-kpi-card/q3-kpi-card.tsx
import type { ReactNode } from 'react';

interface Q3KpiCardProps {
  title: string;
  value: string | number;
  icon?: string;
  delta?: number;        // porcentaje de cambio
  deltaLabel?: string;   // ej: "vs. mes anterior"
  footer?: ReactNode;
}

export function Q3KpiCard({ title, value, icon, delta, deltaLabel, footer }: Q3KpiCardProps) {
  const isPositiveDelta = delta !== undefined && delta >= 0;
  const deltaIcon = isPositiveDelta ? 'pi-arrow-up' : 'pi-arrow-down';

  return (
    <div className="acl-kpi-card">
      <div className="acl-kpi-card__header">
        <span className="acl-kpi-card__header-title">{title}</span>
        {icon && <i className={`pi ${icon} acl-kpi-card__header-icon`} aria-hidden="true" />}
      </div>
      <div className="acl-kpi-card__body">
        <div className="acl-kpi-card__value">{value}</div>
        {delta !== undefined && (
          <div className={`acl-kpi-card__delta acl-kpi-card__delta--${isPositiveDelta ? 'up' : 'down'}`}>
            <i className={`pi ${deltaIcon}`} style={{ fontSize: '0.7rem' }} />
            <span>{Math.abs(delta)}%</span>
            {deltaLabel && (
              <span style={{ fontWeight: 400, color: 'var(--acl-text-tertiary)' }}>{deltaLabel}</span>
            )}
          </div>
        )}
        {footer && <div className="mt-3">{footer}</div>}
      </div>
    </div>
  );
}
```

### 7.4 Organismos (q4) — Lógica de negocio completa

Ver ejemplos en [04-patterns.md](04-patterns.md). Los organismos típicos del ACL Design System:

- `q4-profile-form` — formulario de edición con RHF + Zod (ver `SKILL.md`, sección 7)
- `q4-data-table` — tabla con búsqueda, filtros y paginación
- `q4-detail-form` — formulario de edición en drawer
- `q4-kanban-board` — tablero con drag & drop

```tsx
// src/modules/users/components/q4-users-list/q4-users-list.tsx
import { useState } from 'react';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Skeleton } from 'primereact/skeleton';
import { Q2SearchBar } from '@global/components/q2-search-bar/q2-search-bar'; // ejemplo de 7.2
import { Q2Badge, Q2Forbidden } from '@global/components';
import { getHttpStatus } from '@global/utils';
import { useUsersQuery } from '../../core/hooks/use-users-query';
import type { User } from '@resources/entities/user.entity';

export function Q4UsersList() {
  const [search, setSearch] = useState('');
  const { data: users, isLoading, error } = useUsersQuery();

  if (isLoading) {
    return (
      <div className="acl-card" style={{ padding: 0, overflow: 'hidden' }}>
        <div className="p-4 flex items-center gap-4" style={{ borderBottom: '1px solid var(--acl-border)' }}>
          <Skeleton height="2.5rem" width="300px" borderRadius="8px" />
          <Skeleton height="2.5rem" width="120px" borderRadius="8px" />
        </div>
        <div className="p-4 flex flex-col gap-2">
          <Skeleton height="3rem" borderRadius="8px" />
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} height="3rem" borderRadius="8px" />
          ))}
        </div>
      </div>
    );
  }

  if (getHttpStatus(error) === 403) return <Q2Forbidden />;

  const filtered = users?.filter((u) =>
    u.name.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase())
  ) ?? [];

  const statusTemplate = (row: User) => (
    <Q2Badge
      label={row.status === 'active' ? 'Activo' : 'Inactivo'}
      status={row.status === 'active' ? 'success' : 'neutral'}
    />
  );

  return (
    <div className="acl-card" style={{ padding: 0, overflow: 'hidden' }}>
      <div
        className="flex items-center justify-between gap-4 p-4"
        style={{ borderBottom: '1px solid var(--acl-border)' }}
      >
        <Q2SearchBar value={search} onChange={setSearch} placeholder="Buscar usuarios..." />
        <button className="acl-btn acl-btn-primary">
          <i className="pi pi-plus" />
          Nuevo usuario
        </button>
      </div>

      <DataTable
        value={filtered}
        dataKey="id"
        stripedRows
        paginator
        rows={10}
        rowsPerPageOptions={[10, 25, 50]}
        emptyMessage={
          <div className="acl-empty-state">
            <i className="pi pi-users acl-empty-state__icon" />
            <p className="acl-empty-state__title">Sin usuarios</p>
            <p className="acl-empty-state__description">
              {search ? 'No se encontraron usuarios con esa búsqueda.' : 'Aún no hay usuarios registrados.'}
            </p>
          </div>
        }
      >
        <Column field="name" header="Nombre" sortable />
        <Column field="email" header="Email" sortable />
        <Column field="status" header="Estado" body={statusTemplate} />
      </DataTable>
    </div>
  );
}
```

### 7.5 Templates (q4 con layout de página)

```tsx
// Patrón PageHeader + Contenido
export function Q4PageLayout({
  title,
  subtitle,
  actions,
  children,
}: {
  title: string;
  subtitle?: string;
  actions?: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div className="acl-page-header">
          <h1 className="acl-page-header__title">{title}</h1>
          {subtitle && <p className="acl-page-header__subtitle">{subtitle}</p>}
        </div>
        {actions && <div className="flex items-center gap-3 flex-wrap">{actions}</div>}
      </div>
      {children}
    </div>
  );
}
```

### 7.6 Páginas (pa) — Destino de rutas

```tsx
// src/modules/users/components/pa-users/pa-users.tsx
import { Q4UsersList } from '../q4-users-list/q4-users-list';

export function PaUsers() {
  return (
    <div className="flex flex-col gap-6 acl-animate-slide-up">
      <div className="acl-page-header">
        <h1 className="acl-page-header__title">Gestión de Usuarios</h1>
        <p className="acl-page-header__subtitle">Administra los usuarios del sistema</p>
      </div>
      <Q4UsersList />
    </div>
  );
}
```

---

## 8. Patrones de Diseño UI

### 8.1 KPI Cards con Gradiente

```tsx
// Dashboard con 4 KPI cards (Q3KpiCard: ejemplo de la sección 7.3)
function Q3DashboardKpis() {
  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <Q3KpiCard
        title="Usuarios Activos"
        value="2,847"
        icon="pi-users"
        delta={12.5}
        deltaLabel="vs. mes anterior"
      />
      <Q3KpiCard
        title="Solicitudes Hoy"
        value="184"
        icon="pi-inbox"
        delta={-3.2}
        deltaLabel="vs. ayer"
      />
      <Q3KpiCard
        title="Tasa de Aprobación"
        value="94.8%"
        icon="pi-check-circle"
        delta={2.1}
        deltaLabel="vs. semana anterior"
      />
      <Q3KpiCard
        title="Tiempo Promedio"
        value="1.4h"
        icon="pi-clock"
        delta={-8.0}
        deltaLabel="de procesamiento"
      />
    </div>
  );
}
```

### 8.2 Status Badges

```tsx
// Mapa de estado a color — define en un archivo de utilidades
import type { ComponentProps } from 'react';
import { Q2Badge } from '@global/components';

type BadgeStatus = NonNullable<ComponentProps<typeof Q2Badge>['status']>;

const STATUS_MAP: Record<string, { label: string; status: BadgeStatus }> = {
  active:   { label: 'Activo',      status: 'success' },
  inactive: { label: 'Inactivo',    status: 'neutral' },
  pending:  { label: 'Pendiente',   status: 'warning' },
  rejected: { label: 'Rechazado',   status: 'danger' },
  review:   { label: 'En revisión', status: 'info' },
};

// Uso en tabla
const statusTemplate = (row: { status: string }) => {
  const mapped = STATUS_MAP[row.status] ?? { label: row.status, status: 'neutral' };
  return <Q2Badge label={mapped.label} status={mapped.status} />;
};

// Q2Badge no soporta 'pink'; para ese caso usar la clase directamente:
// <span className="acl-badge acl-badge-pink">Nuevo</span>
```

### 8.3 Tabla de Datos con Acciones

```tsx
// Columna de acciones con iconos
const actionsTemplate = (row: User) => (
  <div className="flex items-center gap-1">
    <button
      className="acl-btn acl-btn-ghost p-2"
      title="Ver detalle"
      aria-label={`Ver detalle de ${row.name}`}
    >
      <i className="pi pi-eye text-sm" style={{ color: 'var(--acl-text-secondary)' }} />
    </button>
    <button
      className="acl-btn acl-btn-ghost p-2"
      title="Editar"
      aria-label={`Editar ${row.name}`}
      onClick={() => onEdit(row)}
    >
      <i className="pi pi-pencil text-sm" style={{ color: 'var(--acl-brand-secondary)' }} />
    </button>
    <button
      className="acl-btn acl-btn-ghost p-2"
      title="Eliminar"
      aria-label={`Eliminar ${row.name}`}
      onClick={() => onDelete(row)}
    >
      <i className="pi pi-trash text-sm" style={{ color: 'var(--acl-danger)' }} />
    </button>
  </div>
);
```

### 8.4 Formularios en Drawer/Dialog

```tsx
// Patrón formulario en Sidebar (drawer desde la derecha)
function Q4EditUserDrawer({
  user,
  visible,
  onHide,
  onSuccess,
}: {
  user: User | null;
  visible: boolean;
  onHide: () => void;
  onSuccess: () => void;
}) {
  const { mutate: update, isPending } = useUpdateUserMutation({ onSuccess: () => { onSuccess(); onHide(); } });
  const { control, handleSubmit, reset, formState: { errors } } = useForm<UserFormValues>({
    resolver: zodResolver(userSchema),
    defaultValues: user ?? { name: '', email: '', status: 'active' },
  });

  useEffect(() => { if (user) reset(user); }, [user, reset]);

  return (
    <Sidebar
      visible={visible}
      onHide={onHide}
      position="right"
      style={{ width: '480px' }}
      header={
        <div className="flex items-center gap-3">
          <div
            className="w-8 h-8 rounded-lg flex items-center justify-center"
            style={{ background: 'var(--acl-brand-gradient)' }}
          >
            <i className="pi pi-user text-white text-sm" />
          </div>
          <h2 className="text-lg font-semibold" style={{ color: 'var(--acl-text-primary)' }}>
            {user ? 'Editar usuario' : 'Nuevo usuario'}
          </h2>
        </div>
      }
    >
      <form onSubmit={handleSubmit((data) => update({ id: user!.id, ...data }))} className="flex flex-col gap-4 h-full">
        <div className="flex-1 flex flex-col gap-4 overflow-y-auto pb-4">
          <Controller
            name="name"
            control={control}
            render={({ field }) => (
              <Q2InputField
                {...field}
                id="name"
                label="Nombre completo"
                error={errors.name?.message}
                required
              />
            )}
          />
          <Controller
            name="email"
            control={control}
            render={({ field }) => (
              <Q2InputField
                {...field}
                id="email"
                label="Email"
                type="email"
                error={errors.email?.message}
                required
              />
            )}
          />
        </div>
        <div
          className="flex justify-end gap-3 pt-4"
          style={{ borderTop: '1px solid var(--acl-border)' }}
        >
          <button type="button" className="acl-btn acl-btn-ghost" onClick={onHide}>
            Cancelar
          </button>
          <button type="submit" className="acl-btn acl-btn-primary" disabled={isPending}>
            {isPending ? (
              <><i className="pi pi-spin pi-spinner" />Guardando...</>
            ) : (
              <><i className="pi pi-check" />Guardar</>
            )}
          </button>
        </div>
      </form>
    </Sidebar>
  );
}
```

### 8.5 Empty State

```tsx
// Reutilizable con variantes
interface Q2EmptyStateProps {
  icon?: string;
  title: string;
  description?: string;
  action?: {
    label: string;
    onClick: () => void;
    icon?: string;
  };
}

export function Q2EmptyState({ icon = 'pi-inbox', title, description, action }: Q2EmptyStateProps) {
  return (
    <div className="acl-empty-state">
      <div
        className="w-16 h-16 rounded-full flex items-center justify-center mb-4"
        style={{ background: 'var(--acl-surface-alt)' }}
      >
        <i className={`pi ${icon}`} style={{ fontSize: '1.75rem', color: 'var(--acl-text-tertiary)' }} />
      </div>
      <p className="acl-empty-state__title">{title}</p>
      {description && <p className="acl-empty-state__description">{description}</p>}
      {action && (
        <button
          className="acl-btn acl-btn-primary mt-5"
          onClick={action.onClick}
        >
          {action.icon && <i className={`pi ${action.icon}`} />}
          {action.label}
        </button>
      )}
    </div>
  );
}
```

### 8.6 Estado de Error 403 — Forbidden

Ver [11-http-error-handling.md](11-http-error-handling.md). Detección con `getHttpStatus(error) === 403` (`@global/utils`).

```tsx
// src/global/components/q2-forbidden/q2-forbidden.tsx (incluido en la semilla)
import { Button } from 'primereact/button';
import { useNavigate } from 'react-router-dom';

export function Q2Forbidden() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col items-center justify-center gap-4 p-8 text-center">
      <i className="pi pi-lock text-5xl" style={{ color: 'var(--red-500)' }} />
      <h2 className="text-xl font-semibold" style={{ color: 'var(--text-color)' }}>
        Ups... no estás autorizado para ver esto
      </h2>
      <p className="text-sm" style={{ color: 'var(--text-color-secondary)' }}>
        No tienes permisos para ver este contenido.
      </p>
      <Button label="Volver" icon="pi pi-arrow-left" text onClick={() => navigate(-1)} />
    </div>
  );
}
```

> Hoy `Q2Forbidden` usa variables de PrimeReact (`--red-500`, `--text-color`) en lugar de tokens `--acl-*`. Si se modifica, preferir `--acl-danger`, `--acl-text-primary` y `--acl-text-secondary`.

```tsx
// Uso
if (isLoading) return <Skeleton height="10rem" />;
if (getHttpStatus(error) === 403) return <Q2Forbidden />;
```

### 8.7 Filtros + Búsqueda

```tsx
// Toolbar de filtros para tablas
function Q2FilterBar({
  search,
  onSearchChange,
  filters,
  onFiltersChange,
  onReset,
}: FilterBarProps) {
  const hasActiveFilters = search || Object.values(filters).some(Boolean);

  return (
    <div
      className="flex items-center gap-3 p-4 flex-wrap"
      style={{ borderBottom: '1px solid var(--acl-border)' }}
    >
      <Q2SearchBar value={search} onChange={onSearchChange} />

      <Dropdown
        value={filters.status}
        options={STATUS_OPTIONS}
        onChange={(e) => onFiltersChange({ ...filters, status: e.value })}
        placeholder="Estado"
        className="w-40"
        showClear
      />

      <Dropdown
        value={filters.role}
        options={ROLE_OPTIONS}
        onChange={(e) => onFiltersChange({ ...filters, role: e.value })}
        placeholder="Rol"
        className="w-40"
        showClear
      />

      {hasActiveFilters && (
        <button className="acl-btn acl-btn-ghost text-sm" onClick={onReset}>
          <i className="pi pi-times" style={{ fontSize: '0.75rem' }} />
          Limpiar filtros
        </button>
      )}
    </div>
  );
}
```

### 8.8 Skeleton en Carga

Ver [11-http-error-handling.md](11-http-error-handling.md) para la regla completa. Patrones clave:

```tsx
// Page skeleton — emula estructura de la página
if (isLoading) {
  return (
    <div className="flex flex-col gap-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <Skeleton height="2rem" width="200px" className="mb-2" />
          <Skeleton height="1rem" width="300px" />
        </div>
        <Skeleton height="2.5rem" width="140px" borderRadius="8px" />
      </div>
      {/* KPI grid */}
      <div className="grid grid-cols-4 gap-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="acl-kpi-card">
            <Skeleton height="3.5rem" style={{ borderRadius: '16px 16px 0 0' }} />
            <div className="p-5">
              <Skeleton height="2.5rem" width="40%" className="mb-2" />
              <Skeleton height="1rem" width="60%" />
            </div>
          </div>
        ))}
      </div>
      {/* Tabla */}
      <div className="acl-card" style={{ padding: '16px' }}>
        {Array.from({ length: 6 }).map((_, i) => (
          <Skeleton key={i} height="3rem" className="mb-2" borderRadius="8px" />
        ))}
      </div>
    </div>
  );
}
```

### 8.9 Paginación

DataTable de PrimeReact incluye paginador. Configuración estándar ACL:

```tsx
<DataTable
  value={data}
  paginator
  rows={10}
  rowsPerPageOptions={[10, 25, 50]}
  paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
  currentPageReportTemplate="{first}-{last} de {totalRecords}"
  paginatorLeft={
    <span className="text-sm" style={{ color: 'var(--acl-text-secondary)' }}>
      {data?.length} registros
    </span>
  }
/>
```

Para paginación server-side:

```tsx
<DataTable
  value={data}
  lazy
  paginator
  first={first}
  rows={rows}
  totalRecords={totalRecords}
  onPage={(e) => { setFirst(e.first); setRows(e.rows); }}
  loading={isLoading}
/>
```

---

## 9. Iconografía

### PrimeIcons 7.0.0

PrimeIcons es la librería de íconos oficial del stack. Se usa mediante la clase `pi pi-{nombre}`.

```tsx
// Acceso en JSX
<i className="pi pi-home" />
<i className="pi pi-user" aria-hidden="true" />

// Con tamaño
<i className="pi pi-search" style={{ fontSize: '1.25rem' }} />

// Cuándo incluir aria-label
// Si el ícono tiene significado sin texto acompañante, agregar aria-label al elemento padre
<button aria-label="Cerrar" onClick={onClose}>
  <i className="pi pi-times" aria-hidden="true" />
</button>
```

#### Íconos estándar ACL

| Contexto | Ícono | Clase |
|---|---|---|
| Dashboard / inicio | Home | `pi-home` |
| Usuarios | Usuario | `pi-user` / `pi-users` |
| Configuración | Engranaje | `pi-cog` |
| Búsqueda | Lupa | `pi-search` |
| Agregar | Plus | `pi-plus` |
| Editar | Lápiz | `pi-pencil` |
| Eliminar | Papelera | `pi-trash` |
| Ver detalle | Ojo | `pi-eye` |
| Guardar | Check | `pi-check` |
| Cancelar | X | `pi-times` |
| Éxito | Check-circle | `pi-check-circle` |
| Error | Exclamation | `pi-exclamation-circle` |
| Advertencia | Triangle | `pi-exclamation-triangle` |
| Info | Info-circle | `pi-info-circle` |
| Cerrar sesión | Sign-out | `pi-sign-out` |
| Menú hamburguesa | Bars | `pi-bars` |
| Notificaciones | Bell | `pi-bell` |
| Filtros | Filter | `pi-filter` |
| Exportar | Download | `pi-download` |
| Cargar | Spinner | `pi-spin pi-spinner` |
| Bloqueado | Lock | `pi-lock` |
| Reportes | Chart | `pi-chart-bar` |
| Calendario | Calendar | `pi-calendar` |

#### Cuándo NO usar PrimeIcons

- Íconos de marca (logos de terceros): usar SVG o una librería específica.
- Ilustraciones complejas: usar SVG custom.
- Íconos que PrimeIcons no incluye y se usan frecuentemente: evaluar `lucide-react` como complemento.

---

## 10. Animaciones y Transiciones

### 10.1 Transiciones Estándar

```css
/* Variables de transición */
--acl-transition-fast:  150ms ease;  /* hover estados, cambios de color */
--acl-transition:       200ms ease;  /* aparición de elementos, focus */
--acl-transition-slow:  300ms ease;  /* drawer, sidebar, dark mode */
```

**Regla:** No usar `transition: all`. Especificar siempre la propiedad:

```css
/* Correcto */
transition: background-color 200ms ease, border-color 200ms ease;

/* Incorrecto */
transition: all 200ms;
```

### 10.2 Clases de Animación de Entrada

```tsx
// fade in — para contenido que aparece
<div className="acl-animate-fade-in">...</div>

// slide up — para cards, páginas
<div className="acl-animate-slide-up">...</div>

// slide down — para dropdowns, notificaciones desde arriba
<div className="acl-animate-slide-down">...</div>

// slide in left — para contenido de sidebar
<div className="acl-animate-slide-in-left">...</div>

// scale in — para modales, tooltips
<div className="acl-animate-scale-in">...</div>
```

### 10.3 Micro-interacciones

```tsx
// Botón con feedback de loading
<button
  className="acl-btn acl-btn-primary"
  disabled={isPending}
  style={{ transition: 'opacity 150ms ease, box-shadow 150ms ease' }}
>
  {isPending ? (
    <><i className="pi pi-spin pi-spinner" />Procesando...</>
  ) : (
    <><i className="pi pi-check" />Guardar</>
  )}
</button>

// Card con hover lift
<div
  className="acl-card"
  style={{ transition: 'box-shadow 200ms ease, transform 200ms ease' }}
  onMouseEnter={(e) => { e.currentTarget.style.transform = 'translateY(-2px)'; }}
  onMouseLeave={(e) => { e.currentTarget.style.transform = 'translateY(0)'; }}
>
  ...
</div>
```

### 10.4 Animaciones de Página

Envolver el contenido de `pa-*` con la clase de animación:

```tsx
export function PaDashboard() {
  return (
    <div className="flex flex-col gap-6 acl-animate-slide-up">
      {/* contenido */}
    </div>
  );
}
```

---

## 11. Accesibilidad

### 11.1 Contraste (WCAG AA mínimo)

Valores calculados con los colores por defecto de la semilla. Al reemplazar la marca según `PROJECT.md`, recalcular esta tabla con los nuevos valores.

| Combinación | Ratio | Estado |
|---|---|---|
| `#E31D4A` sobre `#FFFFFF` | 4.6:1 | ✓ AA |
| `#5135A1` sobre `#FFFFFF` | 7.2:1 | ✓ AAA |
| `#111827` sobre `#F9FAFB` | 18.3:1 | ✓ AAA |
| `#6B7280` sobre `#FFFFFF` | 4.6:1 | ✓ AA |
| `#F3F4F6` sobre `#1F1D2C` | 14.1:1 | ✓ AAA (dark) |

### 11.2 Focus States

Todo elemento interactivo debe mostrar un focus visible claro:

```css
/* Ya definido en theme.css */
:focus-visible {
  outline: 2px solid var(--acl-brand-primary);
  outline-offset: 2px;
}
```

No remover `outline: none` en elementos interactivos sin proveer un reemplazo.

### 11.3 ARIA en Componentes

```tsx
// Botones solo con ícono → aria-label obligatorio
<button aria-label="Cerrar modal" onClick={onClose}>
  <i className="pi pi-times" aria-hidden="true" />
</button>

// Errores de formulario → role="alert" o aria-live
<span role="alert" className="acl-form-error">
  {error}
</span>

// Íconos decorativos → aria-hidden="true"
<i className="pi pi-check" aria-hidden="true" />

// Loading state → aria-busy
<div aria-busy={isLoading} aria-live="polite">
  {isLoading ? <Skeleton height="3rem" /> : <Content />}
</div>

// Sidebar → aria-label
<aside aria-label="Navegación principal">...</aside>

// Tabla → caption o aria-label
<DataTable
  aria-label="Lista de usuarios"
  ...
/>
```

---

## 12. Checklist de Consistencia

Antes de hacer merge de un componente o página nueva, verificar:

### Tokens y Colores
- [ ] Todos los colores usan variables `--acl-*` (no hardcoded hex)
- [ ] Los textos usan `--acl-text-primary/secondary/tertiary`
- [ ] Los fondos usan `--acl-card` o `--acl-surface`
- [ ] Los bordes usan `--acl-border` o `--acl-border-strong`

### Dark Mode
- [ ] Verificar visualmente el componente en dark mode
- [ ] Los backgrounds no están hardcodeados como `#FFFFFF` o `#F9FAFB`
- [ ] Los textos no están hardcodeados como `#000000` o `#111827`
- [ ] Los bordes no están hardcodeados

### Spacing y Layout
- [ ] El spacing usa clases Tailwind (`gap-4`, `p-6`) o variables `--acl-spacing-*`
- [ ] No hay valores de `margin` o `padding` hardcodeados en px
- [ ] El layout es responsive: funciona en mobile (< 640px) y desktop

### Accesibilidad
- [ ] Todos los botones sin texto tienen `aria-label`
- [ ] Los íconos decorativos tienen `aria-hidden="true"`
- [ ] Los errores de formulario tienen `role="alert"` o `aria-describedby`
- [ ] El focus visible es visible sobre el elemento

### Componentes PrimeReact
- [ ] Los estados de carga usan `<Skeleton>` de PrimeReact (no spinners custom)
- [ ] Los errores 403 usan `<Q2Forbidden />` (no redirección)
- [ ] Los botones usan `Q1Button` o `Button` de PrimeReact (no `<button>` HTML puro)

### Patrones de Código
- [ ] El componente tiene export nombrado (no default)
- [ ] El nombre sigue el patrón `{nivel}-{nombre}.tsx` → `export function {Nivel}{Nombre}`
- [ ] Existe un `index.ts` barrel en la carpeta del componente
- [ ] Los tests existen (`*.test.tsx`) para componentes q1-q4
- [ ] Storybook story existe (`*.stories.tsx`) para componentes q1-q3

### Animaciones
- [ ] Las páginas (`pa-*`) tienen clase `acl-animate-slide-up` en el wrapper raíz
- [ ] Los modales/drawers tienen `acl-animate-scale-in` o `acl-animate-slide-in-left`
- [ ] Las transiciones especifican la propiedad (no `transition: all`)

---

## 13. AppShell Pattern (Q3AppShell) — Layout Estándar

`Q3AppShell` (`src/global/components/q3-app-shell/`) es el componente de layout estándar de la semilla para las rutas autenticadas. Provee sidebar dark fijo en desktop (`--acl-sidebar-width`, 280px), drawer de PrimeReact en mobile, topbar y un `<Outlet>` de React Router para el contenido de cada ruta.

### 13.1 Interfaces

```typescript
// src/global/components/q3-app-shell/q3-app-shell.tsx
export interface NavItem {
  path: string;   // ruta exacta, ej: '/profile'
  icon: string;   // clase PrimeIcons completa, ej: 'pi pi-user'
  label: string;  // texto del nav item, ej: 'Mi perfil'
}

interface Props {
  appName: string;           // nombre de la app mostrado bajo el logo del sidebar
  navItems: NavItem[];       // items de navegación fijos
  topbarActions?: ReactNode; // slot para botones adicionales en el topbar
}
```

`Q3AppShell` y `NavItem` se exportan desde el barrel `@global/components`.

### 13.2 Estructura de la implementación

Resumen de `src/global/components/q3-app-shell/q3-app-shell.tsx` (leer el archivo antes de modificarlo):

| Zona | Implementación |
|---|---|
| Header del sidebar | Logo opcional (`logoSrc`, PROJECT.md → Marca) + `appName` en `var(--acl-brand-primary)` |
| Navegación | `navItems` como `NavLink` con `.acl-sidebar-item` / `.acl-sidebar-item--active` / `.acl-sidebar-item__icon` |
| Panel de usuario | Iniciales y datos desde `useAuthStatus()` (`user.name`, `user.email`); botón "Cerrar sesión" con `useLogoutMutation()` |
| Desktop | `<aside className="acl-sidebar hidden lg:flex flex-col">` + main con `lg:ml-[var(--acl-sidebar-width)]` |
| Mobile | `Sidebar` de PrimeReact controlado por `sidebarOpen` / `setSidebarOpen` de `useUiStore`; botón hamburguesa `lg:hidden` |
| Topbar | `<header className="acl-topbar">` con links externos por defecto de la semilla (con `Tooltip`) y el slot `topbarActions` |
| Contenido | `<main className="acl-content"><Outlet /></main>` |

**Por proyecto:** reemplazar el logo (`public/`), los links externos del topbar y, si no aplica, la sección de categorías dinámicas, según `PROJECT.md` (sección Marca). Son valores de la semilla, no parte de la estructura.

### 13.3 Registrar rutas con AppShell en el router

```typescript
// src/app/router/app-router.tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { Q3AppShell, Q5ProtectedRoute, type NavItem } from '@global/components';
import { loginRoutes } from '@modules/login';
import { callbackRoutes } from '@modules/callback';
import { profileRoutes } from '@modules/profile'; // módulo del proyecto derivado

const NAV_ITEMS: NavItem[] = [
  { path: '/profile', icon: 'pi pi-user', label: 'Mi perfil' },
  // Agregar nuevos items aquí
];

export const router = createBrowserRouter([
  ...loginRoutes,
  ...callbackRoutes,
  {
    element: <Q5ProtectedRoute />,
    children: [
      {
        element: <Q3AppShell appName="Mi App" navItems={NAV_ITEMS} />,
        children: [
          // Rutas que se renderizan dentro del AppShell
          ...profileRoutes,
        ],
      },
    ],
  },
  { path: '/', element: <Navigate to="/login" replace /> },
  { path: '*', element: <Navigate to="/login" replace /> },
]);
```

> `Q5ProtectedRoute` es la guarda de sesión: las rutas de negocio (y el `Q3AppShell`) van como hijas suyas; sin sesión redirige a `/login`.

### 13.4 Agregar un nuevo nav item

1. Agregar la ruta al módulo correspondiente (`src/modules/{mod}/routes/{mod}.routes.tsx`)
2. Registrar en `app-router.tsx` dentro del `children` del `Q3AppShell`
3. Agregar el item al array `NAV_ITEMS`:

```typescript
const NAV_ITEMS: NavItem[] = [
  { path: '/profile', icon: 'pi pi-user',      label: 'Mi perfil' },
  { path: '/items',   icon: 'pi pi-list',      label: 'Ítems' },      // nuevo
  { path: '/reports', icon: 'pi pi-chart-bar', label: 'Reportes' },   // nuevo
];
```

### 13.5 Dependencias del AppShell

- `useUiStore` (`@global/store/ui.store`) — `sidebarOpen` / `setSidebarOpen`
- `useAuthStatus` (`@global/hooks`, re-export de `@library/oidc`) — datos del usuario autenticado (`user.name`, `user.email`) derivados del ID token
- `useLogoutMutation` (`@global/hooks`, re-export de `@library/oidc`) — limpia el cache de React Query y ejecuta `oidc.logout()`

---

## 14. PrimeReact Setup — Tema base + overrides ACL

### 14.1 Orden correcto de imports en main.tsx

```typescript
// src/app/main.tsx (extracto)
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { initSentry } from '@library/integrations/sentry/sentry.client';
import { bootstrapOidc, oidcConfig } from '@library/oidc';
import { AppProviders } from './providers/app-providers';

// (validación de REQUIRED_ENV_VARS — ver 10-config.md)

// ORDEN CRÍTICO DE IMPORTS CSS:
import 'primereact/resources/themes/lara-light-indigo/theme.css'; // tema base de PrimeReact
import 'primereact/resources/primereact.min.css';                 // estilos estructurales
import 'primeicons/primeicons.css';                                // íconos
import '@/styles/theme.css';                                       // tokens --acl-* y overrides de PrimeReact
import '@/styles/main.css';                                        // Tailwind (capas)

initSentry();
bootstrapOidc({ implementation: 'real', issuerUri: oidcConfig.issuerUri, clientId: oidcConfig.clientId, scopes: [...oidcConfig.scopes] });

createRoot(rootElement).render(
  <StrictMode>
    <AppProviders />
  </StrictMode>
);
```

`theme.css` va **después** del tema de PrimeReact para que sus overrides ganen. No importar otro tema de PrimeReact (p. ej. `aura-*`) ni cambiar el tema base sin ADR.

### 14.2 Cómo `theme.css` sobrescribe a PrimeReact

`theme.css` redefine las CSS variables que expone el tema base, en `:root` y en los bloques dark:

```css
/* Variables que theme.css sobrescribe (extracto, valores por defecto de la semilla) */
--p-primary-500: #E31D4A;                 /* escala --p-primary-50 … --p-primary-950 */
--p-primary-color: var(--acl-brand-primary);
--p-primary-contrast-color: #ffffff;
--p-focus-ring-color: rgba(227, 29, 74, 0.3);
--p-surface-0: #ffffff;                   /* escala --p-surface-* (redefinida en dark) */
--primary-color: #E31D4A;                 /* variables del tema Lara */
--surface-ground: #f9fafb;
--surface-card: #ffffff;
--text-color: #111827;
--text-color-secondary: #6b7280;
```

Como varios de estos valores están en hex literal (no referencian `--acl-brand-*`), al reemplazar la marca hay que actualizarlos también (ver sección 2.1).

### 14.3 Configuración de AppProviders

```tsx
// src/app/providers/app-providers.tsx
export function AppProviders() {
  return (
    <Sentry.ErrorBoundary fallback={<Q2ErrorFallback />}>
      <OidcInitializationGate
        fallback={
          <div className="flex items-center justify-center min-h-screen">
            <Skeleton height="100vh" />
          </div>
        }
      >
        <PrimeReactProvider>
          <QueryClientProvider client={queryClient}>
            <Q1GlobalToast />
            <RouterProvider router={router} />
          </QueryClientProvider>
        </PrimeReactProvider>
      </OidcInitializationGate>
    </Sentry.ErrorBoundary>
  );
}
```

`PrimeReactProvider` no recibe props: los overrides se hacen vía CSS en `theme.css`. No hay provider de tema: el dark mode lo gestiona `useUiStore` (sección 3.2).

---

