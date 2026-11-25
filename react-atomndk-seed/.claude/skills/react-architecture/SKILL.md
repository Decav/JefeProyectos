---
name: react-architecture
description: Arquitectura obligatoria React Atomic NDK de la semilla frontend ACL (capas resources/global/library/modules, Atomic Design q1-q5/pa, React Query + Zustand, backendApi). Úsala antes de escribir o revisar cualquier código frontend, y al crear un proyecto nuevo desde la semilla.
---

# React Atomic NDK — Arquitectura de la semilla

Esta es la arquitectura **obligatoria** de todo proyecto creado desde la semilla. Lo específico de cada proyecto (nombre, IdP, marca, backend) vive en `PROJECT.md`; las reglas de este documento no cambian entre proyectos sin un ADR aprobado.

Detalle por tema en `./architecture/` (referencia de la arquitectura) y `./seed/` (cómo se construye la base). Plantillas de código en `./seed/templates/`.

## Seccion 1: Reglas Criticas (INVIOLABLES)

1. UI no llama APIs directamente. Toda llamada HTTP pasa por: `component → hook (React Query) → repository → backendApi`. La capa `service` es opcional y solo existe si hay logica de negocio real (ver Anti-Patrones). Ningun componente importa axios, `backendApi` ni repositorios.
2. `global` no tiene logica de negocio. Sus componentes son configurables por props; no conocen dominios de negocio. Solo importa de `resources`, con una unica excepcion documentada: los re-exports de sesion OIDC en `global/hooks` (`use-auth-status`, `use-logout-mutation`), ver `architecture/01-layers.md`.
3. `library` no tiene JSX. Ningun archivo en `library/` importa React ni renderiza componentes.
4. `resources` es completamente agnostico. Solo TypeScript puro y Zod. Sin React, sin Axios.
5. `modules` orquesta todo. Es la unica capa que combina `library + global + resources` para implementar una feature completa. Los modulos no se importan entre si.
6. **Tests e2e obligatorios**: Todo flujo de auth, navegación, routes protegidas y features visibles requieren tests Playwright en `e2e/*.spec.ts` (ver `architecture/08-testing.md`)
7. **Rutas de negocio protegidas**: toda ruta que requiera sesion se registra como hija de `Q5ProtectedRoute` (sin sesion redirige a `/login`). `OidcInitializationGate` no fuerza login.

---

## Seccion 2: Arbol de Decision

### Dado un archivo nuevo, ¿en que capa va?

```
¿Es un tipo, interface, enum o schema base?
  └─ SI  →  src/resources/

¿Es un componente, store, hook utilitario o util reutilizable sin logica de negocio?
  └─ SI  →  src/global/

¿Es cliente HTTP, repositorio, servicio, mock o integracion externa?
  └─ SI  →  src/library/

¿Es logica de negocio, formulario de dominio, pagina o ruta?
  └─ SI  →  src/modules/{nombre-del-modulo}/
```

### Dado un componente nuevo, ¿que prefijo?

```
¿Es el destino directo de una ruta React Router (element en createBrowserRouter)?
  └─ SI  →  pa

¿Controla un flujo completo o es un guard/layout?
  └─ SI  →  q5

¿Tiene logica de negocio (hooks de dominio, stores, llamadas via mutation/query)?
  └─ SI  →  q4

¿Tiene estado local complejo o multiples interacciones propias?
  └─ SI  →  q3

¿Combina 2-3 atomos con un proposito concreto (campo + label + error)?
  └─ SI  →  q2

¿Es el minimo indivisible (boton, icono, spinner)?
  └─ SI  →  q1
```

---

## Seccion 3: Aliases de Path

| Alias | Ruta Real | Cuando Usar |
|-------|-----------|-------------|
| `@/*` | `src/*` | Imports generales desde raiz de src |
| `@global/*` | `src/global/*` | Componentes, stores, hooks, utils reutilizables |
| `@library/*` | `src/library/*` | Repositories, services (opcional), backendApi, oidc, query, mocks |
| `@modules/*` | `src/modules/*` | Solo desde app/router para importar rutas |
| `@resources/*` | `src/resources/*` | Tipos, interfaces, enums, schemas base |

Los aliases estan definidos en `tsconfig.app.json` (paths) y `vite.config.ts` (resolve.alias). Funcionan automaticamente en tests (Vitest reutiliza la config de Vite).

---

## Seccion 4: Atomic Design

| Prefijo | Nombre | Cuando Usar | Ejemplo Real | Puede Importar |
|---------|--------|-------------|--------------|----------------|
| q1 | Atomo | Componente minimo sin logica de negocio | `q1-button`, `q1-loading-spinner` | librerias UI, @resources |
| q2 | Molecula | Combina 2-3 q1 con proposito concreto | `q2-badge`, `q2-input-field` | q1, @resources |
| q3 | Celula | Unidad con estado local complejo | `q3-stat-card` | q1, q2, @global/hooks, @resources |
| q4 | Organismo | Bloque con logica de negocio completa | `q4-profile-form` | q1-q3, hooks de modulo, @global/store |
| q5 | Ecosistema | Guard, layout o flujo multi-pantalla | `q5-protected-route` | q1-q4, stores, hooks |
| pa | Pagina | Destino de ruta React Router | `pa-login`, `pa-callback` | q4, q5, componentes del modulo |

**Regla:** q4 y pa usan export nombrado, nunca default export.

---

## Seccion 5: Convenciones de Nombres

| Tipo | Patron | Ejemplo |
|------|--------|---------|
| Componente | `{nivel}-{nombre}.tsx` | `q4-profile-form.tsx` |
| Carpeta componente | `{nivel}-{nombre}/` | `q4-profile-form/` |
| Hook query | `use-{nombre}-query.ts` | `use-stats-query.ts` |
| Hook mutation | `use-{nombre}-mutation.ts` | `use-update-profile-mutation.ts` |
| Repository | `{dominio}.repository.ts` | `profile.repository.ts` |
| Service (opcional) | `{dominio}.service.ts` | `profile.service.ts` |
| Store Zustand | `{dominio}.store.ts` | `auth.store.ts` |
| Schema Zod | `{nombre}.schema.ts` | `profile.schema.ts` |
| Handler MSW | `{dominio}.handlers.ts` | `profile.handlers.ts` |
| Entidad | `{nombre}.entity.ts` | `user.entity.ts` |
| Request type | `{dominio}.request.ts` | `profile.request.ts` |
| Response type | `{dominio}.response.ts` | `profile.response.ts` |
| Enum | `{nombre}.enum.ts` | `auth-status.enum.ts` |
| Rutas | `{modulo}.routes.tsx` | `login.routes.tsx` |
| Barrel | `index.ts` | `index.ts` |

**Export nombrado siempre** (no default exports en componentes, hooks, stores ni servicios).

**Funcion export = PascalCase del nombre de archivo:** `q4-profile-form.tsx` → `export function Q4ProfileForm`.

---

## Seccion 6: Estructura de Modulo Nuevo

### Arbol de directorios

```
src/modules/{modulo}/
├── components/
│   ├── q2-{nombre}/          # Moleculas especificas del modulo
│   ├── q4-{nombre}/          # Organismo principal (formulario, tabla)
│   └── pa-{nombre}/          # Pagina(s) enrutables
├── core/
│   ├── hooks/                # use-{nombre}-query.ts, use-{nombre}-mutation.ts
│   ├── schemas/              # {nombre}.schema.ts
│   └── state/                # {dominio}-ui.store.ts (si aplica)
├── routes/
│   └── {modulo}.routes.tsx
└── index.ts                  # Barrel: exporta routes + pa-*
```

### 14 Pasos (resumen)

1. `mkdir -p src/modules/{mod}/{components,core/hooks,core/schemas,core/state,routes}`
2. Crear `src/resources/entities/{entidad}.entity.ts` con `interface`
3. Crear `src/resources/requests/{dominio}.request.ts`
4. Crear `src/modules/{mod}/core/schemas/{nombre}.schema.ts` con `z.object` + `z.infer`
5. Crear `src/library/repositories/{mod}.repository.ts` con `backendApi.get/post/put` tipados
6. Agregar las keys del modulo en `src/library/query/query-keys.ts` (y solo si hay logica de negocio real, `src/library/services/{mod}.service.ts`)
7. Crear `src/modules/{mod}/core/hooks/use-{mod}-query.ts` con `useQuery`
8. Crear `src/modules/{mod}/core/hooks/use-{nombre}-mutation.ts` con `useMutation`
9. Crear componentes q2/q3 si son especificos del modulo
10. Crear `src/modules/{mod}/components/q4-{nombre}/q4-{nombre}.tsx` con RHF + zodResolver
11. Crear `src/modules/{mod}/components/pa-{nombre}/pa-{nombre}.tsx` que renderiza q4
12. Crear `src/modules/{mod}/core/state/{dominio}-ui.store.ts` (si necesita UI state local)
13. Crear `src/library/mocks/handlers/{mod}.handlers.ts` y registrar en `handlers/index.ts`
14. Crear `src/modules/{mod}/routes/{mod}.routes.tsx` y registrar en `app-router.tsx`; crear `src/modules/{mod}/index.ts`

---

## Seccion 7: Patrones de Codigo

### Repository

```ts
// src/library/repositories/profile.repository.ts
import { backendApi } from '@library/api';
import type { UpdateProfileRequest } from '@resources/requests/profile.request';
import type { ProfileResponse } from '@resources/responses/profile.response';

export const ProfileRepository = {
  getProfile: (): Promise<ProfileResponse> =>
    backendApi.get<ProfileResponse>('/api/profile').then((r) => r.data),
  updateProfile: (data: UpdateProfileRequest): Promise<ProfileResponse> =>
    backendApi.put<ProfileResponse>('/api/profile', data).then((r) => r.data),
};
```

### Service (opcional)

Solo cuando hay logica de negocio real (combinar repositorios, aplicar reglas). Un service que solo delega viola YAGNI: en ese caso el hook llama directo al repository.

```ts
// src/library/services/profile.service.ts
import { ProfileRepository } from '@library/repositories/profile.repository';
import type { UpdateProfileRequest } from '@resources/requests/profile.request';

export const ProfileService = {
  updateProfile: (data: UpdateProfileRequest) =>
    ProfileRepository.updateProfile({ ...data, email: data.email.trim().toLowerCase() }),
};
```

### Query Keys

```ts
// src/library/query/query-keys.ts
export const queryKeys = {
  profile: { detail: ['profile', 'detail'] as const },
} as const;
```

### Query Hook

```ts
// src/modules/profile/core/hooks/use-profile-query.ts
import { useQuery } from '@tanstack/react-query';
import { ProfileRepository } from '@library/repositories/profile.repository';
import { queryKeys } from '@library/query/query-keys';

export function useProfileQuery() {
  return useQuery({
    queryKey: queryKeys.profile.detail, // siempre del registry central, nunca literal
    queryFn: ProfileRepository.getProfile,
    staleTime: 30_000,
  });
}
```

### Mutation Hook

```ts
// src/modules/profile/core/hooks/use-update-profile-mutation.ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { ProfileRepository } from '@library/repositories/profile.repository';
import { queryKeys } from '@library/query/query-keys';

export function useUpdateProfileMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ProfileRepository.updateProfile,
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.profile.detail });
    },
  });
}
```

### Componente q4 (Organismo con Formulario)

```tsx
// src/modules/profile/components/q4-profile-form/q4-profile-form.tsx
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { InputText } from 'primereact/inputtext';
import { Q1Button } from '@global/components';
import { profileSchema, type ProfileFormValues } from '../../core/schemas/profile.schema';
import { useUpdateProfileMutation } from '../../core/hooks/use-update-profile-mutation';

export function Q4ProfileForm() {
  const { mutate: updateProfile, isPending, isError } = useUpdateProfileMutation();
  const { control, handleSubmit, formState: { errors } } = useForm<ProfileFormValues>({
    resolver: zodResolver(profileSchema),
    defaultValues: { name: '', email: '' },
  });
  return (
    <form onSubmit={handleSubmit((data) => updateProfile(data))} className="flex flex-col gap-4">
      <Controller name="name" control={control}
        render={({ field }) => <InputText {...field} aria-label="Nombre" />} />
      {errors.name && <p className="text-[var(--acl-danger)]">{errors.name.message}</p>}
      {isError && <p className="text-[var(--acl-danger)]">No pudimos guardar los cambios.</p>}
      <Q1Button type="submit" label="Guardar" loading={isPending} />
    </form>
  );
}
```

> Verifica las props reales de `Q1Button` y los tokens disponibles en `theme.css` antes de copiar el ejemplo.

### Componente pa (Pagina)

```tsx
// src/modules/profile/components/pa-profile/pa-profile.tsx
import { Q4ProfileForm } from '../q4-profile-form/q4-profile-form';

export function PaProfile() {
  return (
    <main className="p-6">
      <div className="acl-card max-w-lg">
        <Q4ProfileForm />
      </div>
    </main>
  );
}
```

### Zustand Store

```ts
// src/global/store/auth.store.ts (incluido en la semilla)
import { create } from 'zustand';
import type { OidcUser } from '@resources/contracts/oidc.contract';

interface AuthState {
  user: OidcUser | null;
  setUser: (user: OidcUser | null) => void;
}

// Store delgado: los tokens y el estado de sesion los gestiona oidc-spa.
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));
```

### MSW Handler

```ts
// src/library/mocks/handlers/profile.handlers.ts
import { http, HttpResponse } from 'msw';
import type { ProfileResponse } from '@resources/responses/profile.response';

export const profileHandlers = [
  http.get('*/api/profile', () => {
    const response: ProfileResponse = { id: '1', name: 'Usuario Demo', email: 'demo@example.com' };
    return HttpResponse.json(response);
  }),
];
// Registrar en src/library/mocks/handlers/index.ts
```

---

## Seccion 8: Estrategia de Testing

| Codigo | Herramienta | Archivo | Que Testear |
|--------|-------------|---------|-------------|
| Componente q1/q2/q3 | Vitest + Testing Library | `*.test.tsx` junto al componente | Render, props, eventos, accesibilidad |
| Componente q4 | Vitest + Testing Library + MSW | `*.test.tsx` junto al componente | Validacion, submit, loading/error |
| Hook useQuery/useMutation | Vitest + renderHook + MSW | `*.test.ts` junto al hook | mutate, isSuccess, isError |
| Store Zustand | Vitest + renderHook | `*.test.ts` junto al store | Estado inicial, acciones, resultado |
| Schema Zod | Vitest | `*.test.ts` junto al schema | safeParse valido/invalido, mensajes |
| Repository/Service | Vitest + MSW | `*.test.ts` junto al archivo | Llamadas correctas, retorno |
| E2E flujo | Playwright | `e2e/{flujo}.spec.ts` | Flujos criticos de usuario |

### Setup de MSW en tests

```ts
// En cada archivo de test de integracion
import { server } from '@library/mocks/server';
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Override de handler para test especifico

```ts
server.use(
  http.get('*/api/profile', () =>
    HttpResponse.json({ detail: 'Sin permisos' }, { status: 403 })
  )
);
```

---

## Seccion 11: Anti-Patrones — Lo que NUNCA debes hacer

Reglas extraídas de las revisiones técnicas de la semilla. Cada una tiene un bug real que causó.

---

### React Hooks

**`useMemo` para side effects — PROHIBIDO**

`useMemo` es solo para cálculos puros. React puede descartarlo y re-ejecutarlo en cualquier momento. En Strict Mode (dev) se ejecuta dos veces, causando condiciones de carrera.

```tsx
// ❌ Antipatrón — useMemo para efectos secundarios
useMemo(() => {
  queryClient.resetQueries({ queryKey: queryKeys.someResource });
}, []);

// ✅ Correcto — useEffect para side effects
useEffect(() => {
  void queryClient.resetQueries({ queryKey: queryKeys.someResource });
}, [queryClient]);
```

**`eslint-disable` sin documentar el invariante — PROHIBIDO**

Un disable sin contexto puede estar ocultando un bug real. Si el disable es correcto, explicar por qué.

```tsx
// ❌ ¿Es un bug o es intencional?
}, []); // eslint-disable-line react-hooks/exhaustive-deps

// ✅ Invariante documentado
// hasRun.current garantiza ejecución única en StrictMode (doble-mount).
// Los valores de closure son estables en el mount inicial del callback.
// eslint-disable-next-line react-hooks/exhaustive-deps
}, []);
```

---

### TypeScript

**Non-null assertion `!` — PROHIBIDO sin guard**

Si alguien refactoriza el código y el valor deja de existir, el error es silencioso en runtime.

```tsx
// ❌ Error silencioso si alguien renombra '/login'
loginRoutes.find((r) => r.path === '/login')!

// ✅ Falla ruidosamente con mensaje descriptivo
const entryRoute = loginRoutes.find((r) => r.path === '/login');
if (!entryRoute) throw new Error('Entry route "/login" not found in loginRoutes');
```

**Type assertion `as` sin type narrowing — PROHIBIDO**

Castear `unknown` directamente a un tipo concreto hace que el tipado mienta.

```typescript
// ❌ Si error no es AxiosError, el tipado miente
const axiosError = error as AxiosError;
return axiosError.response?.status ?? null;

// ✅ Type narrowing real
import { isAxiosError } from 'axios';
if (!isAxiosError(error)) return null;
return error.response?.status ?? null;
```

**`as never` en tests — PROHIBIDO**

Silencia un error de tipo en lugar de corregirlo. El test miente sobre el estado del sistema.

```typescript
// ❌ Silenciar el tipo en un test
useAuthStore.setState({ user: undefined as never });

// ✅ Usar el valor correcto del tipo
useAuthStore.setState({ user: null });
```

**`void variable` para silenciar noUnusedLocals — PROHIBIDO**

Si una variable no se usa, no se desestructura.

```tsx
// ❌ Antipatrón — destructurar algo solo para silenciar el linter
const { isPending, isSuccess, isError } = useSomeQuery();
void isError;

// ✅ Desestructurar solo lo que se usa
const { isPending, isSuccess } = useSomeQuery();
```

**Enums — EVITAR, preferir `as const`**

Los enums generan código JS extra y tienen peor tree-shaking.

```typescript
// ❌ enum innecesario
enum AuthStatus { Idle = 'idle', Authenticated = 'authenticated' }

// ✅ as const — TypeScript nativo, mejor tree-shaking
export const AuthStatus = {
  Idle: 'idle',
  Authenticated: 'authenticated',
  Unauthenticated: 'unauthenticated',
  Loading: 'loading',
} as const;
export type AuthStatus = typeof AuthStatus[keyof typeof AuthStatus];
```

---

### TanStack Query

**Query keys como strings literales — PROHIBIDO**

Sin autocompletado, typo silencioso, las invalidaciones manuales no detectan la key en compilación.

```typescript
// ❌ Literal inline
queryKey: ['profile'],

// ✅ Registry central en src/library/query/query-keys.ts
export const queryKeys = {
  profile: { detail: ['profile', 'detail'] as const },
} as const;

queryKey: queryKeys.profile.detail,
```

**Side effects dentro de `queryFn` — PROHIBIDO**

Si TanStack Query hace refetch automático (staleTime, window focus), el side effect se ejecuta silenciosamente. Si el query se cancela mid-flight, el store queda inconsistente.

```typescript
// ❌ Side effect dentro del fetch
queryFn: async () => {
  const data = await ProfileRepository.getProfile();
  setProfile(data); // se ejecuta en cada refetch automático
  return data;
}

// ✅ Separar fetch de sincronización de estado
const query = useQuery({
  queryKey: queryKeys.profile.detail,
  queryFn: ProfileRepository.getProfile,
});
useEffect(() => {
  if (query.data) setProfile(query.data);
}, [query.data, setProfile]);
```

---

### Axios y API Layer

**Axios sin tipo genérico — PROHIBIDO**

`r.data` infiere como `any`, contaminando el tipado del repositorio.

```typescript
// ❌ r.data es any
archive: (id: string) => backendApi.post(`/api/items/${id}/archive`).then((r) => r.data),

// ✅ Tipo explícito — void cuando el backend no retorna body útil
archive: (id: string): Promise<void> =>
  backendApi.post<void>(`/api/items/${id}/archive`).then(() => undefined),
```

**Tipos de respuesta inline en hooks — PROHIBIDO**

Los tipos de dominio viven en `@resources/responses/`. Si se necesitan en otro componente, no hay dónde importarlos.

```typescript
// ❌ Tipo inline en el hook
interface Profile { id: string; name: string; email: string; }

// ✅ En src/resources/responses/profile.response.ts
export interface ProfileResponse { id: string; name: string; email: string; }
// Re-exportar desde src/resources/responses/index.ts
```

**`console.error` / `console.log` en código de producción — PROHIBIDO**

Usar el interceptor centralizado o Sentry para errores. `console.*` no es estrategia de debugging.

---

### Variables de Entorno

**`vite-env.d.ts` ausente — BLOQUEANTE**

Sin él, `import.meta.env.VITE_*` es `any`. Un typo como `VITE_OIDC_CLIEND_ID` compila sin error.

```typescript
// src/vite-env.d.ts — obligatorio en todo proyecto Vite
/// <reference types="vite/client" />
interface ImportMetaEnv {
  readonly VITE_OIDC_ISSUER_URI: string;
  readonly VITE_OIDC_CLIENT_ID: string;
  readonly VITE_OIDC_PUBLIC_URL: string;
  readonly VITE_API_URL: string;
  readonly VITE_SENTRY_DSN?: string;
  // agregar aquí cada variable nueva del proyecto
}
interface ImportMeta { readonly env: ImportMetaEnv; }
```

**Variables críticas fuera de `REQUIRED_ENV_VARS` — PELIGROSO**

Un fallback silencioso es más peligroso que un error explícito. Si falta `VITE_OIDC_ISSUER_URI`, la app arranca pero el login falla de forma confusa contra el IdP.

```typescript
// ❌ Fallback silencioso
const issuerUri = import.meta.env.VITE_OIDC_ISSUER_URI ?? '';

// ✅ Validar en startup (src/app/main.tsx). Si falta, la app no arranca con mensaje claro.
const REQUIRED_ENV_VARS = ['VITE_OIDC_ISSUER_URI', 'VITE_OIDC_CLIENT_ID', 'VITE_OIDC_PUBLIC_URL'] as const;
```

---

### Design System

**Colores hex hardcodeados en `style={{}}` — PROHIBIDO**

Si cambia la paleta corporativa, hay que buscar en todo el código.

```tsx
// ❌ Inmantenible
style={{ background: 'linear-gradient(135deg, #0f0e17 0%, #1F1D2C 40%)' }}

// ✅ Variable CSS en theme.css — un solo lugar para cambiar
style={{ background: 'var(--acl-hero-bg)' }}
```

**`part[0]` para iniciales de avatar — BUG**

Si el nombre contiene espacios consecutivos, `split` genera strings vacíos y `[0]` retorna `undefined`.

```tsx
// ❌ Bug con espacios consecutivos en el nombre
.map((part) => part[0])

// ✅ charAt retorna '' en strings vacíos; filter elimina los vacíos
.map((part) => part.charAt(0))
.filter(Boolean)
.join('')
```

---

### Capa Service

**Service passthrough sin lógica — VIOLA YAGNI**

Un service que solo delega al repository confunde al equipo: no queda claro cuándo usar Service vs Repository.

```typescript
// ❌ Zero lógica de negocio
export const ProfileService = {
  getProfile: () => ProfileRepository.getProfile(),
};

// ✅ Opción A: Service con lógica real (combina repos, aplica reglas de negocio)
// ✅ Opción B: Eliminar la capa Service hasta que haya lógica que la justifique.
//    Los hooks llaman directo al Repository.
```

---

## Checklist de Revisión Antes de Commit

Antes de hacer commit de cualquier `.tsx` / `.ts`:

- [ ] ¿`useMemo` con side effects? → cambiar a `useEffect`
- [ ] ¿`!` non-null assertion? → agregar guard explícito con `throw` o early return
- [ ] ¿`as TipoConcreto` sin type narrowing? → usar `isAxiosError` u otro type guard
- [ ] ¿`as never` o `as unknown as X`? → corregir el tipo en origen
- [ ] ¿`void variable` para silenciar unused? → eliminar del destructuring
- [ ] ¿Query key como string literal? → mover a `queryKeys` registry en `query-keys.ts`
- [ ] ¿Side effect dentro de `queryFn`? → separar con `useEffect` sobre `query.data`
- [ ] ¿Tipo de respuesta inline en un hook? → mover a `@resources/responses/`
- [ ] ¿`backendApi.get()` o `backendApi.post()` sin genérico `<T>`? → tipar siempre
- [ ] ¿Color hex en `style={{}}` o clases? → token `--acl-*` en `theme.css`
- [ ] ¿`console.error` / `console.log`? → eliminar o reemplazar con Sentry
- [ ] ¿`src/vite-env.d.ts` existe con todas las vars tipadas?
- [ ] ¿Todas las vars críticas en `REQUIRED_ENV_VARS` de `main.tsx`?
- [ ] ¿Comentarios zombie o código `@deprecated`? → eliminar
- [ ] ¿`eslint-disable` sin explicación del invariante? → documentar por qué es seguro

---

## Seccion 9: Referencias Adicionales

- [00-overview.md](architecture/00-overview.md) — Mapa general del proyecto y arbol de directorios
- [01-layers.md](architecture/01-layers.md) — Las 4 capas NDK con ejemplos y reglas de importacion
- [02-atomic-design.md](architecture/02-atomic-design.md) — Niveles q1-q5 y pa con arbol de decision
- [03-stack.md](architecture/03-stack.md) — Tabla de tecnologias con versiones exactas
- [04-patterns.md](architecture/04-patterns.md) — 8 patrones canonicos con snippets reales
- [05-conventions.md](architecture/05-conventions.md) — Nomenclatura completa de archivos
- [06-data-flows.md](architecture/06-data-flows.md) — 5 flujos end-to-end (auth OIDC, query, inicialización, permisos, 401) con diagramas ASCII
- [07-new-module-guide.md](architecture/07-new-module-guide.md) — Guia ejecutable de 14 pasos
- [08-testing.md](architecture/08-testing.md) — Estrategia de testing con snippets
- [09-adrs.md](architecture/09-adrs.md) — 8 ADRs con contexto, decision y consecuencias (incluye OIDC)
- [10-config.md](architecture/10-config.md) — tsconfig, vite, env vars, scripts npm, playwright
- [11-http-error-handling.md](architecture/11-http-error-handling.md) — Skeleton en carga, interceptor 401 global, componente Q2Forbidden para 403
- [12-design-system.md](architecture/12-design-system.md) — Estandar de diseno: tokens, dark mode, PrimeReact overrides, patrones UI (valores de marca por proyecto)

---

## Seccion 10: Design System (estructura fija, marca por proyecto)

La **estructura** del design system es parte de la arquitectura y no cambia: tokens CSS `--acl-*` en `src/styles/theme.css`, clases utilitarias `.acl-*`, PrimeReact sobrescrito via CSS variables y dark mode por `data-theme`. Los **valores de marca** (colores, tipografía, logo) se definen por proyecto en `PROJECT.md` y se aplican en `theme.css`. El prefijo `--acl-` se mantiene en todos los proyectos para que los componentes de la semilla sigan funcionando.

### Tokens de marca (valores por proyecto)

| Token | Valor por defecto de la semilla (ACL) | Uso |
|-------|---------------------------------------|-----|
| `--acl-brand-primary` | `#E31D4A` | CTAs, highlights, elementos activos |
| `--acl-brand-secondary` | `#5135A1` | Botones outline, acentos secundarios |
| `--acl-brand-gradient` | gradiente de `primary` | Botones primarios, KPI headers |
| `--acl-font-family` | `"Poppins", system-ui, sans-serif` | Tipografía base |

Al crear un proyecto, reemplazar estos valores con los de `PROJECT.md` (sección Marca). Los colores de marca **no cambian** en dark mode.

### Reglas criticas del Design System

1. **Tokens primero:** Todos los colores y espaciados usan variables `--acl-*` de `theme.css`. Ningun valor hex hardcodeado en componentes.
2. **Clases utilitarias para patrones recurrentes:** Usar `.acl-card`, `.acl-badge-{color}`, `.acl-btn-primary`, `.acl-kpi-card` en lugar de reinventar estilos.
3. **Dark mode automatico:** Si un componente usa solo variables `--acl-*`, hereda el dark mode gratis. Si hardcodea colores, rompe el dark mode.
4. **Sidebar:** usa `--acl-sidebar-bg` y no cambia con el tema.
5. **PrimeReact override via CSS:** Las customizaciones de PrimeReact se hacen en `theme.css` via CSS variables, no con props inline ni CSS-in-JS.
6. **Cambiar la estructura** (nuevos prefijos de token, otra librería UI, CSS-in-JS) requiere ADR.

### Dark mode — implementacion

```ts
// Forzar dark mode
document.documentElement.setAttribute('data-theme', 'dark');
// Forzar light mode
document.documentElement.setAttribute('data-theme', 'light');
// Seguir el sistema operativo
document.documentElement.removeAttribute('data-theme');
```

### PrimeReact preset

El preset de PrimeReact se customiza **via CSS variables** en `theme.css`, no en el objeto del Provider. Las variables clave (estado actual de la semilla):

```css
--p-primary-color: var(--acl-brand-primary);
--p-primary-contrast-color: #ffffff;
--p-focus-ring-color: rgba(227, 29, 74, 0.3); /* derivado del primary: actualizar al cambiar la marca */
```

Al cambiar la marca, revisar también los valores literales derivados del color primario en `theme.css` (no todos están expresados con tokens).

No usar `definePreset()` a menos que se necesite un override profundo de tokens JS. El CSS override es suficiente para el 95% de los casos.

### Z-index layers (no sobrescribir sin coordinacion)

| Capa | Valor | Uso |
|------|-------|-----|
| Sidebar | 50 | Navegacion lateral |
| Modal/Dialog | 200 | Dialogs y drawers de PrimeReact |
| Toast | 300 | Notificaciones toast |
| Tooltip | 400 | Tooltips (siempre encima de todo) |

## Reglas de manejo de estados de carga y errores HTTP

### Regla 1: Skeleton en estados de carga (isLoading)
- Mientras `isLoading === true`, el componente DEBE renderizar `<Skeleton>` de PrimeReact.
- Usar dimensiones aproximadas al contenido real para evitar layout shift.
- NUNCA usar spinners custom ni componentes vacios — usar `<Skeleton>` de PrimeReact siempre.
- Para listas: renderizar N instancias de `<Skeleton>` que emulen los items esperados.

```tsx
import { Skeleton } from 'primereact/skeleton';
if (isLoading) return <Skeleton height="3rem" />;
```

### Regla 2: Error 401 → Manejo global via interceptores
- `refresh-retry.interceptor.ts` reintenta una vez renovando tokens con `oidc-spa`.
- Si el 401 persiste, `error.interceptor.ts` ejecuta `oidc.logout()` (solo si hay sesion activa, para evitar loops) y el usuario vuelve al IdP.
- Esta logica NO debe duplicarse en componentes individuales.

### Regla 3: Error 403 → Componente Q2Forbidden inline (nivel componente, no pantalla)
- Un 403 NO redirige — el usuario sigue autenticado pero sin permiso para ese recurso.
- Usar `getHttpStatus(error)` (`@global/utils`) para obtener el status.
- Cuando el status es `403`, renderizar `<Q2Forbidden />` inline en lugar del contenido normal.
- `Q2Forbidden` es un componente q2 en `src/global/components/q2-forbidden/`.
- NUNCA usar `navigate('/forbidden')` ni bloquear la pantalla completa.

```tsx
if (getHttpStatus(error) === 403) return <Q2Forbidden />;
```

### Patron completo (loading + 403 + render normal)
```tsx
const { data, isLoading, error } = useAlgunaQuery();

if (isLoading) return <Skeleton height="10rem" />;
if (getHttpStatus(error) === 403) return <Q2Forbidden />;
// render normal con data
```

Ver referencia completa con snippets y tabla de responsabilidades: [11-http-error-handling.md](architecture/11-http-error-handling.md)
