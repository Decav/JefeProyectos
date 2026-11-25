import { isAxiosError } from 'axios';

/**
 * Extrae el status HTTP de un error Axios.
 * Función utilitaria pura — no usa hooks de React.
 * Uso: const status = getHttpStatus(error); if (status === 403) return <Q2Forbidden />;
 */
export function getHttpStatus(error: unknown): number | null {
  if (!isAxiosError(error)) return null;
  return error.response?.status ?? null;
}
