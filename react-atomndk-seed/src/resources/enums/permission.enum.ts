/**
 * Roles de ejemplo de la semilla. Cada proyecto define los suyos (PROJECT.md → Autenticación).
 * Mapeados desde grupos del proveedor OIDC vía AUTHENTIK_GROUPS_TO_ROLES.
 *
 * Usar 'as const' para mejor tree-shaking vs TypeScript enum.
 */
export const AppRole = {
  ADMIN: 'ADMIN',
  EDITOR: 'EDITOR',
  VIEWER: 'VIEWER',
} as const;

export type AppRole = typeof AppRole[keyof typeof AppRole];
