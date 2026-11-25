import type { Meta, StoryObj } from '@storybook/react';
import { Q2Badge } from './q2-badge';

const meta: Meta<typeof Q2Badge> = {
  title: 'Global/Q2Badge',
  component: Q2Badge,
  tags: ['autodocs'],
  argTypes: {
    status: { control: 'select', options: ['success', 'warning', 'danger', 'info', 'neutral'] },
  },
};
export default meta;
type Story = StoryObj<typeof Q2Badge>;

export const Success: Story = { args: { label: 'Activo', status: 'success' } };
export const Warning: Story = { args: { label: 'Pendiente', status: 'warning' } };
export const Danger: Story = { args: { label: 'Error', status: 'danger' } };
export const Info: Story = { args: { label: 'Info', status: 'info' } };
export const Neutral: Story = { args: { label: 'Sin estado', status: 'neutral' } };
