import { render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { Q5Authorized } from './q5-authorized';
import { AppRole } from '@resources/enums/permission.enum';

vi.mock('@global/hooks/use-permissions', () => ({
  usePermissions: vi.fn(),
}));

import { usePermissions } from '@global/hooks/use-permissions';
const mockUsePermissions = vi.mocked(usePermissions);

describe('Q5Authorized', () => {
  it('CA-02: renderiza children si el usuario tiene el rol requerido', () => {
    mockUsePermissions.mockReturnValue({
      roles: [AppRole.ADMIN],
      hasRole: (role) => role === AppRole.ADMIN,
    });
    render(
      <Q5Authorized requiredRole={AppRole.ADMIN}>
        <span>Panel Admin</span>
      </Q5Authorized>
    );
    expect(screen.getByText('Panel Admin')).toBeInTheDocument();
  });

  it('CA-03: no renderiza children si el usuario no tiene el rol requerido', () => {
    mockUsePermissions.mockReturnValue({
      roles: [AppRole.VIEWER],
      hasRole: () => false,
    });
    render(
      <Q5Authorized requiredRole={AppRole.ADMIN}>
        <span>Panel Admin</span>
      </Q5Authorized>
    );
    expect(screen.queryByText('Panel Admin')).not.toBeInTheDocument();
  });

  it('CA-03: renderiza fallback si el usuario no tiene el rol', () => {
    mockUsePermissions.mockReturnValue({
      roles: [],
      hasRole: () => false,
    });
    render(
      <Q5Authorized requiredRole={AppRole.ADMIN} fallback={<span>Acceso denegado</span>}>
        <span>Panel Admin</span>
      </Q5Authorized>
    );
    expect(screen.getByText('Acceso denegado')).toBeInTheDocument();
    expect(screen.queryByText('Panel Admin')).not.toBeInTheDocument();
  });

  it('renderiza null por defecto si no tiene rol y no hay fallback', () => {
    mockUsePermissions.mockReturnValue({ roles: [], hasRole: () => false });
    const { container } = render(
      <Q5Authorized requiredRole={AppRole.ADMIN}>
        <span>Contenido</span>
      </Q5Authorized>
    );
    expect(container.firstChild).toBeNull();
  });
});
