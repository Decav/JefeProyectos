import type { Meta, StoryObj } from '@storybook/react';
import { Q1Button } from './q1-button';

const meta: Meta<typeof Q1Button> = {
  title: 'Global/Q1Button',
  component: Q1Button,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'danger', 'ghost'],
    },
  },
};
export default meta;

type Story = StoryObj<typeof Q1Button>;

export const Primary: Story = { args: { label: 'Botón Primary', variant: 'primary' } };
export const Secondary: Story = { args: { label: 'Botón Secondary', variant: 'secondary' } };
export const Danger: Story = { args: { label: 'Botón Danger', variant: 'danger' } };
export const Ghost: Story = { args: { label: 'Botón Ghost', variant: 'ghost' } };
export const Loading: Story = { args: { label: 'Cargando...', loading: true } };
export const WithIcon: Story = { args: { label: 'Con Icono', icon: 'pi pi-check' } };
