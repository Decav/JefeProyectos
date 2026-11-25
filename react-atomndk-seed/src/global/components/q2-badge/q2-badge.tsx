type Status = 'success' | 'warning' | 'danger' | 'info' | 'neutral';

interface Props {
  label: string;
  status?: Status;
}

const statusClasses: Record<Status, string> = {
  success: 'acl-badge acl-badge-success',
  warning: 'acl-badge acl-badge-warning',
  danger:  'acl-badge acl-badge-danger',
  info:    'acl-badge acl-badge-info',
  neutral: 'acl-badge acl-badge-neutral',
};

export function Q2Badge({ label, status = 'neutral' }: Props) {
  return (
    <span className={statusClasses[status]}>
      {label}
    </span>
  );
}
