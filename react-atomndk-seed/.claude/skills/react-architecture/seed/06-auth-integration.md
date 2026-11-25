# 06 — Autenticación en React

> **Implementación por defecto de la semilla: OIDC con `oidc-spa`.** La semilla ya trae resuelta la autenticación con `oidc-spa` v10 (Authorization Code + PKCE) contra un proveedor OIDC (por defecto Authentik; el IdP concreto, issuer, client ID y scopes van en `PROJECT.md`). Código en `src/library/oidc/`:
>
> - `oidc-instance.ts` → `useOidc`, `getOidc`, `bootstrapOidc`, `OidcInitializationGate` (vía `oidcSpa.createUtils()`).
> - `oidc-config.ts` → `issuerUri`, `clientId`, `publicUrl` desde `VITE_OIDC_*` y scopes `openid profile email groups permissions`.
> - `use-auth-status.ts` → `useAuthStatus(): { isAuthenticated, user: OidcUser | null }` (user derivado del ID token).
> - `use-logout-mutation.ts` → `useLogoutMutation()`: `queryClient.clear()` + `oidc.logout(...)`.
>
> `main.tsx` llama `bootstrapOidc(...)` antes de montar; `AppProviders` envuelve la app en `OidcInitializationGate`; los módulos `login` (`PaLogin` → `oidc.login()`) y `callback` (`PaCallback`) implementan el flujo. `backendApi` inyecta el Bearer, reintenta una vez con `renewTokens()` ante 401 y hace `oidc.logout()` si el 401 persiste (ver `../architecture/11-http-error-handling.md`). Tokens y sesión los gestiona `oidc-spa`; `useAuthStore` es un store delgado (`user` / `setUser`) sin tokens. Roles: `usePermissions()` y `<Q5Authorized>`.
>
> Los patrones siguientes (store con `isAuthenticated`, cookies httpOnly, JWT propio, etc.) son **alternativas genéricas**: usarlas en lugar de OIDC requiere un ADR aprobado (registrado en `PROJECT.md`, sección 8).

Este archivo describe cómo integrar autenticación en una aplicación React usando el stack NDK. El mecanismo de autenticación concreto (cookies httpOnly, JWT en header, sesiones, OAuth2, etc.) lo decide el proyecto. Este documento cubre los patrones reutilizables independientes del backend.

---

## Auth Store con Zustand

El estado de sesión vive en un store global. El desarrollador decide cuándo y cómo poblarlo.

```typescript
// src/global/stores/auth.store.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface User {
  id: string;
  name: string;
  email: string;
  roles: string[];
}

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  setUser: (user: User) => void;
  clearUser: () => void;
}

export const useAuthStore = create<AuthState>()(
  devtools(
    (set) => ({
      user: null,
      isAuthenticated: false,

      setUser: (user) =>
        set({ user, isAuthenticated: true }, false, 'auth/setUser'),

      clearUser: () =>
        set({ user: null, isAuthenticated: false }, false, 'auth/clearUser'),
    }),
    { name: 'AuthStore' }
  )
);

export const selectUser = (state: AuthState) => state.user;
export const selectIsAuthenticated = (state: AuthState) => state.isAuthenticated;
```

---

## Protected Route Pattern

```typescript
// src/app/router/protected-route.tsx
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuthStore, selectIsAuthenticated } from '@global/stores/auth.store';

interface ProtectedRouteProps {
  redirectTo?: string;
  requiredRoles?: string[];
}

export function ProtectedRoute({
  redirectTo = '/login',
  requiredRoles = [],
}: ProtectedRouteProps) {
  const location = useLocation();
  const isAuthenticated = useAuthStore(selectIsAuthenticated);
  const user = useAuthStore((state) => state.user);

  if (!isAuthenticated) {
    return <Navigate to={redirectTo} state={{ from: location }} replace />;
  }

  if (requiredRoles.length > 0 && user) {
    const hasRole = requiredRoles.some((role) => user.roles.includes(role));
    if (!hasRole) {
      return <Navigate to="/unauthorized" replace />;
    }
  }

  return <Outlet />;
}
```

---

## Configuración del cliente HTTP

### Opción A: Backend usa cookies httpOnly

Si el backend emite una cookie httpOnly, el navegador la envía automáticamente. Solo se necesita `withCredentials: true`:

```typescript
// src/library/api/axios.instance.ts
import axios from 'axios';

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  withCredentials: true, // el navegador incluye la cookie en cada request
});
```

### Opción B: Backend usa JWT en Authorization header

Si el backend devuelve un token JWT que el frontend debe almacenar y enviar:

```typescript
// src/library/api/axios.instance.ts
import axios from 'axios';
import { useAuthStore } from '@global/stores/auth.store';

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
});

// Adjuntar el token en cada request
apiClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token; // si guardas el token en el store
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

---

## Interceptor de respuesta para 401

```typescript
// src/library/api/axios.instance.ts (continuación)
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Sesión expirada o no válida
      useAuthStore.getState().clearUser();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

---

## Verificar sesión al arrancar la app

El hook `useSessionInit` se llama en el componente raíz para restaurar la sesión activa si existe.

```typescript
// src/app/hooks/use-session-init.ts
import { useEffect } from 'react';
import { useAuthStore } from '@global/stores/auth.store';
import { authRepository } from '@library/repositories/auth.repository';

export function useSessionInit() {
  const setUser = useAuthStore((state) => state.setUser);

  useEffect(() => {
    // Llama al endpoint de tu backend que verifica la sesión activa
    authRepository
      .getCurrentUser()
      .then(setUser)
      .catch(() => {
        // No hay sesión activa — el usuario está deslogueado
        // No redirigir aquí; dejar que el router lo maneje
      });
  }, [setUser]);
}
```

El repositorio de auth implementa la llamada al backend. El contrato depende del mecanismo elegido:

```typescript
// src/library/repositories/auth.repository.ts
import { apiClient } from '../api/axios.instance';
import type { User } from '@resources/entities/user.entity';

export const authRepository = {
  // Adapta el endpoint al contrato real de tu backend
  async getCurrentUser(): Promise<User> {
    const { data } = await apiClient.get<User>('/auth/me');
    return data;
  },

  async logout(): Promise<void> {
    await apiClient.post('/auth/logout');
  },
};
```

---

## Configuración del router con rutas protegidas

```typescript
// src/app/router.tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { ProtectedRoute } from './router/protected-route';
import { Q5LoginPage } from '@modules/auth/components/q5-login-page/q5-login-page';
import { Q5DashboardPage } from '@modules/dashboard/components/q5-dashboard-page/q5-dashboard-page';

export const router = createBrowserRouter([
  // Rutas públicas
  { path: '/login', element: <Q5LoginPage /> },

  // Rutas protegidas
  {
    element: <ProtectedRoute />,
    children: [
      { path: '/dashboard', element: <Q5DashboardPage /> },
    ],
  },

  // Redirigir raíz
  { path: '/', element: <Navigate to="/dashboard" replace /> },
]);
```

---

## Variables de entorno

Solo necesitas la URL base de tu API. El resto depende del mecanismo de auth elegido:

```bash
# .env.example
VITE_API_BASE_URL=http://localhost:3000
VITE_APP_ENV=development
```

Si tu proyecto requiere variables adicionales de autenticación (client IDs, redirect URIs, etc.), agrégalas según el mecanismo que elijas.
