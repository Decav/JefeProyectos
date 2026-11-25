import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { Q2Forbidden } from './q2-forbidden';

const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return { ...actual, useNavigate: () => mockNavigate };
});

function renderComponent() {
  return render(
    <MemoryRouter>
      <Q2Forbidden />
    </MemoryRouter>
  );
}

describe('Q2Forbidden', () => {
  beforeEach(() => {
    mockNavigate.mockClear();
  });

  it('renders the unauthorized message', () => {
    renderComponent();
    expect(
      screen.getByText(/ups\.\.\. no estás autorizado para ver esto/i)
    ).toBeInTheDocument();
  });

  it('renders the secondary help text', () => {
    renderComponent();
    expect(
      screen.getByText(/no tienes permisos para ver este contenido/i)
    ).toBeInTheDocument();
  });

  it('renders the lock icon', () => {
    renderComponent();
    const icon = document.querySelector('.pi-lock');
    expect(icon).toBeInTheDocument();
  });

  it('renders the Volver button', () => {
    renderComponent();
    expect(screen.getByRole('button', { name: /volver/i })).toBeInTheDocument();
  });

  it('calls navigate(-1) when Volver button is clicked', async () => {
    renderComponent();
    await userEvent.click(screen.getByRole('button', { name: /volver/i }));
    expect(mockNavigate).toHaveBeenCalledWith(-1);
  });
});
