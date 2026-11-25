import type { Meta, StoryObj } from '@storybook/react';
import { Q1LoadingSpinner } from './q1-loading-spinner';

const meta: Meta<typeof Q1LoadingSpinner> = {
  title: 'Global/Q1LoadingSpinner',
  component: Q1LoadingSpinner,
  tags: ['autodocs'],
};
export default meta;
type Story = StoryObj<typeof Q1LoadingSpinner>;

export const Small: Story = { args: { size: 'sm' } };
export const Medium: Story = { args: { size: 'md' } };
export const Large: Story = { args: { size: 'lg' } };
export const WithLabel: Story = { args: { size: 'md', label: 'Cargando...' } };
