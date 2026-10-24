# Atuendo inicial de viajero — v1

Interpretación para Vandrheim de la referencia compartida: camisa amplia de lino crema, chaleco de cuero con cordones frontales, cinturón sencillo, pantalón beige y botas altas oscuras. Se omitió a la persona de la fotografía; el diseño se limita a la ropa y se adapta al estilo pintado de los mapas R15 del proyecto.

## Archivos

- `vandrheim_traveler_starter_classic_shirt_r15_v1.png` — mapa clásico R15 para torso y mangas.
- `vandrheim_traveler_starter_classic_pants_r15_v1.png` — mapa clásico R15 para pantalón y botas.
- `Preview_UV_Maps.png` — vista de inspección de ambos mapas UV.
- `Generate-VandrheimTravelerStarterBodySkin.py` — generador reproducible.

## Validación

- PNG RGBA de 585 × 559 px.
- El canal alpha de cada resultado coincide exactamente con su máscara de `Assets/Clothing/EST-07/`.
- Los mapas y el generador están en `Assets/Temp/BodySkins/`; no se modificaron ni integraron assets canónicos.
- No se creó icono: la skill trabaja directamente con las texturas de camisa y pantalón.
- `Preview_UV_Maps.png` permite revisar las islas y el diseño plano; aún no es una prueba de ajuste sobre un avatar R15 en Studio.
