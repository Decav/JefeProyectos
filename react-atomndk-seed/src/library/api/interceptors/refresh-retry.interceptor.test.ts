import { describe, it, expect, vi, beforeEach } from 'vitest';
import axios, { AxiosError } from 'axios';
import type { AxiosInstance, InternalAxiosRequestConfig } from 'axios';
import { registerRefreshRetryInterceptor } from './refresh-retry.interceptor';

const mockGetOidc = vi.fn();
const mockRenewTokens = vi.fn();

vi.mock('@library/oidc', () => ({
  getOidc: (...args: unknown[]) => mockGetOidc(...args),
}));

type ResponseHandler = {
  fulfilled: (value: unknown) => unknown;
  rejected: (error: unknown) => Promise<unknown>;
};

function getRejectHandler(instance: AxiosInstance): ResponseHandler['rejected'] {
  const handlers = (instance.interceptors.response as unknown as {
    handlers: ResponseHandler[];
  }).handlers;
  const handler = handlers[0];
  if (!handler) throw new Error('No hay response interceptor registrado');
  return handler.rejected;
}

function makeError(
  status: number | undefined,
  config: Partial<InternalAxiosRequestConfig> = { url: '/ping' },
): AxiosError {
  const error = new AxiosError('boom', 'ERR_TEST');
  error.config = config as InternalAxiosRequestConfig;
  if (status !== undefined) {
    error.response = {
      status,
      statusText: '',
      data: null,
      headers: {},
      config: config as InternalAxiosRequestConfig,
    };
  }
  return error;
}

describe('registerRefreshRetryInterceptor', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('reintenta en 401 cuando renewTokens tiene éxito', async () => {
    const instance = axios.create();
    const requestSpy = vi
      .spyOn(instance, 'request')
      .mockResolvedValue({ status: 200, data: 'ok' });

    mockRenewTokens.mockResolvedValue(undefined);
    mockGetOidc.mockResolvedValue({
      isUserLoggedIn: true,
      renewTokens: mockRenewTokens,
    });

    registerRefreshRetryInterceptor(instance);
    const reject = getRejectHandler(instance);

    const result = await reject(makeError(401));

    expect(mockRenewTokens).toHaveBeenCalledOnce();
    expect(requestSpy).toHaveBeenCalledOnce();
    expect(result).toEqual({ status: 200, data: 'ok' });
    expect(requestSpy.mock.calls[0]?.[0]).toMatchObject({
      url: '/ping',
      _retry: true,
    });
  });

  it('NO reintenta dos veces (respeta _retry)', async () => {
    const instance = axios.create();
    const requestSpy = vi.spyOn(instance, 'request');

    mockGetOidc.mockResolvedValue({
      isUserLoggedIn: true,
      renewTokens: mockRenewTokens,
    });

    registerRefreshRetryInterceptor(instance);
    const reject = getRejectHandler(instance);

    const error = makeError(401, { url: '/ping', _retry: true } as Partial<InternalAxiosRequestConfig> & { _retry: boolean });

    await expect(reject(error)).rejects.toBe(error);
    expect(mockGetOidc).not.toHaveBeenCalled();
    expect(requestSpy).not.toHaveBeenCalled();
  });

  it('propaga error si renewTokens falla', async () => {
    const instance = axios.create();
    const requestSpy = vi.spyOn(instance, 'request');

    mockRenewTokens.mockRejectedValue(new Error('renew failed'));
    mockGetOidc.mockResolvedValue({
      isUserLoggedIn: true,
      renewTokens: mockRenewTokens,
    });

    registerRefreshRetryInterceptor(instance);
    const reject = getRejectHandler(instance);

    const error = makeError(401);
    await expect(reject(error)).rejects.toBe(error);
    expect(requestSpy).not.toHaveBeenCalled();
  });

  it('NO reintenta si el error no es 401', async () => {
    const instance = axios.create();
    const requestSpy = vi.spyOn(instance, 'request');

    mockGetOidc.mockResolvedValue({
      isUserLoggedIn: true,
      renewTokens: mockRenewTokens,
    });

    registerRefreshRetryInterceptor(instance);
    const reject = getRejectHandler(instance);

    const error500 = makeError(500);
    await expect(reject(error500)).rejects.toBe(error500);
    expect(mockGetOidc).not.toHaveBeenCalled();
    expect(requestSpy).not.toHaveBeenCalled();
  });

  it('NO reintenta si el usuario no esta logueado', async () => {
    const instance = axios.create();
    const requestSpy = vi.spyOn(instance, 'request');

    mockGetOidc.mockResolvedValue({ isUserLoggedIn: false });

    registerRefreshRetryInterceptor(instance);
    const reject = getRejectHandler(instance);

    const error = makeError(401);
    await expect(reject(error)).rejects.toBe(error);
    expect(mockRenewTokens).not.toHaveBeenCalled();
    expect(requestSpy).not.toHaveBeenCalled();
  });
});
