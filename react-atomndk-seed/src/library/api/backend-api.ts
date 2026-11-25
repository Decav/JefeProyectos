import { createApiClient } from './client/api-instance';
import { registerTokenInterceptor } from './interceptors/token.interceptor';
import { registerRefreshRetryInterceptor } from './interceptors/refresh-retry.interceptor';
import { registerErrorInterceptor } from './interceptors/error.interceptor';

/**
 * Instancia axios canónica del backend propio.
 * baseURL = VITE_API_URL.
 *
 * Orden de interceptores:
 *   1. Request  — token.interceptor: inyecta Bearer (getAccessToken refresca
 *                 automáticamente si hay refresh token válido).
 *   2. Response — refresh-retry.interceptor: en 401 reintenta una sola vez
 *                 vía renewTokens() si hay sesión activa.
 *   3. Response — error.interceptor: maneja el 401 final (logout/redirect).
 *
 * Los repositorios que consuman el backend DEBEN importar backendApi desde
 * '@library/api/backend-api' (o vía el barrel '@library/api').
 */
export const backendApi = createApiClient(import.meta.env.VITE_API_URL);
registerTokenInterceptor(backendApi);
registerRefreshRetryInterceptor(backendApi);
registerErrorInterceptor(backendApi);
