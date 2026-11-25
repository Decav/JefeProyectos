import { useAuthStatus } from './use-auth-status';
import { hasPermission } from '@resources/utils/has-permission';
import { AUTHENTIK_GROUPS_TO_ROLES } from '@resources/contracts/oidc.contract';
import type { AppRole } from '@resources/enums/permission.enum';
import type { GroupRoleMapping } from '@resources/contracts/oidc.contract';

export interface UsePermissionsResult {
  readonly roles: AppRole[];
  readonly hasRole: (role: AppRole) => boolean;
}

/**
 * Hook que extrae los grupos del token OIDC y los mapea a roles de la app.
 * Si el claim 'groups' no existe → retorna roles vacío (no rompe la app).
 *
 * @param mapping - Mapeo opcional de grupos → roles.
 *                  Por defecto usa AUTHENTIK_GROUPS_TO_ROLES del seed.
 *                  Las apps hijas pueden pasar su propio mapeo (CA-06).
 */
export function usePermissions(
  mapping: GroupRoleMapping<AppRole> = AUTHENTIK_GROUPS_TO_ROLES,
): UsePermissionsResult {
  const { user } = useAuthStatus();
  const groups = user?.groups ?? [];

  const roles = Array.from(
    new Set(
      groups
        .map((group) => mapping[group])
        .filter((role): role is AppRole => role !== undefined),
    ),
  );

  return {
    roles,
    hasRole: (role: AppRole) => hasPermission(groups, role, mapping),
  };
}
