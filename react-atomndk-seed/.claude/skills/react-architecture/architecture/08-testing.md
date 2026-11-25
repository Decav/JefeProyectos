## Regla Obligatoria: Tests E2E

Los tests e2e son OBLIGATORIOS en todo cambio que involucre:
- Flujos de autenticación (login OIDC, logout, callback, sesión)
- Rutas protegidas (guards, redirects)
- Navegación entre páginas
- Integración con servicios externos (proveedor OIDC, endpoints REST)
- Cualquier feature visible para el usuario final

**Herramienta:** Playwright (`e2e/` directory, config: `playwright.config.ts`, `baseURL` por defecto `http://localhost:5151`)

**Cobertura mínima por feature:**
- Happy path completo (flujo exitoso end-to-end)
- Error path principal (qué pasa cuando falla)
- Estado no autenticado vs autenticado
- Redirects y guards de rutas
- CSRF/seguridad si aplica

**Convenciones:**
- Mockear APIs del backend con `page.route()` — no depender del servidor real en tests
- Usar `page.evaluate()` para manipular sessionStorage/localStorage
- Usar `expect(page).toHaveURL()` en lugar de `page.waitForNavigation()` (deprecado)
- Organizar en `e2e/*.spec.ts` por módulo/feature

**No se considera una implementación completa sin tests e2e.**

---

# Estrategia de Testing

Testing por capas con herramientas específicas. Vitest integrado en `vite.config.ts`, Testing Library para componentes, MSW para HTTP, `vi.mock` para aislar OIDC y Playwright para e2e.

---

## Tabla: Tipo de Código → Herramienta → Qué Testear

| Tipo de Código | Herramienta | Archivo de Test | Qué Testear |
|---------------|-------------|-----------------|-------------|
| Componente q1/q2/q3 | Vitest + Testing Library | `*.test.tsx` junto al componente | Renderizado, props, eventos de usuario, accesibilidad |
| Componente q4 (formulario) | Vitest + Testing Library + MSW | `*.test.tsx` junto al componente | Validación de campos, submit, estados loading/error/403 |
| Página pa | Vitest + Testing Library (+ MSW si consulta datos) | `*.test.tsx` junto al componente | Integración de componentes, guardas, flujo completo |
| Componente o hook que usa OIDC | Vitest + Testing Library + `vi.mock('@library/oidc')` | `*.test.tsx` / `*.test.ts` junto al archivo | Estado autenticado vs no autenticado, login/logout invocados |
| Hook useQuery | Vitest + renderHook + MSW | `*.test.ts` junto al hook | data, isLoading, error con API mockeada |
| Hook useMutation | Vitest + renderHook + MSW | `*.test.ts` junto al hook | mutate, isSuccess, isError, invalidaciones |
| Store Zustand | Vitest + renderHook | `*.test.ts` junto al store | Estado inicial, acciones, estado resultante |
| Schema Zod | Vitest | `*.test.ts` junto al schema | Validaciones válidas, inválidas, mensajes de error |
| Repository | Vitest + MSW | `*.test.ts` junto al repositorio | Llamadas correctas, retorno de data |
| Service (solo si existe) | Vitest + MSW o `vi.mock` del repository | `*.test.ts` junto al servicio | La lógica de negocio que justifica su existencia |
| Interceptor HTTP | Vitest + `vi.mock('@library/oidc')` | `*.test.ts` junto al interceptor | Header Bearer, reintento en 401, logout |
| E2E flujo crítico | Playwright | `e2e/{flujo}.spec.ts` | Flujos de usuario reales en browser real |

---

## Cobertura por Capa

| Capa | Objetivo | Tipo de Test |
|------|----------|-------------|
| `resources` | 100% | Unit: schemas Zod y utilidades puras (ej.: `has-permission.ts`) |
| `global` | 80%+ | Unit de stores, hooks y utils; Unit + Integration de componentes |
| `library` | 70%+ | Unit de interceptores y oidc (con `vi.mock`); repositories/services con MSW |
| `modules` | 60%+ | Integration de hooks, formularios q4 y páginas pa |

```bash
npm run test:coverage   # genera reporte HTML en coverage/
```

---

## Setup de Tests

**`src/test/setup.ts`** solo importa `@testing-library/jest-dom` (matchers adicionales). Vitest corre con `globals: true`, por lo que `describe`, `it`, `expect` y `vi` están disponibles sin importarlos.

**MSW no se arranca globalmente.** Cada archivo de test que necesite HTTP mockeado levanta el server de `src/library/mocks/server.ts` (que usa los `handlers` registrados en `src/library/mocks/handlers/index.ts`):

```ts
import { server } from '@library/mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

**OIDC no se inicializa en tests.** `bootstrapOidc` solo se llama en `main.tsx`, así que todo código que dependa de `@library/oidc` (componentes, hooks, interceptores de `backendApi`) se testea con `vi.mock('@library/oidc', ...)`. Es el patrón que usan los tests existentes (`token.interceptor.test.ts`, `error.interceptor.test.ts`, `refresh-retry.interceptor.test.ts`).

---

## Snippets por Tipo de Test

### 1. Unit Test de Componente React (Testing Library)

**Real del proyecto:** `src/global/components/q1-button/q1-button.test.tsx`

```tsx
import { render, screen } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';
import { Q1Button } from './q1-button';

describe('Q1Button', () => {
  it('renders label', () => {
    render(<Q1Button label="Hola" />);
    expect(screen.getByText('Hola')).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const onClick = vi.fn();
    render(<Q1Button label="Click" onClick={onClick} />);
    await userEvent.click(screen.getByText('Click'));
    expect(onClick).toHaveBeenCalledOnce();
  });

  it('is disabled when loading', () => {
    render(<Q1Button label="Loading" loading />);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

**Principio:** testea comportamiento visible, no implementación interna. Otros ejemplos reales: `q2-forbidden.test.tsx` (mockea `useNavigate`), `q5-authorized.test.tsx` (mockea `usePermissions`).

---

### 2. Unit Test de Schema Zod

**Patrón (módulo nuevo):** `src/modules/profile/core/schemas/profile.schema.test.ts`

```ts
import { profileSchema } from './profile.schema';

describe('profileSchema', () => {
  it('acepta datos válidos', () => {
    const result = profileSchema.safeParse({ name: 'Usuario Demo', email: 'demo@example.com' });
    expect(result.success).toBe(true);
  });

  it('rechaza nombre vacío', () => {
    const result = profileSchema.safeParse({ name: '', email: 'demo@example.com' });
    expect(result.success).toBe(false);
    expect(result.error?.issues[0]?.message).toBe('El nombre es obligatorio');
  });

  it('rechaza email inválido', () => {
    const result = profileSchema.safeParse({ name: 'Usuario Demo', email: 'no-es-email' });
    expect(result.success).toBe(false);
  });
});
```

---

### 3. Unit Test de Store Zustand

**Real del proyecto:** `src/global/store/ui.store.test.ts` (extracto)

```ts
import { renderHook, act } from '@testing-library/react';
import { useUiStore } from './ui.store';

describe('useUiStore', () => {
  beforeEach(() => {
    localStorage.clear();
    document.documentElement.removeAttribute('data-theme');
    useUiStore.setState({ sidebarOpen: false, theme: 'system' });
  });

  it('setSidebarOpen updates sidebarOpen', () => {
    const { result } = renderHook(() => useUiStore());
    act(() => result.current.setSidebarOpen(true));
    expect(result.current.sidebarOpen).toBe(true);
  });

  it('setTheme("dark") sets data-theme="dark" and persists to localStorage', () => {
    const { result } = renderHook(() => useUiStore());
    act(() => result.current.setTheme('dark'));
    expect(result.current.theme).toBe('dark');
    expect(document.documentElement.getAttribute('data-theme')).toBe('dark');
    expect(localStorage.getItem('acl-theme')).toBe('dark');
  });
});
```

**Real del proyecto:** `src/global/store/auth.store.test.ts` (extracto) — store delgado, sin tokens

```ts
import { renderHook, act } from '@testing-library/react';
import { useAuthStore } from './auth.store';
import type { OidcUser } from '@resources/contracts/oidc.contract';

const mockUser: OidcUser = { sub: 'user-123', email: 'user@test.com', name: 'Test User' };

describe('useAuthStore', () => {
  beforeEach(() => {
    useAuthStore.setState({ user: null });
  });

  it('setUser populates user data', () => {
    const { result } = renderHook(() => useAuthStore());
    act(() => result.current.setUser(mockUser));
    expect(result.current.user?.sub).toBe('user-123');
  });

  it('setUser(null) clears user', () => {
    const { result } = renderHook(() => useAuthStore());
    act(() => result.current.setUser(mockUser));
    act(() => result.current.setUser(null));
    expect(result.current.user).toBeNull();
  });
});
```

---

### 4. Test de Hook con renderHook y MSW

**Patrón (módulo nuevo):** `src/modules/profile/core/hooks/use-profile-query.test.ts`

Requiere el handler `profileHandlers` (`http.get('*/api/profile', ...)`) registrado en `src/library/mocks/handlers/index.ts` (ver [04-patterns.md](04-patterns.md#8-msw-handler)).

```ts
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { createElement, type ReactNode } from 'react';
import { http, HttpResponse } from 'msw';
import { server } from '@library/mocks/server';
import { useProfileQuery } from './use-profile-query';

// backendApi registra token.interceptor, que llama a getOidc().
// En tests OIDC no está inicializado: se simula una sesión anónima.
vi.mock('@library/oidc', () => ({
  getOidc: () => Promise.resolve({ isUserLoggedIn: false }),
}));

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

function wrapper({ children }: { children: ReactNode }) {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return createElement(QueryClientProvider, { client: qc }, children);
}

describe('useProfileQuery', () => {
  it('retorna el perfil desde la API', async () => {
    const { result } = renderHook(() => useProfileQuery(), { wrapper });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.email).toBe('demo@example.com');
  });

  it('expone el error cuando la API responde 500', async () => {
    server.use(http.get('*/api/profile', () => HttpResponse.json({ detail: 'Error' }, { status: 500 })));
    const { result } = renderHook(() => useProfileQuery(), { wrapper });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});
```

---

### 5. Test de Componente q4 con MSW (Integration)

**Patrón (módulo nuevo):** `src/modules/profile/components/q4-profile-form/q4-profile-form.test.tsx`

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { server } from '@library/mocks/server';
import { Q4ProfileForm } from './q4-profile-form';

vi.mock('@library/oidc', () => ({
  getOidc: () => Promise.resolve({ isUserLoggedIn: false }),
}));

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

function renderForm() {
  const qc = new QueryClient({ defaultOptions: { mutations: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <Q4ProfileForm />
    </QueryClientProvider>
  );
}

describe('Q4ProfileForm', () => {
  it('renderiza los campos', () => {
    renderForm();
    expect(screen.getByLabelText(/nombre/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/correo/i)).toBeInTheDocument();
  });

  it('muestra errores de validación al enviar vacío', async () => {
    renderForm();
    await userEvent.click(screen.getByRole('button', { name: /guardar/i }));
    await waitFor(() => {
      expect(screen.getByText(/el nombre es obligatorio/i)).toBeInTheDocument();
    });
  });

  it('envía con datos válidos sin mostrar error', async () => {
    renderForm();
    await userEvent.type(screen.getByLabelText(/nombre/i), 'Usuario Demo');
    await userEvent.type(screen.getByLabelText(/correo/i), 'demo@example.com');
    await userEvent.click(screen.getByRole('button', { name: /guardar/i }));
    await waitFor(() => {
      expect(screen.queryByText(/no pudimos guardar/i)).not.toBeInTheDocument();
    });
  });
});
```

---

### 6. Test con Override de MSW Handler (error y 403)

Para testear estados de error específicos, se sobreescribe un handler solo para ese test:

```tsx
import { http, HttpResponse } from 'msw';
import { server } from '@library/mocks/server';

it('muestra error si el backend falla al guardar', async () => {
  server.use(
    http.put('*/api/profile', () => HttpResponse.json({ detail: 'Error' }, { status: 500 }))
  );
  renderForm();
  await userEvent.type(screen.getByLabelText(/nombre/i), 'Usuario Demo');
  await userEvent.type(screen.getByLabelText(/correo/i), 'demo@example.com');
  await userEvent.click(screen.getByRole('button', { name: /guardar/i }));
  await waitFor(() => {
    expect(screen.getByText(/no pudimos guardar los cambios/i)).toBeInTheDocument();
  });
});
```

Para un componente que aplica `getHttpStatus(error) === 403` (ej.: `Q4ProfileDetail` de [04-patterns.md](04-patterns.md#11-error-403--componente-q2forbidden-inline)), se fuerza un 403 y se verifica `Q2Forbidden`. Como `Q2Forbidden` usa `useNavigate`, el render debe incluir un `MemoryRouter`:

```tsx
it('muestra Q2Forbidden ante un 403', async () => {
  server.use(
    http.get('*/api/profile', () => HttpResponse.json({ detail: 'Sin permisos' }, { status: 403 }))
  );
  render(
    <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
      <MemoryRouter>
        <Q4ProfileDetail />
      </MemoryRouter>
    </QueryClientProvider>
  );
  expect(await screen.findByText(/no estás autorizado para ver esto/i)).toBeInTheDocument();
});
```

---

### 7. Test de Componente que usa OIDC (mock de `@library/oidc`)

Los componentes no se testean contra un IdP real: se mockean `useOidc`, `useAuthStatus` y `useLogoutMutation` con `vi.mock`. El patrón es el de `src/library/oidc/use-auth-status.test.ts` y de los tests de interceptores: un `vi.fn()` a nivel de módulo que cada test configura con `mockReturnValue`.

**Patrón sobre componente real:** `src/modules/callback/components/pa-callback/pa-callback.test.tsx`

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { PaCallback } from './pa-callback';

const useAuthStatusMock = vi.fn();
const mockLogout = vi.fn();

vi.mock('@library/oidc', () => ({
  useAuthStatus: (...args: unknown[]) => useAuthStatusMock(...args),
  useLogoutMutation: () => ({ mutate: mockLogout, isPending: false }),
}));

function renderAt(path: string) {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <Routes>
        <Route path="/callback" element={<PaCallback />} />
        <Route path="/login" element={<div>Página de login</div>} />
      </Routes>
    </MemoryRouter>
  );
}

describe('PaCallback', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('redirige a /login si no hay sesión', () => {
    useAuthStatusMock.mockReturnValue({ isAuthenticated: false, user: null });
    renderAt('/callback');
    expect(screen.getByText('Página de login')).toBeInTheDocument();
  });

  it('muestra los claims y permite cerrar sesión', async () => {
    useAuthStatusMock.mockReturnValue({
      isAuthenticated: true,
      user: { sub: 'user-001', email: 'user@example.com', name: 'Usuario Demo' },
    });
    renderAt('/callback');
    expect(screen.getByText('user@example.com')).toBeInTheDocument();

    await userEvent.click(screen.getByRole('button', { name: /cerrar sesión/i }));
    expect(mockLogout).toHaveBeenCalledOnce();
  });
});
```

**Patrón sobre componente real:** `src/modules/login/components/pa-login/pa-login.test.tsx` (mock de `useOidc`)

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { PaLogin } from './pa-login';

const mockUseOidc = vi.fn();

vi.mock('@library/oidc', () => ({
  useOidc: (...args: unknown[]) => mockUseOidc(...args),
}));

function renderLogin() {
  return render(
    <MemoryRouter initialEntries={['/login']}>
      <Routes>
        <Route path="/login" element={<PaLogin />} />
        <Route path="/callback" element={<div>Callback</div>} />
      </Routes>
    </MemoryRouter>
  );
}

describe('PaLogin', () => {
  it('inicia el login OIDC al hacer clic en el botón', async () => {
    const login = vi.fn();
    mockUseOidc.mockReturnValue({ isUserLoggedIn: false, login });
    renderLogin();
    await userEvent.click(screen.getByRole('button', { name: /ingresar/i }));
    expect(login).toHaveBeenCalledWith({ doesCurrentHrefRequiresAuth: false });
  });

  it('redirige a /callback si ya hay sesión', () => {
    mockUseOidc.mockReturnValue({ isUserLoggedIn: true });
    renderLogin();
    expect(screen.getByText('Callback')).toBeInTheDocument();
  });
});
```

> Si el componente consume los hooks a través de `@global/hooks` (re-exports de `@library/oidc`), se mockea ese path, como hace `q3-app-shell.test.tsx` con `@global/hooks/use-auth-status`. Para permisos, mockear `usePermissions` (ver `q5-authorized.test.tsx`).

---

### 8. Test E2E con Playwright

**Ruta:** `e2e/auth.spec.ts`

El dev server (`npm run dev`, puerto 5151) ejecuta `bootstrapOidc` al arrancar, por lo que los e2e necesitan un `.env` con `VITE_OIDC_*` apuntando a un proveedor OIDC de desarrollo alcanzable. Las llamadas al backend se mockean con `page.route()`.

```ts
import { test, expect } from '@playwright/test';

test('la raíz redirige a /login', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveURL(/\/login$/);
});

test('/callback sin sesión redirige a /login', async ({ page }) => {
  await page.goto('/callback');
  await expect(page).toHaveURL(/\/login$/);
});

test('el botón de ingreso redirige al proveedor OIDC (Authorization Code + PKCE)', async ({ page }) => {
  await page.goto('/login');
  await page.getByRole('button', { name: /ingresar/i }).click();
  await page.waitForURL((url) => url.searchParams.get('response_type') === 'code');
  const authorizeUrl = new URL(page.url());
  expect(authorizeUrl.searchParams.get('code_challenge_method')).toBe('S256');
});
```

Los flujos autenticados (callback con claims, logout) requieren un usuario de prueba en el IdP de desarrollo, con credenciales en variables de entorno del runner (nunca en el repo). El formulario de login pertenece al IdP, no a la app.

---

## Configuración de Vitest (en vite.config.ts)

```ts
test: {
  globals: true,
  environment: 'jsdom',
  passWithNoTests: true,
  setupFiles: ['./src/test/setup.ts'],
  exclude: ['**/node_modules/**', '**/dist/**', 'e2e/**'],
  coverage: {
    provider: 'v8',
    reporter: ['text', 'json', 'html'],
    include: ['src/**/*.{ts,tsx}'],
    exclude: ['src/test/**', 'src/**/*.stories.tsx', 'src/app/main.tsx'],
  },
},
```

**Beneficio clave:** los path aliases `@global`, `@library`, etc. funcionan automáticamente en tests sin configuración adicional.
