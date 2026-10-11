# Follow-up — descripciones de objetos

Aplicado en el Hub de Roblox Studio, en `ReplicatedStorage.Shared.TooltipData`.

- `TooltipData.Item` agrega la descripción del template como última fila del tooltip, después de stats, requisitos y bonos de set.
- La fila usa `C.Muted`, BuilderSans regular y el tamaño de detalle, siguiendo el gris del tooltip de CDR.
- También se agrega al final de las fichas de consumibles.
- `before/TooltipData.luau` conserva la versión previa; `after/TooltipData.luau` refleja el source aplicado.
- No se inició Play para esta modificación.
