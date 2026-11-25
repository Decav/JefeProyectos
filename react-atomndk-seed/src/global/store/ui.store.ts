import { create } from 'zustand';
import type { RefObject } from 'react';
import type { Toast } from 'primereact/toast';

type Theme = 'system' | 'light' | 'dark';

interface UiState {
  sidebarOpen: boolean;
  setSidebarOpen: (value: boolean) => void;
  theme: Theme;
  setTheme: (theme: Theme) => void;
  toastRef: RefObject<Toast | null> | null;
  setToastRef: (ref: RefObject<Toast | null>) => void;
  showError: (summary: string, detail: string) => void;
  showSuccess: (summary: string, detail: string) => void;
}

const THEME_STORAGE_KEY = 'acl-theme';

function isTheme(value: unknown): value is Theme {
  return value === 'system' || value === 'light' || value === 'dark';
}

function applyTheme(theme: Theme) {
  if (theme === 'system') {
    document.documentElement.removeAttribute('data-theme');
  } else {
    document.documentElement.setAttribute('data-theme', theme);
  }
}

function readSavedTheme(): Theme {
  try {
    const saved = localStorage.getItem(THEME_STORAGE_KEY);
    return isTheme(saved) ? saved : 'system';
  } catch {
    // localStorage no disponible (SSR, modo privado, tests sin browser)
    return 'system';
  }
}

function saveTheme(theme: Theme): void {
  try {
    localStorage.setItem(THEME_STORAGE_KEY, theme);
  } catch {
    // Storage no disponible o sin cuota: el tema aplica solo en la sesión actual.
  }
}

export const useUiStore = create<UiState>((set, get) => {
  const savedTheme = readSavedTheme();
  applyTheme(savedTheme);

  return {
    sidebarOpen: false,
    setSidebarOpen: (value) => set({ sidebarOpen: value }),
    theme: savedTheme,
    setTheme: (theme) => {
      applyTheme(theme);
      saveTheme(theme);
      set({ theme });
    },
    toastRef: null,
    setToastRef: (ref) => set({ toastRef: ref }),
    showError: (summary, detail) => {
      get().toastRef?.current?.show({
        severity: 'error',
        summary,
        detail,
        life: 5000,
      });
    },
    showSuccess: (summary, detail) => {
      get().toastRef?.current?.show({
        severity: 'success',
        summary,
        detail,
        life: 3000,
      });
    },
  };
});
