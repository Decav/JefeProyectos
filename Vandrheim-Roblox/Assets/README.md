# Vandrheim assets — organización del repositorio

## Estructura canónica

Los assets finales/activos se guardan por **tipo de asset y uso**, no en la raíz ni en carpetas temporales por fecha:

```text
Assets/
├── Icons/
│   ├── Classes/
│   ├── Items/
│   │   ├── Armor/{Paladin,Hunter,Cleric}/{Base,Blue,Frost}/
│   │   ├── Weapons/{OneHand,TwoHand,Bow,Wand,Shield,Unique}/
│   │   ├── Consumables/
│   │   └── Accessories/
│   ├── Skills/{Paladin,Hunter,Cleric}/
│   ├── Talents/
│   └── UI/{Menu,Common,Currency,Stats,Death,PartyRoles}/
├── Images/
│   ├── Brand/
│   ├── Enemies/Portraits/
│   └── Marketing/{ExperienceIcons,Candidates,Thumbnails}/
├── Animations/{Casts,Melee,Ranged}/
├── Clothing/{EST-07,EST-33/BodySkins/<Clase_Tier>}/
├── Sounds/{music}/
├── Source/{Design,Itemization,References}/
└── Temp/  (solo trabajo aún no aprobado)
```

## Reglas

1. **Canónico** significa asset aprobado/activo que usa el juego o una HU de integración. Su ruta local estable va en `ASSETS_LIST.md`; su ID Roblox, fuente y licencia van en `ASSETS_POLICY.md` → ASSETS_REGISTRY.
2. `Assets/Temp/` se reserva para trabajo aún no aprobado. Los masters, previews, prompts, entregas y scripts auxiliares de material **aprobado** se archivan en `Assets/Source/` por proyecto/épica; Temp no debe contener entregables aprobados.
3. **Iconos** van bajo `Assets/Icons/` por dominio (Items, Skills, Talents, UI); retratos/arte sin función de icono van bajo `Assets/Images/`.
4. Mantener nombres de archivos canónicos (`Icon_Item_*`, `Icon_Skill_*`, `Icon_Talent_*`, `Icon_Menu_*`, `Portrait_*`). No renombrar IDs sin actualizar `ItemConfig`, configs y `ASSETS_LIST.md`.
5. No borrar originales de trabajo ni previews al promover un archivo: se conservan en `Assets/Source/` para procedencia; la copia de producción queda en la carpeta canónica por tipo.

## Assets aprobados aún sin selección/publicación

Las propuestas de icono y miniaturas de experiencia están aprobadas como candidatas y organizadas en `Assets/Images/Marketing/{ExperienceIcons,Thumbnails}/Candidates/`; la selección de la propuesta oficial/publicación queda en ASSETS_LIST. Masters, comparativas, prompts y scripts están en `Assets/Source/Design/`.
