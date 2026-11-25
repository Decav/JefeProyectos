import { type ReactNode } from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { Sidebar } from 'primereact/sidebar';
import { useAuthStatus } from '@global/hooks/use-auth-status';
import { useLogoutMutation } from '@global/hooks/use-logout-mutation';
import { useUiStore } from '@global/store/ui.store';

export interface NavItem {
  path: string;
  icon: string;
  label: string;
}

interface Props {
  /** Nombre visible de la aplicación (PROJECT.md → Identidad). */
  appName: string;
  /** Ítems de navegación del sidebar. */
  navItems: NavItem[];
  /** Logo opcional (ruta en public/, PROJECT.md → Marca). */
  logoSrc?: string;
  /** Acciones opcionales en el topbar (selector de tema, notificaciones, etc.). */
  topbarActions?: ReactNode;
}

interface SidebarContentProps {
  appName: string;
  navItems: NavItem[];
  logoSrc?: string | undefined;
  onClose: () => void;
}

function getInitials(name: string | undefined): string {
  if (!name) return '?';
  const initials = name
    .split(' ')
    .slice(0, 2)
    .map((part) => part.charAt(0))
    .filter((c) => c.length > 0)
    .join('')
    .toUpperCase();
  return initials || '?';
}

function SidebarContent({ appName, navItems, logoSrc, onClose }: SidebarContentProps) {
  const { user } = useAuthStatus();
  const { mutate: logout, isPending: isLoggingOut } = useLogoutMutation();

  return (
    <>
      {/* Sidebar header */}
      <div className="flex flex-shrink-0 flex-col items-center gap-2 border-b border-[var(--acl-sidebar-border)] px-5 py-6">
        {logoSrc && <img src={logoSrc} alt={appName} className="block h-24 w-24 rounded-xl" />}
        <p className="text-2xl font-medium leading-none text-[var(--acl-brand-primary)]">{appName}</p>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto py-4" aria-label="Navegación principal">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            end
            className={({ isActive }) =>
              `acl-sidebar-item${isActive ? ' acl-sidebar-item--active' : ''}`
            }
            onClick={onClose}
          >
            <i className={`${item.icon} acl-sidebar-item__icon`} />
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>

      {/* User panel */}
      <div className="flex-shrink-0 border-t border-[var(--acl-sidebar-border)] px-4 py-4">
        <div className="mb-3 flex items-center gap-3">
          <div className="acl-gradient flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-xs font-bold text-[var(--acl-text-on-brand)]">
            {getInitials(user?.name)}
          </div>
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-medium text-[var(--acl-sidebar-text)]">
              {user?.name ?? 'Usuario'}
            </p>
            <p className="truncate text-xs text-[var(--acl-sidebar-text-muted)]">
              {user?.email ?? ''}
            </p>
          </div>
        </div>
        <button
          type="button"
          className="flex w-full items-center justify-center gap-2 rounded-lg border border-[var(--acl-sidebar-border)] bg-transparent px-3 py-2 text-xs font-medium text-[var(--acl-sidebar-text-muted)] transition-colors hover:bg-[var(--acl-sidebar-hover)]"
          onClick={() => logout()}
          disabled={isLoggingOut}
        >
          <i className="pi pi-sign-out text-sm" />
          {isLoggingOut ? 'Cerrando...' : 'Cerrar sesión'}
        </button>
      </div>
    </>
  );
}

export function Q3AppShell({ appName, navItems, logoSrc, topbarActions }: Props) {
  const sidebarOpen = useUiStore((s) => s.sidebarOpen);
  const setSidebarOpen = useUiStore((s) => s.setSidebarOpen);

  return (
    <div className="acl-app-shell">
      {/* Desktop sidebar — siempre visible en lg+ */}
      <aside className="acl-sidebar hidden flex-col lg:flex" data-testid="sidebar">
        <SidebarContent appName={appName} navItems={navItems} logoSrc={logoSrc} onClose={() => {}} />
      </aside>

      {/* Mobile drawer — PrimeReact Sidebar */}
      <Sidebar
        visible={sidebarOpen}
        onHide={() => setSidebarOpen(false)}
        position="left"
        className="!w-[280px] !p-0"
        pt={{
          root: { style: { backgroundColor: 'var(--acl-sidebar-bg)', padding: 0 } },
          header: { style: { display: 'none' } },
          content: { style: { padding: 0, display: 'flex', flexDirection: 'column', height: '100%' } },
        }}
      >
        <SidebarContent
          appName={appName}
          navItems={navItems}
          logoSrc={logoSrc}
          onClose={() => setSidebarOpen(false)}
        />
      </Sidebar>

      {/* Main area */}
      <div className="flex min-h-screen flex-1 flex-col lg:ml-[var(--acl-sidebar-width)]">
        <header className="acl-topbar">
          {/* Hamburger — solo mobile */}
          <button
            type="button"
            className="mr-4 flex h-10 w-10 items-center justify-center rounded-lg transition-colors hover:bg-[var(--acl-surface-alt)] lg:hidden"
            onClick={() => setSidebarOpen(true)}
            aria-label="Abrir menú"
            data-testid="hamburger-button"
          >
            <i className="pi pi-bars text-lg text-[var(--acl-text-secondary)]" />
          </button>

          <div className="flex-1" />

          {topbarActions && <div className="flex items-center gap-2">{topbarActions}</div>}
        </header>

        <main className="acl-content">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
