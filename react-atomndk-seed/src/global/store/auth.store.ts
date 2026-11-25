import { create } from 'zustand';
import type { OidcUser } from '@resources/contracts/oidc.contract';

interface AuthState {
  user: OidcUser | null;
  setUser: (user: OidcUser | null) => void;
}

/**
 * Store delgado para datos de usuario derivados del token OIDC.
 * NO gestiona tokens ni estado de autenticación — eso lo provee oidc-spa.
 * isAuthenticated lo obtiene useOidc().isUserLoggedIn.
 */
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));
