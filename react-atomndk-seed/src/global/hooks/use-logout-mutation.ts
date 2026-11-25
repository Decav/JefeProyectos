/**
 * Re-export de useLogoutMutation desde library/oidc.
 * La implementación vive en src/library/oidc/use-logout-mutation.ts
 * porque depende directamente de oidc-spa (getOidc).
 *
 * Este archivo es el punto de acceso público para importadores que usan @global/hooks.
 */
export { useLogoutMutation } from '@library/oidc';
