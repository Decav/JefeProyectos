import { describe, expect, it } from 'vitest';
import { hasPermission } from './has-permission';
import { AppRole } from '@resources/enums/permission.enum';

const MAPPING = {
  'acl-admin': AppRole.ADMIN,
  'acl-editor': AppRole.EDITOR,
  'acl-viewer': AppRole.VIEWER,
};

describe('hasPermission', () => {
  it('CA-04: retorna true cuando el grupo mapea al rol requerido', () => {
    expect(hasPermission(['acl-admin', 'acl-viewer'], AppRole.ADMIN, MAPPING)).toBe(true);
  });

  it('CA-05: retorna false cuando ningún grupo mapea al rol requerido', () => {
    expect(hasPermission(['acl-viewer'], AppRole.ADMIN, MAPPING)).toBe(false);
  });

  it('CA-07: retorna false cuando groups está vacío', () => {
    expect(hasPermission([], AppRole.ADMIN, MAPPING)).toBe(false);
  });

  it('retorna false cuando el grupo no existe en el mapeo', () => {
    expect(hasPermission(['grupo-desconocido'], AppRole.ADMIN, MAPPING)).toBe(false);
  });

  it('retorna true para EDITOR cuando tiene el grupo correcto', () => {
    expect(hasPermission(['acl-editor'], AppRole.EDITOR, MAPPING)).toBe(true);
  });

  it('retorna false para ADMIN cuando solo tiene EDITOR', () => {
    expect(hasPermission(['acl-editor'], AppRole.ADMIN, MAPPING)).toBe(false);
  });
});
