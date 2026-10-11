# Nota de esquema — rc086

No se añadió schema persistido. `BackpackUIConfig` solo contiene valores de presentación. La mochila usa `InventoryData.bag`, `quantity`, `iconId`, `rarity`, atributo `Gold`, `VendorResult` y `ItemUseSlotState` existentes. El doble toque reutiliza `RequestUseConsumable` y `RequestEquipItem`; asignar el acceso rápido conserva `ItemUseAssignSlot` y `RequestAssignItemUseSlot`.
