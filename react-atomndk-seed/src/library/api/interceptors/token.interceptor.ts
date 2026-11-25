import type { AxiosInstance } from 'axios';
import { getOidc } from '@library/oidc';

/**
 * Registra el interceptor de request que inyecta el Bearer token en cada llamada.
 * Usa getOidc() (no useOidc) para ser callable fuera del árbol de componentes React.
 *
 * Si no hay token activo (usuario no autenticado), no agrega el header — no bloquea la request.
 * El interceptor es async para manejar correctamente el Promise de getOidc().
 *
 * API oidc-spa v10: getOidc() retorna Promise<GetOidc.Oidc>.
 * El método getAccessToken() está disponible en el estado LoggedIn.
 */
export function registerTokenInterceptor(instance: AxiosInstance): void {
  instance.interceptors.request.use(async (config) => {
    try {
      const oidc = await getOidc();

      if (oidc.isUserLoggedIn) {
        // getAccessToken() retorna Promise<string> en oidc-spa v10
        const accessToken = await oidc.getAccessToken();
        config.headers.Authorization = `Bearer ${accessToken}`;
      }
    } catch {
      // OIDC aún no inicializado o error al obtener el token — no bloquear la request
    }

    return config;
  });
}
