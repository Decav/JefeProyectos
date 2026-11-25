import type { AppRole } from '../enums/permission.enum';

/**
 * Claim application inyectado por el IdP (en Authentik, vía una property mapping de scope).
 * Requiere el scope 'permissions' en la configuración OIDC.
 *
 * MC-02: El claim es { slug, role } — ambos son strings.
 */
export interface OidcApplicationClaim {
  readonly slug: string;
  readonly role: string;
}

/**
 * Campos estándar del decodedIdToken de Authentik/OIDC.
 * Representa los claims del token ID tal como vienen del proveedor.
 *
 * NOTA: El claim 'groups' requiere un Property Mapping en Authentik
 * que lo incluya en el ID token. Si no está configurado, groups será undefined.
 *
 * NOTA: El claim 'application' requiere el scope 'permissions' activo en Authentik.
 * Si no está configurado, application será undefined (graceful degradation).
 */
export interface OidcUser {
  readonly sub: string;
  readonly email: string;
  readonly name: string;
  readonly email_verified?: boolean;
  readonly given_name?: string;
  readonly family_name?: string;
  readonly groups?: string[];
  /** Claim inyectado por Authentik via scope 'permissions'. */
  readonly application?: OidcApplicationClaim;
}

/**
 * Tipo de mapeo de grupos de Authentik a roles de la app.
 * Las apps hijas del seed pueden crear su propio mapeo.
 */
export type GroupRoleMapping<TRole extends string> = Record<string, TRole>;

/**
 * Mapeo por defecto del seed: grupos de Authentik → roles de la app.
 *
 * IMPORTANTE: Los nombres de los grupos deben coincidir EXACTAMENTE con los
 * configurados en Authentik. Actualizar este mapeo según el entorno.
 *
 * Las apps hijas pueden sobreescribir pasando su propio mapping a usePermissions().
 */
export const AUTHENTIK_GROUPS_TO_ROLES: GroupRoleMapping<AppRole> = {
  'acl-admin': 'ADMIN',
  'acl-editor': 'EDITOR',
  'acl-viewer': 'VIEWER',
} as const;
