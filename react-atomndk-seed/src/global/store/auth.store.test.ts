import { renderHook, act } from '@testing-library/react';
import { useAuthStore } from './auth.store';
import type { OidcUser } from '@resources/contracts/oidc.contract';

const mockUser: OidcUser = {
  sub: 'user-123',
  email: 'user@test.com',
  name: 'Test User',
};

describe('useAuthStore', () => {
  beforeEach(() => {
    useAuthStore.setState({ user: null });
  });

  it('starts with null user', () => {
    const { result } = renderHook(() => useAuthStore());
    expect(result.current.user).toBeNull();
  });

  it('setUser populates user data', () => {
    const { result } = renderHook(() => useAuthStore());
    act(() => result.current.setUser(mockUser));
    expect(result.current.user?.sub).toBe('user-123');
    expect(result.current.user?.email).toBe('user@test.com');
    expect(result.current.user?.name).toBe('Test User');
  });

  it('setUser(null) clears user', () => {
    const { result } = renderHook(() => useAuthStore());
    act(() => result.current.setUser(mockUser));
    act(() => result.current.setUser(null));
    expect(result.current.user).toBeNull();
  });

  it('does not have accessToken in state (tokens managed by oidc-spa)', () => {
    const { result } = renderHook(() => useAuthStore());
    expect((result.current as unknown as Record<string, unknown>).accessToken).toBeUndefined();
  });
});
