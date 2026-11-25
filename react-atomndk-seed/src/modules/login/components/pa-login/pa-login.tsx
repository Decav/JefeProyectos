import { Navigate } from 'react-router-dom';
import { useOidc } from '@library/oidc';
import { Q1Button } from '@global/components/q1-button';

/**
 * Página de entrada. Si ya hay sesión, continúa a /callback.
 * Si no, ofrece iniciar sesión con el proveedor OIDC configurado (ver PROJECT.md).
 *
 * Personalización por proyecto: textos y logo según la marca de PROJECT.md.
 * Si el proyecto no necesita esta pantalla, puede redirigir directo con
 * oidc.login() al montar.
 */
export function PaLogin() {
  const oidc = useOidc();

  if (oidc.isUserLoggedIn) {
    return <Navigate to="/callback" replace />;
  }

  return (
    <main className="flex min-h-screen items-center justify-center bg-[var(--acl-surface)] p-6">
      <div className="acl-card flex w-full max-w-sm flex-col items-center gap-6 p-10">
        <div className="flex flex-col items-center gap-2 text-center">
          <h1 className="text-3xl font-bold tracking-tight text-[var(--acl-brand-primary)]">
            Iniciar sesión
          </h1>
          <p className="text-sm text-[var(--acl-text-secondary)]">
            Accede con tu cuenta corporativa
          </p>
        </div>

        <Q1Button
          type="button"
          label="Ingresar"
          icon="pi pi-sign-in"
          className="w-full"
          onClick={() => {
            void oidc.login({ doesCurrentHrefRequiresAuth: false });
          }}
        />
      </div>
    </main>
  );
}
