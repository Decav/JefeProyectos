export const AuthStatus = {
  Idle: 'idle',
  Authenticated: 'authenticated',
  Unauthenticated: 'unauthenticated',
  Loading: 'loading',
} as const;

export type AuthStatus = (typeof AuthStatus)[keyof typeof AuthStatus];
