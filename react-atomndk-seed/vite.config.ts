import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { oidcSpa } from 'oidc-spa/vite-plugin';
import path from 'node:path';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  const apiProxyTarget = env.VITE_API_URL;

  return {
    plugins: [react(), tailwindcss(), oidcSpa()],
    optimizeDeps: {
      include: ['@sentry/react', '@sentry/core', '@sentry/browser'],
    },
    server: {
      port: 5151,
      // Proxy /api → VITE_API_URL en dev. Si la variable no está definida,
      // no se registra el proxy (la app puede usar URL absolutas o MSW).
      ...(apiProxyTarget
        ? {
            proxy: {
              '/api': {
                target: apiProxyTarget,
                changeOrigin: true,
                secure: true,
                cookieDomainRewrite: 'localhost',
              },
            },
          }
        : {}),
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
        '@global': path.resolve(__dirname, './src/global'),
        '@library': path.resolve(__dirname, './src/library'),
        '@modules': path.resolve(__dirname, './src/modules'),
        '@resources': path.resolve(__dirname, './src/resources'),
      },
    },
    test: {
      globals: true,
      environment: 'jsdom',
      passWithNoTests: true,
      setupFiles: ['./src/test/setup.ts'],
      exclude: ['**/node_modules/**', '**/dist/**', 'e2e/**'],
      coverage: {
        provider: 'v8',
        reporter: ['text', 'json', 'html'],
        include: ['src/**/*.{ts,tsx}'],
        exclude: [
          'src/test/**',
          'src/**/*.stories.tsx',
          'src/app/main.tsx',
        ],
      },
    },
  };
});
