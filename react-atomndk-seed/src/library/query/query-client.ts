import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      // Default de 60s — cada hook puede sobreescribirlo segun criticidad del dato:
      // p. ej. catálogos estables: 5 min; datos que cambian seguido: 30s
      staleTime: 60_000,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 0,
    },
  },
});
