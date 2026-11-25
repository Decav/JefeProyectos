import type { ReactNode } from 'react';
import { usePermissions } from '@global/hooks/use-permissions';
import type { AppRole } from '@resources/enums/permission.enum';
import type { GroupRoleMapping } from '@resources/contracts/oidc.contract';

interface Q5AuthorizedProps {
  /** Rol requerido para renderizar children */
  readonly requiredRole: AppRole;
  /** Contenido a renderizar si el usuario tiene el rol */
  readonly children: ReactNode;
  /** Contenido alternativo si no tiene el rol (default: null) */
  readonly fallback?: ReactNode;
  /** Mapeo opcional de grupos → roles. Por defecto usa AUTHENTIK_GROUPS_TO_ROLES */
  readonly mapping?: GroupRoleMapping<AppRole>;
}

/**
 * Componente wrapper que condiciona el renderizado según el rol del usuario.
 * Nivel Q5: componente de orquestación/guard.
 *
 * @example
 * // Ocultar si no tiene rol (fallback null por defecto)
 * <Q5Authorized requiredRole={AppRole.ADMIN}>
 *   <AdminPanel />
 * </Q5Authorized>
 *
 * @example
 * // Mostrar Q2Forbidden si no tiene rol
 * <Q5Authorized requiredRole={AppRole.EDITOR} fallback={<Q2Forbidden />}>
 *   <EditorTools />
 * </Q5Authorized>
 */
export function Q5Authorized({
  requiredRole,
  children,
  fallback = null,
  mapping,
}: Q5AuthorizedProps) {
  const { hasRole } = usePermissions(mapping);
  return hasRole(requiredRole) ? <>{children}</> : <>{fallback}</>;
}
