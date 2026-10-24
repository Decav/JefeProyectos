# Atuendo inicial de viajero — body skin v2

Texturas clásicas R15 basadas en los iconos de referencia de guantes, pecho y pantalón de `Assets/Temp/Traveler_Starter_Icons_v1/`. La camisa retoma el chaleco de cuero castaño con cordones, la camisa de lino crema, el cinturón y los guantes integrados en la zona de muñeca/mano. El mapa de pantalón conserva el lino beige y las botas altas oscuras con correas de latón.

## Archivos

- `vandrheim_traveler_starter_classic_shirt_r15_v2.png` — camisa, torso y mangas/guantes.
- `vandrheim_traveler_starter_classic_pants_r15_v2.png` — pantalón y botas.
- `Preview_UV_Maps_v2.png` — inspección plana de ambos mapas.
- `Generate-VandrheimTravelerStarterBodySkin_v2.py` — generador reproducible.

## Verificación

- Ambas texturas son PNG RGBA de 585 × 559 px.
- El canal alpha de cada PNG coincide píxel por píxel con la máscara R15 correspondiente de `Assets/Clothing/EST-07/`.
- Se añadieron grano sutil de cuero y trama de lino, conservando la lectura de las costuras y pliegues a escala del mapa.
- La versión anterior v1 se conserva intacta.
- Los archivos están bajo `Assets/Temp/`; no se modificaron las plantillas originales ni se integraron assets al juego.
- La imagen incluida es una vista UV plana. Aún no se ha comprobado el calce sobre un avatar R15 en Roblox Studio.
