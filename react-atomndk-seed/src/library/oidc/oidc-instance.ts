import { oidcSpa } from 'oidc-spa/react-spa';

/**
 * Instancia OIDC del seed.
 * oidcSpa v10 usa el builder pattern:
 *   .createUtils()  — genera { useOidc, getOidc, bootstrapOidc, OidcInitializationGate }
 *
 * MC-01: SIN withAutoLogin(). useOidc() retorna discriminated union:
 *   - { isUserLoggedIn: false; login: () => Promise<void> }
 *   - { isUserLoggedIn: true; decodedIdToken: ...; logout: ... }
 *
 * La app NO redirige automáticamente a Authentik. Las vistas /login y /callback
 * manejan sus propias guardas de autenticación.
 *
 * NOTA de capa NDK: este archivo vive en library/ y re-exporta OidcInitializationGate
 * (componente React). Esto es una excepción válida — oidc-spa exporta el gate
 * como parte de su API. El archivo en sí NO renderiza JSX.
 *
 * bootstrapOidc debe llamarse en main.tsx antes de montar la app.
 */
export const {
  useOidc,
  getOidc,
  bootstrapOidc,
  OidcInitializationGate,
} = oidcSpa.createUtils();
