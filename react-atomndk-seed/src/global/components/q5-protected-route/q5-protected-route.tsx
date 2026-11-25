import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuthStatus } from '@global/hooks/use-auth-status';

/**
 * Guarda de sesión para un grupo de rutas.
 *
 * - Con sesión OIDC activa → renderiza las rutas hijas (<Outlet />).
 * - Sin sesión → redirige a /login (la semilla no usa autoLogin de oidc-spa).
 *
 * Para restringir por rol dentro de una ruta protegida, envolver el contenido
 * con <Q5Authorized requiredRole={...} fallback={<Q2Forbidden />}>.
 *
 * Uso en el router:
 *   { element: <Q5ProtectedRoute />, children: [...rutasDeNegocio] }
 */
export function Q5ProtectedRoute() {
  const { isAuthenticated } = useAuthStatus();
  const location = useLocation();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }

  return <Outlet />;
}
