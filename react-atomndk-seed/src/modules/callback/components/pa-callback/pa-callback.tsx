import { Navigate } from 'react-router-dom';
import { useAuthStatus, useLogoutMutation } from '@library/oidc';
import { Q1Button } from '@global/components/q1-button';

/**
 * Página posterior al login OIDC. Muestra los claims del ID token para
 * verificar la integración con el proveedor de identidad.
 *
 * Al crear el primer módulo de negocio, lo habitual es reemplazar esta vista
 * por una redirección a la página de inicio del proyecto.
 */
export function PaCallback() {
  const { isAuthenticated, user } = useAuthStatus();
  const { mutate: logout, isPending } = useLogoutMutation();

  if (!isAuthenticated || user === null) {
    return <Navigate to="/login" replace />;
  }

  const notAvailable = 'No disponible';

  return (
    <main className="flex min-h-screen items-center justify-center bg-[var(--acl-surface)] p-6">
      <div className="acl-card flex w-full max-w-lg flex-col gap-6 p-8">
        <div className="flex flex-col gap-1">
          <h1 className="text-2xl font-bold text-[var(--acl-brand-primary)]">
            Autenticación exitosa
          </h1>
          <p className="text-sm text-[var(--acl-text-secondary)]">
            Claims del token decodificado
          </p>
        </div>

        <div className="flex flex-col gap-3">
          <ClaimRow label="sub" value={user.sub} />
          <ClaimRow label="email" value={user.email} />
          <ClaimRow label="name" value={user.name} />
          <ClaimRow label="groups" value={user.groups?.join(', ') || notAvailable} />
          <ClaimRow label="application.slug" value={user.application?.slug ?? notAvailable} />
          <ClaimRow label="application.role" value={user.application?.role ?? notAvailable} />
        </div>

        <Q1Button
          type="button"
          label={isPending ? 'Cerrando sesión...' : 'Cerrar sesión'}
          icon="pi pi-sign-out"
          loading={isPending}
          className="w-full"
          onClick={() => {
            logout();
          }}
        />
      </div>
    </main>
  );
}

interface ClaimRowProps {
  readonly label: string;
  readonly value: string;
}

function ClaimRow({ label, value }: ClaimRowProps) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="font-mono text-xs uppercase tracking-wider text-[var(--acl-text-tertiary)]">
        {label}
      </span>
      <span className="break-all text-sm font-medium text-[var(--acl-text-primary)]">
        {value}
      </span>
    </div>
  );
}
