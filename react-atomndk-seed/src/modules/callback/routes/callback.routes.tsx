import type { RouteObject } from 'react-router-dom';
import { PaCallback } from '../components/pa-callback/pa-callback';

export const callbackRoutes: RouteObject[] = [
  { path: '/callback', element: <PaCallback /> },
];
