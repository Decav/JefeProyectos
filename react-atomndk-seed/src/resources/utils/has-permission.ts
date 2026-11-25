import type { GroupRoleMapping } from '../contracts/oidc.contract';

/**
 * Función pura que verifica si una lista de grupos de Authentik
 * otorga el rol requerido según un mapeo configurable.
 * Testeable sin React, sin hooks, sin contexto.
 *
 * @param groups - Grupos del usuario (claim 'groups' del token OIDC)
 * @param requiredRole - Rol requerido para el acceso
 * @param mapping - Mapeo de grupos de Authentik → roles de la app
 */
export function hasPermission<TRole extends string>(
  groups: readonly string[],
  requiredRole: TRole,
  mapping: GroupRoleMapping<TRole>,
): boolean {
  return groups.some((group) => mapping[group] === requiredRole);
}
