/**
 * Re-export de useAuthStatus desde library/oidc.
 * global/ no importa de library/ directamente; este archivo es el punto de acceso público
 * para el resto de la app que ya importa desde @global/hooks.
 *
 * Nota NDK: La implementación vive en src/library/oidc/use-auth-status.ts
 * porque depende directamente de oidc-spa (useOidc).
 */
export { useAuthStatus } from '@library/oidc';
export type { AuthStatusResult } from '@library/oidc';
