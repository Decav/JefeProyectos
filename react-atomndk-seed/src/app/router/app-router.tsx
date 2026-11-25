import { createBrowserRouter, Navigate } from 'react-router-dom';
import { loginRoutes } from '@modules/login';
import { callbackRoutes } from '@modules/callback';

/**
 * Router principal de la semilla.
 *
 * Rutas de negocio: agregarlas como hijas de Q5ProtectedRoute (y de
 * Q3AppShell si usan el layout con sidebar).
 *
 * /login y /callback son rutas top-level — sin Q3AppShell ni layout wrapper.
 * Las guardas de autenticación viven en cada componente:
 *   - PaLogin: si ya autenticado → redirige a /callback
 *   - PaCallback: si no autenticado → redirige a /login
 */
export const router = createBrowserRouter([
  ...loginRoutes,
  ...callbackRoutes,
  { path: '/', element: <Navigate to="/login" replace /> },
  { path: '*', element: <Navigate to="/login" replace /> },
]);
