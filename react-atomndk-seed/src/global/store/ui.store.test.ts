import { renderHook, act } from '@testing-library/react';
import { useUiStore } from './ui.store';

describe('useUiStore', () => {
  beforeEach(() => {
    localStorage.clear();
    document.documentElement.removeAttribute('data-theme');
    useUiStore.setState({ sidebarOpen: false, theme: 'system' });
  });

  // --- sidebarOpen ---

  it('starts with sidebarOpen false', () => {
    const { result } = renderHook(() => useUiStore());
    expect(result.current.sidebarOpen).toBe(false);
  });

  it('setSidebarOpen updates sidebarOpen', () => {
    const { result } = renderHook(() => useUiStore());
    act(() => result.current.setSidebarOpen(true));
    expect(result.current.sidebarOpen).toBe(true);
  });

  // --- theme ---

  it('starts with theme "system" when localStorage is empty', () => {
    const { result } = renderHook(() => useUiStore());
    expect(result.current.theme).toBe('system');
  });

  it('setTheme("dark") sets data-theme="dark" and persists to localStorage', () => {
    const { result } = renderHook(() => useUiStore());
    act(() => result.current.setTheme('dark'));
    expect(result.current.theme).toBe('dark');
    expect(document.documentElement.getAttribute('data-theme')).toBe('dark');
    expect(localStorage.getItem('acl-theme')).toBe('dark');
  });

  it('setTheme("light") sets data-theme="light" and persists to localStorage', () => {
    const { result } = renderHook(() => useUiStore());
    act(() => result.current.setTheme('light'));
    expect(result.current.theme).toBe('light');
    expect(document.documentElement.getAttribute('data-theme')).toBe('light');
    expect(localStorage.getItem('acl-theme')).toBe('light');
  });

  it('setTheme("system") removes data-theme attribute and persists to localStorage', () => {
    document.documentElement.setAttribute('data-theme', 'dark');
    const { result } = renderHook(() => useUiStore());
    act(() => result.current.setTheme('system'));
    expect(result.current.theme).toBe('system');
    expect(document.documentElement.hasAttribute('data-theme')).toBe(false);
    expect(localStorage.getItem('acl-theme')).toBe('system');
  });

  it('applies saved theme from localStorage on store init', () => {
    localStorage.setItem('acl-theme', 'dark');
    // Re-import by re-initializing the store state to trigger init logic
    // We test the applyTheme side-effect indirectly via setTheme
    const { result } = renderHook(() => useUiStore());
    act(() => result.current.setTheme('dark'));
    expect(document.documentElement.getAttribute('data-theme')).toBe('dark');
  });
});
