import { QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from 'react-router-dom';
import { PrimeReactProvider } from 'primereact/api';
import * as Sentry from '@sentry/react';
import { Skeleton } from 'primereact/skeleton';
import { queryClient } from '@library/query/query-client';
import { OidcInitializationGate } from '@library/oidc';
import { router } from '../router/app-router';
import { Q1GlobalToast } from '@global/components/q1-global-toast';
import { Q2ErrorFallback } from '@global/components/q2-error-fallback';

/**
 * Árbol de providers de la aplicación.
 * Orden: Sentry.ErrorBoundary > OidcInitializationGate > PrimeReactProvider > QueryClientProvider > RouterProvider
 *
 * OidcInitializationGate (oidc-spa v10) espera a que bootstrapOidc complete
 * antes de renderizar la app. NO fuerza login (la semilla no usa autoLogin):
 * las rutas que requieren sesión se envuelven con Q5ProtectedRoute.
 *
 * oidc-spa mantiene los tokens en memoria (no localStorage/sessionStorage).
 * Ver ADR-008 en .claude/skills/react-architecture/architecture/09-adrs.md.
 */
export function AppProviders() {
  return (
    <Sentry.ErrorBoundary fallback={<Q2ErrorFallback />}>
      <OidcInitializationGate
        fallback={
          <div className="flex items-center justify-center min-h-screen">
            <Skeleton height="100vh" />
          </div>
        }
      >
        <PrimeReactProvider>
          <QueryClientProvider client={queryClient}>
            <Q1GlobalToast />
            <RouterProvider router={router} />
          </QueryClientProvider>
        </PrimeReactProvider>
      </OidcInitializationGate>
    </Sentry.ErrorBoundary>
  );
}
