import type {
  AxiosInstance,
  AxiosError,
  InternalAxiosRequestConfig,
} from 'axios';
import { getOidc } from '@library/oidc';

type RetryableConfig = InternalAxiosRequestConfig & { _retry?: boolean };

/**
 * Response interceptor que reintenta una vez en 401 usando renewTokens().
 *
 * Comportamiento:
 *   - Solo se activa en status 401.
 *   - Solo reintenta si el usuario está logueado (oidc.isUserLoggedIn).
 *   - Marca la request con _retry = true para evitar bucles.
 *   - Tras renewTokens() re-ejecuta la request en la misma instancia; el
 *     registerTokenInterceptor inyectará el nuevo access token automáticamente.
 *   - Si renewTokens() falla (sin refresh token o sesión expirada en el IdP),
 *     propaga el error original y el error.interceptor resuelve el 401 final.
 *
 * Nota: el objeto que entrega getOidc() en oidc-spa/react-spa no expone
 * getTokens()/hasRefreshToken; la disponibilidad de refresh se resuelve
 * intentando renewTokens().
 */
export function registerRefreshRetryInterceptor(instance: AxiosInstance): void {
  instance.interceptors.response.use(
    (response) => response,
    async (error: AxiosError) => {
      if (error.response?.status !== 401 || !error.config) {
        return Promise.reject(error);
      }

      const config = error.config as RetryableConfig;
      if (config._retry) {
        return Promise.reject(error);
      }

      let oidc;
      try {
        oidc = await getOidc();
      } catch {
        return Promise.reject(error);
      }

      if (!oidc.isUserLoggedIn) {
        return Promise.reject(error);
      }

      try {
        await oidc.renewTokens();
      } catch {
        return Promise.reject(error);
      }

      config._retry = true;
      return instance.request(config);
    },
  );
}
