import { render, screen } from '@testing-library/react';
import { Q3StatCard } from './q3-stat-card';

describe('Q3StatCard', () => {
  it('renders title and value', () => {
    render(<Q3StatCard title="Usuarios" value={42} />);
    expect(screen.getByText('Usuarios')).toBeInTheDocument();
    expect(screen.getByText('42')).toBeInTheDocument();
  });

  it('renders icon when provided', () => {
    const { container } = render(<Q3StatCard title="Stat" value={1} icon="pi pi-users" />);
    expect(container.querySelector('.pi-users')).toBeInTheDocument();
  });
});
