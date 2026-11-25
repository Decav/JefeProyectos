import type { AxiosInstance, AxiosError } from 'axios';
import { getOidc } from '@library/oidc';

/**
 * Registra el interceptor de error en una instancia axios.
 *
 * En 401: ejecuta oidc.logout() para limpiar sesión y redirigir al proveedor OIDC.
 *         oidc-spa habrá intentado refresh antes de llegar aquí, por lo que
 *         un 401 indica token genuinamente inválido.
 *
 * En 403: propaga el error — los componentes lo manejan con getHttpStatus(error) === 403 + Q2Forbidden.
 *
 * ANTIPATRÓN evitado: ya NO importa de @global/ (violación NDK anterior).
 * getOidc() vive en @library/oidc — capa correcta.
 *
 * Mitigación loop logout: verifica oidc.isUserLoggedIn antes de llamar logout.
 */
export function registerErrorInterceptor(instance: AxiosInstance): void {
  instance.interceptors.response.use(
    (response) => response,
    async (error: AxiosError) => {
      if (error.response?.status === 401) {
        try {
          const oidc = await getOidc();
          if (oidc.isUserLoggedIn) {
            await oidc.logout({ redirectTo: 'home' });
          }
        } catch {
          // getOidc falló — propagar el error original
        }
      }
      return Promise.reject(error);
    }
  );
}
