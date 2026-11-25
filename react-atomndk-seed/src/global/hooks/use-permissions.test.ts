import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook } from '@testing-library/react';
import { usePermissions } from './use-permissions';
import { AppRole } from '@resources/enums/permission.enum';

const mockUseAuthStatus = vi.fn();

vi.mock('./use-auth-status', () => ({
  useAuthStatus: (...args: unknown[]) => mockUseAuthStatus(...args),
}));

const MAPPING = {
  'acl-admin': AppRole.ADMIN,
  'acl-editor': AppRole.EDITOR,
  'acl-viewer': AppRole.VIEWER,
} as const;

describe('usePermissions', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('retorna roles vacios y hasRole=false cuando user es null', () => {
    mockUseAuthStatus.mockReturnValue({ user: null });

    const { result } = renderHook(() => usePermissions(MAPPING));

    expect(result.current.roles).toEqual([]);
    expect(result.current.hasRole(AppRole.ADMIN)).toBe(false);
  });

  it('retorna roles vacios y hasRole=false cuando user no tiene grupos', () => {
    mockUseAuthStatus.mockReturnValue({
      user: { sub: 'u1', email: 'u@acl.cl', name: 'U' },
    });

    const { result } = renderHook(() => usePermissions(MAPPING));

    expect(result.current.roles).toEqual([]);
    expect(result.current.hasRole(AppRole.ADMIN)).toBe(false);
  });

  it('CA-08: mapea correctamente grupos a roles', () => {
    mockUseAuthStatus.mockReturnValue({
      user: { sub: 'u2', email: 'u@acl.cl', name: 'U', groups: ['acl-admin', 'acl-viewer'] },
    });

    const { result } = renderHook(() => usePermissions(MAPPING));

    expect(result.current.roles).toContain(AppRole.ADMIN);
    expect(result.current.roles).toContain(AppRole.VIEWER);
    expect(result.current.roles).not.toContain(AppRole.EDITOR);
  });

  it('hasRole retorna true para rol presente', () => {
    mockUseAuthStatus.mockReturnValue({
      user: { sub: 'u3', email: 'u@acl.cl', name: 'U', groups: ['acl-editor'] },
    });

    const { result } = renderHook(() => usePermissions(MAPPING));

    expect(result.current.hasRole(AppRole.EDITOR)).toBe(true);
    expect(result.current.hasRole(AppRole.ADMIN)).toBe(false);
  });

  it('deduplica roles cuando el usuario tiene grupos duplicados con el mismo rol', () => {
    const DUPED_MAPPING = {
      'acl-admin': AppRole.ADMIN,
      'acl-super-admin': AppRole.ADMIN,
    } as const;

    mockUseAuthStatus.mockReturnValue({
      user: { sub: 'u4', email: 'u@acl.cl', name: 'U', groups: ['acl-admin', 'acl-super-admin'] },
    });

    const { result } = renderHook(() => usePermissions(DUPED_MAPPING));

    const adminRoles = result.current.roles.filter((r) => r === AppRole.ADMIN);
    expect(adminRoles).toHaveLength(1);
  });

  it('ignora grupos que no estan en el mapeo', () => {
    mockUseAuthStatus.mockReturnValue({
      user: { sub: 'u5', email: 'u@acl.cl', name: 'U', groups: ['grupo-desconocido'] },
    });

    const { result } = renderHook(() => usePermissions(MAPPING));

    expect(result.current.roles).toEqual([]);
  });

  it('usa AUTHENTIK_GROUPS_TO_ROLES por defecto cuando no se pasa mapping', () => {
    mockUseAuthStatus.mockReturnValue({
      user: { sub: 'u6', email: 'u@acl.cl', name: 'U', groups: ['acl-admin'] },
    });

    // Sin pasar mapping — usa el default
    const { result } = renderHook(() => usePermissions());

    expect(result.current.hasRole(AppRole.ADMIN)).toBe(true);
  });
});
