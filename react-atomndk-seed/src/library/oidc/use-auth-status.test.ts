import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook } from '@testing-library/react';
import { useAuthStatus } from './use-auth-status';

const mockUseOidc = vi.fn();

vi.mock('./oidc-instance', () => ({
  useOidc: (...args: unknown[]) => mockUseOidc(...args),
}));

describe('useAuthStatus', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('retorna isAuthenticated=false y user=null cuando el usuario no esta logueado', () => {
    mockUseOidc.mockReturnValue({ isUserLoggedIn: false });

    const { result } = renderHook(() => useAuthStatus());

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });

  it('retorna isAuthenticated=true y user mapeado cuando el usuario esta logueado', () => {
    mockUseOidc.mockReturnValue({
      isUserLoggedIn: true,
      decodedIdToken: {
        sub: 'user-001',
        email: 'user@acl.cl',
        name: 'Usuario ACL',
        email_verified: true,
        given_name: 'Usuario',
        family_name: 'ACL',
        groups: ['acl-admin', 'acl-viewer'],
      },
    });

    const { result } = renderHook(() => useAuthStatus());

    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user?.sub).toBe('user-001');
    expect(result.current.user?.email).toBe('user@acl.cl');
    expect(result.current.user?.name).toBe('Usuario ACL');
    expect(result.current.user?.email_verified).toBe(true);
    expect(result.current.user?.given_name).toBe('Usuario');
    expect(result.current.user?.family_name).toBe('ACL');
    expect(result.current.user?.groups).toEqual(['acl-admin', 'acl-viewer']);
  });

  it('omite propiedades opcionales si no estan en el token', () => {
    mockUseOidc.mockReturnValue({
      isUserLoggedIn: true,
      decodedIdToken: {
        sub: 'user-002',
        email: 'minimal@acl.cl',
        name: 'Minimal User',
      },
    });

    const { result } = renderHook(() => useAuthStatus());

    expect(result.current.user?.sub).toBe('user-002');
    expect(result.current.user?.email_verified).toBeUndefined();
    expect(result.current.user?.given_name).toBeUndefined();
    expect(result.current.user?.family_name).toBeUndefined();
    expect(result.current.user?.groups).toBeUndefined();
  });

  it('filtra valores no-string del array groups del token', () => {
    mockUseOidc.mockReturnValue({
      isUserLoggedIn: true,
      decodedIdToken: {
        sub: 'user-003',
        email: 'user@acl.cl',
        name: 'User',
        groups: ['acl-admin', 42, null, 'acl-editor', true],
      },
    });

    const { result } = renderHook(() => useAuthStatus());

    expect(result.current.user?.groups).toEqual(['acl-admin', 'acl-editor']);
  });

  it('omite groups si el claim no es un array', () => {
    mockUseOidc.mockReturnValue({
      isUserLoggedIn: true,
      decodedIdToken: {
        sub: 'user-004',
        email: 'user@acl.cl',
        name: 'User',
        groups: 'not-an-array',
      },
    });

    const { result } = renderHook(() => useAuthStatus());

    expect(result.current.user?.groups).toBeUndefined();
  });

  it('usa string vacio como fallback para sub/email/name si el tipo no es string', () => {
    mockUseOidc.mockReturnValue({
      isUserLoggedIn: true,
      decodedIdToken: {
        sub: 123,
        email: null,
        name: undefined,
      },
    });

    const { result } = renderHook(() => useAuthStatus());

    expect(result.current.user?.sub).toBe('');
    expect(result.current.user?.email).toBe('');
    expect(result.current.user?.name).toBe('');
  });
});
