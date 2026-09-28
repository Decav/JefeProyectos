# HU-ESTETICA-33 — muestra de body skins del Paladín azul

## Estado

Muestra visual nueva para revisión. No es integración ni entrega final de la HU completa.

## Archivos

- `paladin_blue_classic_shirt_r15.png` — mapa clásico R15 para torso y brazos: coraza ceñida al torso y brazales/guantes integrados a las islas de brazo.
- `paladin_blue_classic_pants_r15.png` — mapa clásico R15 para piernas: calzas azul noche con rodilleras y grebas integradas.
- `Generate-PaladinBlueBodySkins.ps1` — script aislado que genera los PNG.

Ambos PNG son de 585×559, RGBA, con transparencia fuera de las islas UV. Paleta de muestra: azul noche, acero azulado, cobalto y ribetes dorados sobrios. El acabado es una interpretación nueva desde cero; no se copió ni recoloreó el arte Hunter ni la textura original del Paladín.

## Método y validación

El script usa únicamente el canal alfa de las texturas clásicas de Hunter como máscara UV para respetar exactamente las islas R15; no reutiliza sus píxeles de color. Los mapas se dibujan en coordenadas de la plantilla oficial y se recortan a esa máscara.

Validación realizada: dimensiones 585×559, formato PNG y cero diferencias de alfa frente a la máscara UV de cada tipo de prenda. Se corrigió la ubicación de las caras frontales en las islas izquierda/derecha, cuyo orden UV está espejado.

## Uso previsto

- El mapa de camisa aporta las superficies de pecho y guantes/brazos. En los modelos `BodySkin`, el dev puede asignar el mismo `ShirtTemplate` y limitar los segmentos visibles mediante `bodySkinParts`.
- El mapa de pantalón aporta piernas y grebas; se limita a los segmentos de piernas según `bodySkinParts`.
- No crear modelos 3D separados para pecho, guantes ni piernas: son gráficos sobre el body R15. Casco y hombreras siguen siendo los únicos accesorios superpuestos.

## Límites de la muestra

- No se subieron los PNG a Roblox ni se modificó el place.
- No se alteraron `ItemConfig`, `ASSETS_LIST`, `ASSETS_REGISTRY`, ni assets canónicos.
- La textura no se previsualizó vestida sobre el rig en Studio, porque eso requeriría subir imágenes al servidor de assets. Revisar visualmente en un avatar R15 antes de integración.
- Esta muestra cubre solo la dirección Paladín azul para body skins; quedan pendientes la aprobación visual y el resto del alcance de HU-ESTETICA-33.
