import { render, screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { vi } from 'vitest';
import { Q5ProtectedRoute } from './q5-protected-route';
import { useAuthStatus } from '@global/hooks/use-auth-status';

vi.mock('@global/hooks/use-auth-status', () => ({
  useAuthStatus: vi.fn(),
}));

function renderAt(path: string) {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <Routes>
        <Route element={<Q5ProtectedRoute />}>
          <Route path="/home" element={<div data-testid="home">Home</div>} />
        </Route>
        <Route path="/login" element={<div data-testid="login">Login</div>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Q5ProtectedRoute', () => {
  it('renderiza las rutas hijas cuando hay sesión activa', () => {
    vi.mocked(useAuthStatus).mockReturnValue({
      isAuthenticated: true,
      user: { sub: 'user-1', email: 'ana@example.com', name: 'Ana' },
    });

    renderAt('/home');

    expect(screen.getByTestId('home')).toBeInTheDocument();
    expect(screen.queryByTestId('login')).not.toBeInTheDocument();
  });

  it('redirige a /login cuando no hay sesión', () => {
    vi.mocked(useAuthStatus).mockReturnValue({ isAuthenticated: false, user: null });

    renderAt('/home');

    expect(screen.getByTestId('login')).toBeInTheDocument();
    expect(screen.queryByTestId('home')).not.toBeInTheDocument();
  });
});
