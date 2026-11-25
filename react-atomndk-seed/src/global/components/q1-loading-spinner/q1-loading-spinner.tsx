interface Props {
  size?: 'sm' | 'md' | 'lg';
  label?: string;
}

const sizeClasses = { sm: 'text-lg', md: 'text-3xl', lg: 'text-5xl' };

export function Q1LoadingSpinner({ size = 'md', label }: Props) {
  return (
    <div className="flex flex-col items-center gap-2">
      <i className={`pi pi-spin pi-spinner ${sizeClasses[size]} text-[var(--acl-brand-primary)]`} />
      {label && <p className="text-sm text-[var(--acl-text-secondary)]">{label}</p>}
    </div>
  );
}
