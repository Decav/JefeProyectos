import type { Meta, StoryObj } from '@storybook/react';
import { Q5Authorized } from './q5-authorized';
import { AppRole } from '@resources/enums/permission.enum';

const meta: Meta<typeof Q5Authorized> = {
  title: 'Global/Q5Authorized',
  component: Q5Authorized,
  parameters: {
    docs: {
      description: {
        component:
          'Componente guard que condiciona el renderizado según el rol del usuario. ' +
          'Usa usePermissions() internamente para verificar si el usuario tiene el rol requerido.',
      },
    },
  },
};
export default meta;
type Story = StoryObj<typeof Q5Authorized>;

export const AccesoPermitido: Story = {
  args: {
    requiredRole: AppRole.ADMIN,
    children: (
      <div style={{ padding: '1rem', background: '#e8f5e9', borderRadius: '0.5rem' }}>
        Contenido visible para ADMIN
      </div>
    ),
    fallback: (
      <div style={{ padding: '1rem', background: '#ffebee', borderRadius: '0.5rem' }}>
        Acceso denegado
      </div>
    ),
  },
};

export const AccesoDenegado: Story = {
  args: {
    requiredRole: AppRole.ADMIN,
    children: (
      <div style={{ padding: '1rem', background: '#e8f5e9', borderRadius: '0.5rem' }}>
        Contenido solo para ADMIN
      </div>
    ),
    fallback: (
      <div style={{ padding: '1rem', background: '#ffebee', borderRadius: '0.5rem' }}>
        No tienes permiso para ver este contenido
      </div>
    ),
  },
};
