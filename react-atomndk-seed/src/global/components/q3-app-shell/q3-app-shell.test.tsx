import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { vi } from 'vitest';
import { Q3AppShell } from './q3-app-shell';
import { useUiStore } from '@global/store/ui.store';
import { useLogoutMutation } from '@global/hooks/use-logout-mutation';

// Mock stores — top-level vi.mock required for Vitest ESM alias resolution
vi.mock('@global/store/ui.store', () => ({
  useUiStore: vi.fn(),
}));

vi.mock('@global/hooks/use-auth-status', () => ({
  useAuthStatus: vi.fn(() => ({
    isAuthenticated: true,
    user: { name: 'Ana Pérez', email: 'ana@example.com', sub: 'user-123' },
  })),
}));

const mockLogout = vi.fn();
vi.mock('@global/hooks/use-logout-mutation', () => ({
  useLogoutMutation: vi.fn(),
}));

vi.mock('primereact/sidebar', () => ({
  Sidebar: ({ visible, children }: { visible: boolean; children: React.ReactNode }) =>
    visible ? <div data-testid="mobile-drawer">{children}</div> : null,
}));

const NAV_ITEMS = [{ path: '/home', icon: 'pi pi-home', label: 'Inicio' }];

function renderShell(sidebarOpen = false, extraProps: { logoSrc?: string; topbarActions?: React.ReactNode } = {}) {
  const setSidebarOpen = vi.fn();

  vi.mocked(useUiStore).mockImplementation((selector) =>
    selector({
      sidebarOpen,
      setSidebarOpen,
    } as unknown as Parameters<typeof selector>[0])
  );

  vi.mocked(useLogoutMutation).mockReturnValue({
    mutate: mockLogout,
    isPending: false,
  } as unknown as ReturnType<typeof useLogoutMutation>);

  return {
    setSidebarOpen,
    ...render(
      <MemoryRouter initialEntries={['/home']}>
        <Q3AppShell appName="Mi App" navItems={NAV_ITEMS} {...extraProps} />
      </MemoryRouter>,
    ),
  };
}

describe('Q3AppShell', () => {
  it('renders sidebar with app name and nav items', () => {
    renderShell();
    expect(screen.getByTestId('sidebar')).toBeInTheDocument();
    expect(screen.getByText('Mi App')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /inicio/i })).toHaveAttribute('href', '/home');
  });

  it('does not render external links or logo by default', () => {
    renderShell();
    expect(screen.queryByRole('img')).not.toBeInTheDocument();
    expect(screen.queryAllByRole('link')).toHaveLength(1);
  });

  it('renders logo and topbar actions when provided', () => {
    renderShell(false, { logoSrc: '/logo.svg', topbarActions: <span>Acción</span> });
    expect(screen.getByRole('img', { name: 'Mi App' })).toHaveAttribute('src', '/logo.svg');
    expect(screen.getByText('Acción')).toBeInTheDocument();
  });

  it('shows the hamburger button', () => {
    renderShell();
    expect(screen.getByTestId('hamburger-button')).toBeInTheDocument();
  });

  it('displays user name in sidebar', () => {
    renderShell();
    expect(screen.getByText('Ana Pérez')).toBeInTheDocument();
  });

  it('calls logout mutation on logout button click', async () => {
    const user = userEvent.setup();
    renderShell();
    await user.click(screen.getByRole('button', { name: /cerrar sesión/i }));
    expect(mockLogout).toHaveBeenCalled();
  });

  it('opens mobile drawer when hamburger is clicked', async () => {
    const user = userEvent.setup();
    const { setSidebarOpen } = renderShell(false);
    await user.click(screen.getByTestId('hamburger-button'));
    expect(setSidebarOpen).toHaveBeenCalledWith(true);
  });

  it('renders mobile drawer when sidebarOpen is true', () => {
    renderShell(true);
    expect(screen.getByTestId('mobile-drawer')).toBeInTheDocument();
  });

  it('does not show page title text in topbar', () => {
    renderShell();
    expect(screen.queryByRole('heading', { level: 1 })).not.toBeInTheDocument();
  });
});
