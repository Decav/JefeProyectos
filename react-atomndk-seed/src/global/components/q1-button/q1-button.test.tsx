import { render, screen } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';
import { Q1Button } from './q1-button';

describe('Q1Button', () => {
  it('renders label', () => {
    render(<Q1Button label="Hola" />);
    expect(screen.getByText('Hola')).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const onClick = vi.fn();
    render(<Q1Button label="Click" onClick={onClick} />);
    await userEvent.click(screen.getByText('Click'));
    expect(onClick).toHaveBeenCalledOnce();
  });

  it('is disabled when loading', () => {
    render(<Q1Button label="Loading" loading />);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
