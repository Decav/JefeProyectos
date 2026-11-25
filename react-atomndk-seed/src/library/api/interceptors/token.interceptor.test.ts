import { describe, it, expect, vi, beforeEach } from 'vitest';
import axios from 'axios';
import type { AxiosInstance } from 'axios';
import { registerTokenInterceptor } from './token.interceptor';

const mockGetAccessToken = vi.fn();
const mockGetOidc = vi.fn();

vi.mock('@library/oidc', () => ({
  getOidc: (...args: unknown[]) => mockGetOidc(...args),
}));

type MockConfig = { headers: Record<string, string> };
type RequestHandler = { fulfilled: (config: MockConfig) => Promise<MockConfig> };

function getRequestHandler(instance: AxiosInstance): RequestHandler['fulfilled'] {
  const handlers = (instance.interceptors.request as unknown as { handlers: RequestHandler[] }).handlers;
  const handler = handlers[0];
  if (!handler) throw new Error('No hay request interceptor registrado');
  return handler.fulfilled;
}

function setup() {
  const instance = axios.create();
  registerTokenInterceptor(instance);
  return getRequestHandler(instance);
}

describe('registerTokenInterceptor', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('agrega el header Authorization Bearer cuando el usuario está autenticado', async () => {
    mockGetOidc.mockResolvedValue({
      isUserLoggedIn: true,
      getAccessToken: mockGetAccessToken.mockResolvedValue('access-token-123'),
    });

    const result = await setup()({ headers: {} });

    expect(result.headers['Authorization']).toBe('Bearer access-token-123');
  });

  it('NO agrega el header Authorization cuando el usuario NO está autenticado', async () => {
    mockGetOidc.mockResolvedValue({ isUserLoggedIn: false });

    const result = await setup()({ headers: {} });

    expect(result.headers['Authorization']).toBeUndefined();
  });

  it('NO bloquea la request si getOidc lanza un error', async () => {
    mockGetOidc.mockRejectedValue(new Error('OIDC no inicializado'));

    const mockConfig: MockConfig = { headers: {} };
    const result = await setup()(mockConfig);

    expect(result).toBe(mockConfig);
    expect(result.headers['Authorization']).toBeUndefined();
  });

  it('NO bloquea la request si getAccessToken lanza un error', async () => {
    mockGetOidc.mockResolvedValue({
      isUserLoggedIn: true,
      getAccessToken: vi.fn().mockRejectedValue(new Error('Token expirado')),
    });

    const mockConfig: MockConfig = { headers: {} };
    const result = await setup()(mockConfig);

    expect(result).toBe(mockConfig);
    expect(result.headers['Authorization']).toBeUndefined();
  });
});
