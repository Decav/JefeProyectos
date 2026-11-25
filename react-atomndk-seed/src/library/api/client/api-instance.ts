import axios from 'axios';
import type { AxiosInstance } from 'axios';

/**
 * Factory de instancias axios con configuración base del seed.
 * No registra interceptores — quien cree la instancia decide qué interceptores
 * registra (ej: backend-api.ts compone token + refresh-retry + error).
 */
export function createApiClient(baseURL: string): AxiosInstance {
  return axios.create({
    baseURL,
    timeout: 15_000,
    // Sin withCredentials — autenticación vía Bearer en Authorization header
    headers: { 'Content-Type': 'application/json' },
  });
}
