import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { initSentry } from '@library/integrations/sentry/sentry.client';
import { bootstrapOidc, oidcConfig } from '@library/oidc';
import { AppProviders } from './providers/app-providers';

const REQUIRED_ENV_VARS = [
  'VITE_OIDC_ISSUER_URI',
  'VITE_OIDC_CLIENT_ID',
  'VITE_OIDC_PUBLIC_URL',
] as const;

const missing = REQUIRED_ENV_VARS.filter(
  (key) => !import.meta.env[key]
);
if (missing.length > 0) {
  throw new Error(`Variables de entorno faltantes: ${missing.join(', ')}`);
}

import 'primereact/resources/themes/lara-light-indigo/theme.css';
import 'primereact/resources/primereact.min.css';
import 'primeicons/primeicons.css';
import '@/styles/theme.css';
import '@/styles/main.css';

initSentry();

/**
 * bootstrapOidc DEBE llamarse antes de montar la app.
 * Inicia la inicialización OIDC (discovery endpoint, silent login check, etc.).
 * OidcInitializationGate en AppProviders espera a que esto complete.
 */
bootstrapOidc({
  implementation: 'real',
  issuerUri: oidcConfig.issuerUri,
  clientId: oidcConfig.clientId,
  scopes: [...oidcConfig.scopes],
});

/**
 * MSW en el navegador: solo en desarrollo y con VITE_ENABLE_MOCKS=true.
 * El import dinámico evita incluir MSW en el bundle de producción.
 * Requiere public/mockServiceWorker.js (npm run msw:init).
 */
async function enableMocking(): Promise<void> {
  if (!import.meta.env.DEV || import.meta.env.VITE_ENABLE_MOCKS !== 'true') return;
  const { worker } = await import('@library/mocks/browser');
  await worker.start({ onUnhandledRequest: 'bypass' });
}

const rootElement = document.getElementById('root');
if (!rootElement) throw new Error('Root element not found');
const root = createRoot(rootElement);

void enableMocking().then(() => {
  root.render(
    <StrictMode>
      <AppProviders />
    </StrictMode>
  );
});
