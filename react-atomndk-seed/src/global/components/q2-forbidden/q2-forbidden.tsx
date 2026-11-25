import { Button } from 'primereact/button';
import { useNavigate } from 'react-router-dom';

export function Q2Forbidden() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col items-center justify-center gap-4 p-8 text-center">
      <i className="pi pi-lock text-5xl" style={{ color: 'var(--acl-danger)' }} />
      <h2 className="text-xl font-semibold" style={{ color: 'var(--acl-text-primary)' }}>
        Ups... no estás autorizado para ver esto
      </h2>
      <p className="text-sm" style={{ color: 'var(--acl-text-secondary)' }}>
        No tienes permisos para ver este contenido.
      </p>
      <Button
        label="Volver"
        icon="pi pi-arrow-left"
        text
        onClick={() => navigate(-1)}
      />
    </div>
  );
}
