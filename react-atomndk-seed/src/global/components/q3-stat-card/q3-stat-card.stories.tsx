import type { Meta, StoryObj } from '@storybook/react';
import { Q3StatCard } from './q3-stat-card';

const meta: Meta<typeof Q3StatCard> = {
  title: 'Global/Q3StatCard',
  component: Q3StatCard,
  tags: ['autodocs'],
};
export default meta;
type Story = StoryObj<typeof Q3StatCard>;

export const Default: Story = { args: { title: 'Usuarios', value: 42 } };
export const WithIcon: Story = { args: { title: 'Usuarios', value: 42, icon: 'pi pi-users', trend: 'up' } };
export const TrendDown: Story = { args: { title: 'Errores', value: 3, icon: 'pi pi-times-circle', trend: 'down' } };
