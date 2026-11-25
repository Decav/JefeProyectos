import { getHttpStatus } from './get-http-status';
import type { AxiosError, AxiosResponse } from 'axios';

function makeAxiosError(status: number): AxiosError {
  return {
    isAxiosError: true,
    response: { status } as AxiosResponse,
    message: 'Request failed',
    name: 'AxiosError',
    config: {} as AxiosError['config'],
    toJSON: () => ({}),
  } as unknown as AxiosError;
}

describe('getHttpStatus', () => {
  it('returns the HTTP status from an Axios error', () => {
    const error = makeAxiosError(403);
    expect(getHttpStatus(error)).toBe(403);
  });

  it('returns 401 for an Axios 401 error', () => {
    const error = makeAxiosError(401);
    expect(getHttpStatus(error)).toBe(401);
  });

  it('returns 500 for server errors', () => {
    const error = makeAxiosError(500);
    expect(getHttpStatus(error)).toBe(500);
  });

  it('returns null for a TypeError (non-Axios error)', () => {
    const error = new TypeError('Network failure');
    expect(getHttpStatus(error)).toBeNull();
  });

  it('returns null when error is null', () => {
    expect(getHttpStatus(null)).toBeNull();
  });

  it('returns null when error is undefined', () => {
    expect(getHttpStatus(undefined)).toBeNull();
  });

  it('returns null for an Axios error without response', () => {
    const error = {
      isAxiosError: true,
      response: undefined,
      message: 'Network Error',
    } as unknown as AxiosError;
    expect(getHttpStatus(error)).toBeNull();
  });
});
