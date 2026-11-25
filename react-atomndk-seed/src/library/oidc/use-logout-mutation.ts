import { useMutation, useQueryClient } from '@tanstack/react-query';
import { getOidc } from './oidc-instance';

/**
 * Logout mutation.
 * Limpia el cache de TanStack Query PRIMERO, luego ejecuta oidc.logout()
 * para el end-session contra Authentik.
 *
 * ORDEN CRÍTICO: queryClient.clear() ANTES de logout() para evitar
 * re-fetches con token ya inválido en componentes aún montados.
 */
export function useLogoutMutation() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (): Promise<void> => Promise.resolve(),
    onSuccess: async () => {
      // 1. Limpiar cache PRIMERO
      queryClient.clear();
      // 2. oidc-spa maneja el end-session contra el proveedor OIDC
      const oidc = await getOidc();
      if (oidc.isUserLoggedIn) {
        // redirectTo: 'specific url' con url relativa → redirige a /login post-logout
        // El post-logout redirect URI debe estar registrado en el IdP:
        //   {VITE_OIDC_PUBLIC_URL}/login (local: http://localhost:5151/login)
        await oidc.logout({ redirectTo: 'specific url', url: `${window.location.origin}/login` });
      }
    },
  });
}
