/**
 * Fallback del ErrorBoundary de Sentry (AppProviders). Se renderiza fuera de
 * PrimeReactProvider y QueryClientProvider, por eso usa HTML + clases ACL.
 */
export function Q2ErrorFallback() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-[var(--acl-surface)]">
      <div className="p-8 text-center">
        <h1 className="mb-2 text-2xl font-bold text-[var(--acl-text-primary)]">Algo salió mal</h1>
        <p className="mb-4 text-[var(--acl-text-secondary)]">
          Ocurrió un error inesperado. Recarga la página o contacta al administrador.
        </p>
        <button
          type="button"
          className="acl-btn-primary rounded-lg px-4 py-2"
          onClick={() => window.location.reload()}
        >
          Recargar página
        </button>
      </div>
    </main>
  );
}
