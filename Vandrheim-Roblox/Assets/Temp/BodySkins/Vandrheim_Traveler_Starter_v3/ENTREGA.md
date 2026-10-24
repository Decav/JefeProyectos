# Corrección de bordes — Atuendo de viajero v3

La resolución del bodyskin se mantiene en 585×559. La franja clara venía de una coordenada UV incorrecta: la cuarta cara de cada pierna/brazo está en un panel separado y la cara de la pierna izquierda comienza en x=503, no en la tapa x=303. También se extendieron los degradados un píxel en sus bordes para cubrir los píxeles antialias de la máscara.

Archivos generados:
- `vandrheim_traveler_starter_classic_shirt_r15_v3.png`
- `vandrheim_traveler_starter_classic_pants_r15_v3.png`
- `Preview_UV_Maps_v3.png`

Verificación: ambos PNG son RGBA de 585×559 y conservan exactamente el canal alpha de las máscaras aprobadas. Se dejaron en esta carpeta temporal para revisión; no se importaron a Roblox Studio ni se movieron a los assets finales.
