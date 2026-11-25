import type { RouteObject } from 'react-router-dom';
import { PaLogin } from '../components/pa-login/pa-login';

export const loginRoutes: RouteObject[] = [
  { path: '/login', element: <PaLogin /> },
];
