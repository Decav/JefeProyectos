import { describe, it, expect, vi, beforeEach } from 'vitest';
import axios, { AxiosError } from 'axios';
import type { AxiosInstance, InternalAxiosRequestConfig } from 'axios';
import { registerErrorInterceptor } from './error.interceptor';

const mockGetOidc = vi.fn();
const mockLogout = vi.fn();

vi.mock('@library/oidc', () => ({
  getOidc: (...args: unknown[]) => mockGetOidc(...args),
}));

type ResponseHandler = { rejected: (error: unknown) => Promise<unknown> };

function getRejectHandler(instance: AxiosInstance): ResponseHandler['rejected'] {
  const handlers = (instance.interceptors.response as unknown as { handlers: ResponseHandler[] }).handlers;
  const handler = handlers[0];
  if (!handler) throw new Error('No hay response interceptor registrado');
  return handler.rejected;
}

function setup() {
  const instance = axios.create();
  registerErrorInterceptor(instance);
  return getRejectHandler(instance);
}

function makeError(status: number): AxiosError {
  const config = { url: '/ping', headers: {} } as unknown as InternalAxiosRequestConfig;
  const error = new AxiosError('Request failed', 'ERR_TEST', config);
  error.response = { status, statusText: '', data: {}, headers: {}, config };
  return error;
}

describe('registerErrorInterceptor', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockLogout.mockResolvedValue(undefined);
  });

  it('en 401 con sesión activa llama a oidc.logout y rechaza con el error original', async () => {
    mockGetOidc.mockResolvedValue({ isUserLoggedIn: true, logout: mockLogout });
    const error = makeError(401);

    await expect(setup()(error)).rejects.toBe(error);
    expect(mockLogout).toHaveBeenCalledWith({ redirectTo: 'home' });
  });

  it('en 401 sin sesión activa NO llama a logout (evita loops)', async () => {
    mockGetOidc.mockResolvedValue({ isUserLoggedIn: false, logout: mockLogout });
    const error = makeError(401);

    await expect(setup()(error)).rejects.toBe(error);
    expect(mockLogout).not.toHaveBeenCalled();
  });

  it('en 401 si getOidc falla propaga el error original', async () => {
    mockGetOidc.mockRejectedValue(new Error('OIDC no inicializado'));
    const error = makeError(401);

    await expect(setup()(error)).rejects.toBe(error);
    expect(mockLogout).not.toHaveBeenCalled();
  });

  it.each([403, 404, 500])('en %i NO llama a logout y rechaza con el error original', async (status) => {
    const error = makeError(status);

    await expect(setup()(error)).rejects.toBe(error);
    expect(mockGetOidc).not.toHaveBeenCalled();
    expect(mockLogout).not.toHaveBeenCalled();
  });
});
