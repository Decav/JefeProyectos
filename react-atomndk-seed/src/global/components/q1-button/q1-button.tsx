import { Button, type ButtonProps } from 'primereact/button';

type Variant = 'primary' | 'secondary' | 'danger' | 'ghost';

interface Props extends Omit<ButtonProps, 'severity'> {
  variant?: Variant;
}

const variantMap: Record<Variant, ButtonProps['severity']> = {
  primary: undefined,
  secondary: 'secondary',
  danger: 'danger',
  ghost: 'help',
};

export function Q1Button({ variant = 'primary', ...props }: Props) {
  return <Button severity={variantMap[variant]} {...props} />;
}
