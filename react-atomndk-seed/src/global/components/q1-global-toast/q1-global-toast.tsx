import { useRef, useEffect } from 'react';
import { Toast } from 'primereact/toast';
import { useUiStore } from '@global/store/ui.store';

export function Q1GlobalToast() {
  const toastRef = useRef<Toast>(null);
  const setToastRef = useUiStore((s) => s.setToastRef);

  useEffect(() => {
    setToastRef(toastRef);
  }, [setToastRef]);

  return <Toast ref={toastRef} position="top-right" />;
}
