import { render, screen } from '@testing-library/react';
import { Q2Badge } from './q2-badge';

describe('Q2Badge', () => {
  it('renders label', () => {
    render(<Q2Badge label="Activo" status="success" />);
    expect(screen.getByText('Activo')).toBeInTheDocument();
  });

  it('applies correct class for danger status', () => {
    render(<Q2Badge label="Error" status="danger" />);
    const badge = screen.getByText('Error');
    expect(badge).toHaveClass('acl-badge-danger');
  });
});
