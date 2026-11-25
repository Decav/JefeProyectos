import { useOidc } from './oidc-instance';
import type { OidcApplicationClaim, OidcUser } from '@resources/contracts/oidc.contract';

export interface AuthStatusResult {
  readonly isAuthenticated: boolean;
  readonly user: OidcUser | null;
}

/**
 * Extrae y valida el claim application desde el token decodificado.
 * Authentik lo inyecta a nivel raíz del token cuando el scope 'permissions' está activo.
 *
 * Estructura esperada: { application: { slug: string; role: string } }
 * Graceful degradation: retorna undefined si el claim no existe o tiene estructura inválida.
 */
function extractApplicationClaim(token: Record<string, unknown>): OidcApplicationClaim | undefined {
  const raw = token['application'];
  if (typeof raw !== 'object' || raw === null) return undefined;
  const app = raw as Record<string, unknown>;
  if (typeof app['slug'] !== 'string' || typeof app['role'] !== 'string') return undefined;
  return { slug: app['slug'], role: app['role'] };
}

/**
 * Hook público de autenticación.
 * Wrapper sobre useOidc que expone datos tipados sin exponer la API completa de oidc-spa.
 * Los componentes deben usar ESTE hook — NO useOidc directamente.
 *
 * Sin withAutoLogin(), useOidc() puede retornar isUserLoggedIn === false.
 * Las guardas de autenticación se manejan en cada vista (PaLogin / PaCallback).
 *
 * Nota: decodedIdToken tiene tipo Record<string, unknown> por defecto en oidc-spa.
 * Se mapea manualmente a OidcUser con type narrowing explícito. Sin 'any'.
 */
export function useAuthStatus(): AuthStatusResult {
  const oidc = useOidc();

  if (!oidc.isUserLoggedIn) {
    return {
      isAuthenticated: false,
      user: null,
    };
  }

  const token = oidc.decodedIdToken as Record<string, unknown>;

  // exactOptionalPropertyTypes requiere no incluir propiedades opcionales si son undefined
  const emailVerified = typeof token['email_verified'] === 'boolean'
    ? token['email_verified']
    : undefined;
  const givenName = typeof token['given_name'] === 'string' ? token['given_name'] : undefined;
  const familyName = typeof token['family_name'] === 'string' ? token['family_name'] : undefined;
  const groupsRaw = Array.isArray(token['groups'])
    ? (token['groups'] as unknown[]).filter((g): g is string => typeof g === 'string')
    : undefined;
  const application = extractApplicationClaim(token);

  const user: OidcUser = {
    sub: typeof token['sub'] === 'string' ? token['sub'] : '',
    email: typeof token['email'] === 'string' ? token['email'] : '',
    name: typeof token['name'] === 'string' ? token['name'] : '',
    ...(emailVerified !== undefined && { email_verified: emailVerified }),
    ...(givenName !== undefined && { given_name: givenName }),
    ...(familyName !== undefined && { family_name: familyName }),
    ...(groupsRaw !== undefined && { groups: groupsRaw }),
    ...(application !== undefined && { application }),
  };

  return {
    isAuthenticated: true,
    user,
  };
}
