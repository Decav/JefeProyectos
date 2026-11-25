/**
 * Configuración base para createReactOidc().
 * Lee variables de entorno tipadas via vite-env.d.ts.
 *
 * NOTA: VITE_OIDC_ISSUER_URI debe terminar con '/' para Authentik.
 * Ejemplo (Authentik): https://<idp>/application/o/<app-slug>/
 */
export const oidcConfig = {
  issuerUri: import.meta.env.VITE_OIDC_ISSUER_URI,
  clientId: import.meta.env.VITE_OIDC_CLIENT_ID,
  publicUrl: import.meta.env.VITE_OIDC_PUBLIC_URL,
  // 'permissions' activa el claim application { slug, role } en Authentik
  // vía una property mapping del IdP. Sin ese mapping, application será undefined.
  // Ajustar los scopes al proveedor del proyecto (PROJECT.md → Autenticación).
  scopes: ['openid', 'profile', 'email', 'groups', 'permissions'] as string[],
} as const;
