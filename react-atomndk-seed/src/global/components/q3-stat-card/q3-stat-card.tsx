interface Props {
  title: string;
  value: string | number;
  icon?: string;
  trend?: 'up' | 'down' | 'neutral';
}

const trendConfig = {
  up: { icon: 'pi pi-arrow-up', color: 'var(--acl-success)' },
  down: { icon: 'pi pi-arrow-down', color: 'var(--acl-danger)' },
  neutral: { icon: 'pi pi-minus', color: 'var(--acl-text-secondary)' },
};

export function Q3StatCard({ title, value, icon, trend = 'neutral' }: Props) {
  const { icon: trendIcon, color } = trendConfig[trend];

  return (
    <div
      className="rounded-lg p-6 flex items-center gap-4"
      style={{
        background: 'var(--acl-card)',
        boxShadow: 'var(--acl-shadow-sm)',
      }}
    >
      {icon && (
        <div
          className="p-3 rounded-full"
          style={{
            background: 'rgba(var(--acl-brand-secondary-rgb), 0.08)',
          }}
        >
          <i
            className={`${icon} text-2xl`}
            style={{ color: 'var(--acl-brand-secondary)' }}
          />
        </div>
      )}
      <div className="flex-1">
        <p className="text-sm" style={{ color: 'var(--acl-text-secondary)' }}>
          {title}
        </p>
        <p className="text-2xl font-bold" style={{ color: 'var(--acl-text-primary)' }}>
          {value}
        </p>
      </div>
      <i className={trendIcon} style={{ color, fontSize: '1.125rem' }} />
    </div>
  );
}
