import * as Sentry from '@sentry/react';

export function initSentry(): void {
  const dsn = import.meta.env.VITE_SENTRY_DSN;
  if (!dsn) return; // Risk R5 mitigation: guard on missing DSN

  Sentry.init({
    dsn,
    integrations: [],
    tracesSampleRate: 0.1,
    environment: import.meta.env.MODE,
  });
}
