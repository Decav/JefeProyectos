# HU-BOT-01: Anuncios de lanzamiento y beta abierta programados para Discord (bot DCV Studios)

**Proyecto:** DCV Studios — bot de Discord (`bots/DCVStudioOrganizer`)
**Épica:** Operaciones / Lanzamiento de Vandrheim
**Prioridad:** Alta
**Estado:** Abierta — lista para implementar
**Tipo:** Automatización de anuncios y contenido de beta abierta (Node.js / discord.js)
**Depende de:** bot actual (`/dcv-setup`, `config/server.json`), canales y roles existentes, assets de beta abierta, link de Roblox y fecha de beta confirmados por el PO
**Componentes observados:** `src/bot.js`, `src/register-commands.js`, `config/server.json`, `package.json` (Node 20+, discord.js 14.26.5, ESM)
**No modifica:** estructura de canales/roles, moderación, `/dcv-setup` ni el juego Roblox.

> **Nota de flujo:** esta HU es para el dev del bot. No usa el flujo RC de Roblox Studio; si el equipo del bot exige un RC técnico propio, se deriva de esta HU.

---

### Narrativa (INVEST)

**Como** PM/PO de DCV Studios,
**quiero** programar y publicar la secuencia de anuncios de beta abierta de Vandrheim en los canales correctos, con copys, imágenes y menciones,
**para** que la beta salga coordinada, sin duplicados ni posts olvidados.

**Como** dev del bot,
**quiero** un sistema config-driven con preview, programación, idempotencia y logs,
**para** operar los anuncios sin tocar código en cada publicación.

---

### Descripción / Contexto

El bot solo tiene `/dcv-setup` para ordenar el servidor. La beta abierta de Vandrheim necesita una secuencia de publicaciones en `#teasers`, `#devlogs`, `#anuncios`, `#actualizaciones`, `#recursos`, `#bienvenida-y-normas`, `#general`, `#planes-para-reuniones` y los foros `#ideas-y-feedback` / `#reportar-bugs`.

Publicar todo a mano es propenso a errores: horarios, copys, imágenes, menciones, pins y duplicados. Esta HU agrega un sistema de anuncios config-driven con previsualización, publicación manual, programación, cancelación, persistencia y logs. El contenido de beta abierta (copys y calendario) se entrega en el Anexo A.

**Criterio de hecho global:** el PO puede previsualizar, programar y publicar cada anuncio de la beta; el bot envía una sola vez, respeta canal/rol/imagen/horario, sobrevive reinicios, recupera envíos perdidos dentro de una ventana y reporta errores; `/dcv-setup` sigue funcionando igual.

---

### Especificaciones Técnicas / Contratos de API

#### 1. Modelo de datos (`config/announcements.json`)

Archivo separado de `server.json` para no mezclar estructura con contenido.

```json
{
  "timezone": "America/Argentina/Buenos_Aires",
  "defaultMentionRoleKey": "announcements",
  "adminNotifyChannel": "equipo-general",
  "schedulerIntervalSeconds": 30,
  "catchUpGraceMinutes": 60,
  "announcements": [
    {
      "id": "launch-main",
      "phase": "launch",
      "mode": "announcement",
      "channel": "anuncios",
      "title": "Vandrheim ya está en beta abierta",
      "body": "RPG de acción nórdico en Roblox...",
      "color": "#C89445",
      "image": "Assets/Launch/launch-main.png",
      "link": { "label": "Jugar en Roblox", "url": "https://www.roblox.com/games/..." },
      "mentionRoleKey": "announcements",
      "pin": true,
      "crosspost": false,
      "threadName": null,
      "forumTags": [],
      "publishAt": "2026-11-06T18:00:00-03:00",
      "status": "draft"
    }
  ]
}
```

Reglas del modelo:

* `id`: único, slug estable (`launch-main`, `t7-teaser-helada`). No se reutiliza.
* `mode`: `announcement` (embed en canal de texto), `forum-post` (hilo nuevo en foro) o `thread` (mensaje + hilo en canal de texto).
* `channel`: nombre o alias declarado en `config/server.json`.
* `title`: ≤ 256 caracteres; `body`: ≤ 2000 caracteres para el mensaje; si se usa embed, `description` ≤ 4096.
* `image`: ruta local relativa a la raíz del bot (`Assets/...`) o `imageUrl` https. Validar existencia/formato antes de publicar.
* `link`: opcional; botón de URL (máx. 5 botones por fila, 1 en esta HU).
* `mentionRoleKey`: opcional; resuelve el rol por `key` de `server.json`. `null` = sin mención.
* `pin` / `crosspost`: booleanos. `crosspost` solo si el canal es de tipo Announcement.
* `publishAt`: ISO 8601 con offset; `null` = publicación manual.
* `status`: `draft` | `scheduled` | `sent` | `cancelled` | `missed`.
* `sentAt`, `messageId`, `channelId`, `late`: los escribe el bot en el state, no en el config.

#### 2. Comandos (`/anuncio`)

Todos restringidos a la persona propietaria o a quien tenga `ManageChannels` (mismo criterio que `/dcv-setup`). Respuestas efímeras salvo el post público.

| Subcomando | Comportamiento |
|---|---|
| `/anuncio previsualizar <id>` | Muestra embed/mensaje, canal destino, mención, pin, crosspost y horario. Sin efectos secundarios. |
| `/anuncio publicar <id>` | Pide confirmación con botones; envía, fija y menciona; guarda `messageId`/`sentAt`. |
| `/anuncio programar <id> <fecha-hora>` | Valida fecha futura y guarda `publishAt` + `status=scheduled`. Acepta ISO 8601 o `DD/MM/AAAA HH:mm`. |
| `/anuncio cancelar <id>` | Cancela un `scheduled`; no borra mensajes ya enviados. |
| `/anuncio listar` | Lista id, canal, estado, horario y `messageId` (tabla corta, ≤ 20 filas). |
| `/anuncio reprogramar <id> <fecha-hora>` | Solo si `scheduled`; actualiza la hora sin duplicar. |

Reglas de interacción:

* `previsualizar` nunca envía ni modifica state.
* `publicar` exige confirmación explícita; si el anuncio ya fue enviado, rechaza con mensaje claro.
* Errores de validación muestran el motivo exacto (canal inexistente, rol inexistente, imagen faltante, texto largo, fecha pasada, permisos).
* Autocompletar `id` y `channel` en los comandos.

#### 3. Programación y persistencia

* Scheduler en proceso, revisa cada `schedulerIntervalSeconds` (default 30 s).
* State persistido en `data/announcements-state.json` (fuera de Git), escritura atómica (temp + rename) para evitar corrupción.
* Al arrancar, carga el state y:
  * `scheduled` con `publishAt` futuro → queda agendado.
  * `scheduled` vencido dentro de `catchUpGraceMinutes` → envía y marca `sent` con `late=true`.
  * `scheduled` vencido fuera de la ventana → marca `missed` y notifica al canal admin; no envía.
* Idempotencia: si existe `messageId` para el `id`, no se vuelve a enviar aunque el state se recargue o el bot reinicie.
* Un lock simple por proceso evita doble envío si el scheduler y un comando manual coinciden.
* Si el bot está apagado a la hora exacta, aplica la regla de catch-up; no hay promesa de envío sin proceso corriendo.
* `publishAt` se interpreta en la zona horaria configurada; guardar también el ISO con offset para auditoría.

#### 4. Formato de los mensajes

* `announcement`: embed con título, descripción, color, imagen y footer; mención de rol fuera del embed (para que notifique); botón de link si existe.
* `forum-post`: crea un hilo en el foro con `threadName` y el cuerpo; aplica `forumTags` por nombre si existen; no usa `pin`.
* `thread`: envía el mensaje al canal y crea un hilo público con `threadName`; el mensaje queda como cabecera.
* Imágenes: `AttachmentBuilder` para archivos locales; límite de seguridad 8 MB; validar extensión png/jpg/jpeg/gif/webp.
* Longitudes: título ≤ 256, descripción ≤ 4096, cuerpo ≤ 2000, nombre de hilo ≤ 100, tags ≤ 5.
* No usar `@everyone` ni `@here`; solo el rol configurado.
* Si `crosspost=true` y el canal no es Announcement, avisar y omitir crosspost (no fallar el envío).
* Pin: solo en canales de texto; si falla por permisos, reportar sin perder el envío.

#### 5. Canales, roles y permisos

* Resolver canales por nombre/alias con la misma normalización de `src/bot.js`.
* Resolver roles por `key` de `server.json` (`announcements` para `@Anuncios`).
* Permisos del bot necesarios: `ViewChannel`, `SendMessages`, `ReadMessageHistory`, `EmbedLinks`, `AttachFiles`, `ManageMessages` (pin), `ManageChannels` (comando) y `MentionEveryone` si Discord lo exige para mencionar el rol; para foros, `CreatePublicThreads` y `SendMessagesInThreads`.
* Si falta un permiso, el comando responde con la lista exacta y no publica.
* No se concede `Administrator`.
* `#anuncios` se mantiene como canal de texto en v1; `crosspost` queda deshabilitado por default. Si el PO quiere crosspost, el dev evalúa convertir el canal a Announcement y lo documenta.

#### 6. Logs y observabilidad

* Log de consola y `data/announcements.log` (JSON Lines) por acción: `preview`, `publish`, `schedule`, `cancel`, `send`, `missed`, `error`.
* Campos: `timestamp`, `announcementId`, `action`, `userId`, `channelId`, `messageId`, `late`, `error`.
* En fallo de envío o `missed`: notificar al canal `adminNotifyChannel` (default `#equipo-general`) o por DM al propietario si el canal no existe.
* No loguear tokens, IDs secretos ni contenido sensible.

#### 7. Integración con el bot actual

* Mantener `/dcv-setup` sin cambios funcionales.
* Nuevo módulo `src/announcements.js` (o equivalente) para config, scheduler, state y envío.
* Registrar `/anuncio` en `src/register-commands.js` junto al comando existente.
* Arrancar el scheduler en `Events.ClientReady`; detenerlo en `SIGINT`/`SIGTERM`.
* ESM, Node 20+, discord.js 14.26.5; evitar dependencias nuevas salvo necesidad justificada.
* Actualizar `README.md` con comandos, config, permisos y operación.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Previsualizar sin efectos

* **GIVEN** un anuncio `draft` con canal, rol e imagen válidos
* **WHEN** el PO ejecuta `/anuncio previsualizar <id>`
* **THEN** ve el embed/mensaje, canal, mención, pin, crosspost y horario
* **AND** no se envía nada ni cambia el state

#### Escenario 2: Publicar una vez

* **GIVEN** un anuncio `draft`
* **WHEN** el PO confirma `/anuncio publicar <id>`
* **THEN** el bot envía el mensaje al canal correcto, menciona el rol, fija si corresponde y guarda `messageId`/`sentAt`
* **AND** una segunda ejecución rechaza el envío por ya publicado

#### Escenario 3: Programar y enviar

* **GIVEN** un anuncio `draft` y una fecha futura
* **WHEN** el PO ejecuta `/anuncio programar <id> <fecha-hora>`
* **THEN** el anuncio queda `scheduled` con la hora en la zona configurada
* **AND** el scheduler lo envía a esa hora y lo marca `sent`

#### Escenario 4: Reinicio sin duplicados

* **GIVEN** un anuncio ya enviado o programado
* **WHEN** el bot se reinicia
* **THEN** no reenvía el ya enviado y conserva el programado
* **AND** el state mantiene `messageId`, `sentAt` y `status`

#### Escenario 5: Envío perdido

* **GIVEN** un anuncio programado que venció mientras el bot estaba apagado
* **WHEN** el bot arranca dentro de `catchUpGraceMinutes`
* **THEN** lo envía una vez y lo marca `sent` con `late=true`
* **AND** si está fuera de la ventana, lo marca `missed` y avisa al canal admin sin enviarlo

#### Escenario 6: Cancelar

* **GIVEN** un anuncio `scheduled`
* **WHEN** el PO ejecuta `/anuncio cancelar <id>`
* **THEN** queda `cancelled` y no se envía
* **AND** un anuncio ya enviado no se borra ni se cancela

#### Escenario 7: Validaciones

* **GIVEN** un anuncio con canal inexistente, rol inválido, imagen faltante, texto fuera de límite o fecha pasada
* **WHEN** se previsualiza o publica
* **THEN** el bot rechaza con el motivo exacto
* **AND** no envía nada parcial

#### Escenario 8: Permisos

* **GIVEN** un usuario sin `ManageChannels` o un bot sin permisos suficientes
* **WHEN** intenta usar `/anuncio`
* **THEN** el bot rechaza y explica qué permiso falta
* **AND** no publica ni modifica el state

#### Escenario 9: Mención y pin

* **GIVEN** un anuncio con `mentionRoleKey=announcements` y `pin=true`
* **WHEN** se publica
* **THEN** menciona solo `@Anuncios` (nunca `@everyone`/`@here`) y fija el mensaje
* **AND** si el pin falla por permisos, el envío se conserva y se reporta el error

#### Escenario 10: Foros

* **GIVEN** un anuncio `forum-post` en `#ideas-y-feedback` o `#reportar-bugs`
* **WHEN** se publica
* **THEN** crea un hilo con el nombre y cuerpo configurados y aplica los tags solicitados
* **AND** si el canal no es foro o falta un tag, rechaza con error claro

#### Escenario 11: Crosspost opcional

* **GIVEN** un anuncio con `crosspost=true`
* **WHEN** el canal es Announcement
* **THEN** el bot crosspostea el mensaje
* **AND** si el canal es texto, avisa y publica sin crosspost

#### Escenario 12: Regresión

* **GIVEN** el sistema de anuncios implementado
* **WHEN** se ejecuta `/dcv-setup previsualizar` y `/dcv-setup aplicar`
* **THEN** el comportamiento existente no cambia
* **AND** no se duplican canales, roles ni mensajes de bienvenida

---

### Comportamiento Visual / Reglas de Negocio

* Los anuncios usan la paleta de Vandrheim (latón `#C89445`, pergamino `#F4EDE0`, frío `#8FB7D6`) y una imagen por post.
* `#anuncios` es para hitos y noticias; `#actualizaciones` para patch notes; `#devlogs` para proceso. No repetir el mismo texto en todos.
* `#teasers` no promete fechas; `#anuncios` solo anuncia fechas confirmadas por el PO.
* Las menciones se limitan a `@Anuncios`; nunca `@everyone`/`@here`.
* Los foros reciben un post de bienvenida/plantilla, no spam de anuncios.
* Si un asset falta, el sistema usa un placeholder aprobado o bloquea la publicación; no publica imágenes rotas.

---

### Alcance

#### Incluye

* Config `config/announcements.json` + state persistente.
* Comandos `/anuncio previsualizar | publicar | programar | cancelar | listar | reprogramar`.
* Scheduler con timezone, catch-up y anti-duplicados.
* Envío a canales de texto, hilos y foros; embeds, imágenes, links, mención de rol y pin.
* Validaciones, permisos, logs y notificación de errores.
* Paquete de contenido de beta abierta del Anexo A (IDs, canales, copys y assets).
* Actualización de `README.md`.

#### No incluye

* Cambiar el juego Roblox, su código, sus places o su economía.
* Publicar automáticamente desde Roblox/CI.
* Analytics de clicks, A/B testing, multi-servidor o multi-idioma.
* Generación automática de imágenes o copys.
* Rediseñar canales/roles existentes; solo se usan.
* Crosspost obligatorio (queda opcional y deshabilitado por default en v1).

---

### Anexo A — Paquete de contenido de beta abierta

> Los copys de beta son la fuente propuesta por el PM. El PO puede ajustar texto/imágenes antes de programar. Los assets deben existir en `Assets/Launch/` o usar un placeholder aprobado.

#### A.1 Calendario y canales

| ID | Fase | Canal | Modo | Qué publica | Flags |
|---|---|---|---|---|---|
| `t7-teaser-helada` | T-7 | `#teasers` | announcement | “La Helada no perdona. 5 pisos. Un trono. Pronto en Vandrheim.” | imagen teaser |
| `t7-devlog-final` | T-7 | `#devlogs` | announcement | “Devlog — El último invierno antes de la beta” | captura |
| `t3-teaser-clases` | T-3 | `#teasers` | announcement | “3 clases. 6 especializaciones. ¿Cuál es la tuya?” | class card |
| `t3-playtest` | T-3 | `#planes-para-reuniones` | announcement | Playtest/Q&A pre-beta (si hay cupo) | mención `@Anuncios` |
| `t1-teaser-jotunn` | T-1 | `#teasers` | announcement | “Jotunn, Guardián de la Escarcha. Mañana.” | boss card |
| `t1-anuncio-fecha` | T-1 | `#anuncios` | announcement | Fecha y hora de la beta + link (solo si está confirmada) | mención, pin |
| `launch-main` | Día 0 | `#anuncios` | announcement | Apertura de la beta + features + link | mención, pin |
| `launch-patch-notes` | Día 0 | `#actualizaciones` | announcement | Patch notes de beta + known issues | pin |
| `launch-recursos` | Día 0 | `#recursos` | announcement | “Cómo empezar”: link, controles, clases, FAQ | pin |
| `launch-bienvenida` | Día 0 | `#bienvenida-y-normas` | announcement | “Vandrheim ya está en beta abierta” + link | pin |
| `launch-general` | Día 0 | `#general` | thread | “Contá tu clase y tu build” | hilo |
| `launch-trailer` | Día 0 | `#teasers` | announcement | Trailer/GIF de beta | video/GIF |
| `launch-party` | Día 0 | `#planes-para-reuniones` | announcement | Beta party en voz | mención `@Anuncios` |
| `launch-ideas` | Día 0 | `#ideas-y-feedback` | forum-post | “Ya jugaste la beta: ¿qué mejorarías?” + plantilla | tag `Nueva idea` |
| `launch-bugs` | Día 0 | `#reportar-bugs` | forum-post | “¿Encontraste un bug en la beta?” + plantilla | tag `Nuevo` |
| `t1-gracias` | T+1 | `#anuncios` | announcement | Gracias por la beta + hotfix/known issues | mención, pin |
| `t1-hotfix` | T+1 | `#actualizaciones` | announcement | Hotfix notes | pin |
| `t3-devlog-48h` | T+3 | `#devlogs` | announcement | “Primeras 48 h de beta: qué aprendimos” | captura |

> `t7-teaser-fuego` **no forma parte de la secuencia de beta**: se publica después de 1.0, cuando la expansión de fuego/lava tenga su propio anuncio.

#### A.2 Copys base

**`launch-main`**
> **Vandrheim ya está en beta abierta.**
> RPG de acción nórdico en Roblox. 3 clases, 6 especializaciones, 30 habilidades y una mazmorra de 5 pisos. Crea tu personaje y enfrenta a Jotunn, Guardián de la Escarcha, solo o en party de hasta 4.
> Juega gratis en PC y móvil: `<link>`
> Beta abierta: el contenido, el balance y la economía pueden cambiar. Reporta bugs en `#reportar-bugs`.
> Actualizaciones gratuitas. El bioma de fuego y lava llegará en una expansión posterior a 1.0.

**`launch-patch-notes`**
> **Beta abierta — La Helada**
> Incluye: 3 clases, 6 especializaciones, 30 habilidades, 5 pisos, mini-jefes, Jotunn, loot, sets y nivel 20. Party de 1–4 y juego en PC/móvil.
> **Known issues:** `<lista>`
> Gracias por jugar la beta. Reporta bugs en `#reportar-bugs`.

**`launch-recursos`**
> **Cómo empezar en Vandrheim**
> Link de Roblox · Controles PC/móvil · Guía de clases y especializaciones · FAQ · Cómo unirte a una party.

**`launch-ideas`**
> **Ya jugaste la beta: ¿qué mejorarías?**
> Una publicación por idea. Explica el problema, la propuesta y el impacto esperado. Busca antes de publicar para no duplicar.

**`launch-bugs`**
> **¿Encontraste un bug en la beta?**
> Incluye pasos para reproducirlo, resultado esperado, resultado real, plataforma, versión y captura/video. En dungeon, agrega seed, piso y variante. No publiques exploits: envíalos por MD a moderación.

**`t7-teaser-helada`**
> La Helada no perdona. 5 pisos. Un trono. Pronto en Vandrheim.

**`t3-teaser-clases`**
> 3 clases. 6 especializaciones. ¿Cuál es la tuya?

**`t1-teaser-jotunn`**
> Jotunn, Guardián de la Escarcha. Mañana.

**`t7-teaser-fuego` (post-1.0, fuera de la secuencia de beta)**
> El hielo fue solo el principio. El fuego despierta en la próxima expansión de Vandrheim.

#### A.3 Assets requeridos

* `Assets/Launch/teaser-helada.png` — 1 imagen horizontal (1200×675 o similar).
* `Assets/Launch/class-card.png` — 3 clases / 6 specs.
* `Assets/Launch/jotunn-card.png` — Jotunn.
* `Assets/Launch/launch-main.png` — key art de beta.
* `Assets/Launch/launch-trailer.gif` o `.mp4` — trailer/GIF corto.
* `Assets/Launch/fire-teaser.png` — teaser de fuego/lava.
* Capturas para devlogs (2–3) y patch notes.
* Placeholder aprobado si falta un asset; el sistema no debe publicar imágenes rotas.

---

### Definition of Done (DoD)

* [ ] `config/announcements.json` con schema, timezone y paquete de beta del Anexo A.
* [ ] `/anuncio previsualizar | publicar | programar | cancelar | listar | reprogramar` funcionando y restringido.
* [ ] Scheduler con timezone, catch-up y anti-duplicados; state persistente atómico.
* [ ] Envío a texto, hilo y foro; embed, imagen, link, mención y pin.
* [ ] Validaciones de canal/rol/imagen/texto/fecha y permisos con mensajes claros.
* [ ] Logs de acciones/errores y notificación de `missed`/fallos.
* [ ] `/dcv-setup` sin regresiones.
* [ ] `README.md` actualizado con comandos, config, permisos y operación.
* [ ] QA en servidor/canal de prueba: preview, publish, schedule, restart, missed, cancel, forum-post.
* [ ] Evidencia adjunta (capturas, logs) y copys/assets aprobados por el PO.
* [ ] Programación real de la secuencia de beta acordada.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Timezone | `America/Argentina/Buenos_Aires` (configurable) |
| Intervalo del scheduler | 30 s (configurable) |
| Catch-up | 60 min de gracia; después `missed` + aviso |
| Crosspost | Deshabilitado en v1; opcional si `#anuncios` es Announcement |
| Menciones | Solo `@Anuncios`; nunca `@everyone`/`@here` |
| Pin | Sí en anuncios principales; no en foros |
| State | `data/announcements-state.json`, fuera de Git, escritura atómica |
| Autorización | Propietario o `ManageChannels` |
| Foros | `forum-post` con `threadName`, cuerpo y tags por nombre |
| Imágenes | Locales en `Assets/Launch/`; 8 MB máximo; png/jpg/jpeg/gif/webp |
| Texto | Cuerpo ≤ 2000; título ≤ 256; descripción de embed ≤ 4096 |
| Si falta asset | Bloquear publicación y avisar; no usar imagen rota |
| Si falta canal/rol | Rechazar con error; no crear canales/roles automáticamente |

---

### Estimación (orientativa)

2–3 sesiones del dev: modelo/config + comandos + scheduler/state + envío a foros + QA y documentación.

---

### Historial

| Fecha | Cambio |
|-------|--------|
| 2026-10-27 | Creación de HU-BOT-01: sistema de anuncios config-driven para el bot de DCV Studios, con preview, publicación, programación, cancelación, persistencia, catch-up, foros, logs y paquete de contenido de beta abierta de Vandrheim. |
| 2026-10-27 | Copy adaptado a **beta abierta** (no 1.0): apertura, patch notes, bienvenida y agradecimiento; el teaser de fuego/lava se movió a post-1.0. |
