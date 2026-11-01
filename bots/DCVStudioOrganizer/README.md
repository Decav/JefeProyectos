# DCV Studios Discord Bot

Bot privado de Discord para preparar y mantener la estructura inicial del servidor de DCV Studios.

## Qué hace

- Registra `/dcv-setup previsualizar` para mostrar cambios sin editar el servidor.
- Registra `/dcv-setup aplicar`, que pide confirmación antes de ordenar canales.
- Renombra las categorías conocidas y mueve/renombra los canales existentes para conservar su historial.
- Crea `#ideas-y-feedback` y `#reportar-bugs` como canales de foro con etiquetas para clasificar y seguir cada publicación.
- Crea los canales que falten y publica el mensaje de bienvenida/normas solo si el canal todavía está vacío.
- No borra categorías, canales ni mensajes.
- Puede enviar un saludo cuando entra una persona nueva si habilitas la intención privilegiada correspondiente.
- Incluye `/anuncio` para previsualizar, publicar con confirmación, programar, reprogramar, cancelar y listar anuncios.
- Conserva el estado de anuncios enviados/programados y recupera envíos vencidos dentro de una ventana de 60 minutos.

## Requisitos

- Node.js 20.6.0 o posterior (en esta carpeta ya está instalado Node.js 22.12.0).
- La aplicación de bot que ya creaste en Discord Developer Portal.
- Permisos para administrar canales en DCV Studios.

## Preparación local

1. En esta carpeta, copia `.env.example` como `.env`.
2. Completa `DISCORD_TOKEN`, `DISCORD_CLIENT_ID` y `DISCORD_GUILD_ID` en `.env`. El token es secreto: no lo pegues en el chat ni lo subas a Git.
3. En Discord Developer Portal > **OAuth2 > URL Generator**, selecciona los scopes `bot` y `applications.commands`.
4. Solicita estos permisos: `Manage Channels`, `Manage Roles`, `Manage Messages`, `Moderate Members`, `View Channel`, `Send Messages`, `Read Message History`, `Embed Links`, `Attach Files`, `Connect` y `Speak`. No hace falta `Administrator`.
5. Usa el enlace generado para añadir el bot a DCV Studios.
6. Si ya añadiste el bot con el enlace anterior, puedes habilitar esos permisos en **Ajustes del servidor > Roles > rol del bot**. Mantén el rol del bot por encima de los roles que vaya a administrar. Para publicaciones en hilos y foros, añade también `Create Public Threads` y `Send Messages in Threads`.
7. Activa **Comunidad** en **Ajustes del servidor > Activar Comunidad**. Discord exige Comunidad para crear foros. En la configuración puedes usar `#bienvenida-y-normas` como canal de reglas y `#anuncios` como canal de actualizaciones de Comunidad. ([Guía oficial para activar Comunidad](https://support.discord.com/hc/en-us/articles/360047132851-Enabling-Your-Community-Server), [preguntas frecuentes sobre foros](https://support.discord.com/hc/en-us/articles/6208479917079-Forum-Channels-FAQ))
8. Abre PowerShell en esta carpeta y ejecuta:

   ```powershell
   npm install
   npm run commands
   npm start
   ```

9. En Discord, ejecuta `/dcv-setup previsualizar`. Si la vista previa está bien, usa `/dcv-setup aplicar` y confirma el botón. Si Comunidad sigue desactivada, el bot bloqueará la aplicación completa y no hará cambios.

## Anuncios de lanzamiento

El catálogo está en `config/announcements.json`; la estructura de canales y roles sigue en `config/server.json`. El calendario del Anexo A está precargado como **borradores**: no contiene fechas de publicación. Los links de Roblox, la lista de problemas conocidos y algunos copys mantienen marcadores intencionales. El bot bloquea publicar o programar hasta corregir los marcadores, asignar links válidos y colocar los assets requeridos. No se inventó una fecha para la beta.

### Comandos

- `/anuncio previsualizar id` muestra el mensaje, destino, menciones, pin, crosspost, hora y errores que debes corregir. Puede llevar `canal` para previsualizar un destino alternativo.
- `/anuncio publicar id` pide confirmación antes de publicar. También acepta `canal`; la publicación queda en el canal elegido.
- `/anuncio programar id fecha-hora` guarda una publicación futura. Acepta ISO 8601 con zona, por ejemplo `2026-11-06T18:00:00-03:00`, o `DD/MM/AAAA HH:mm` en la zona configurada. `canal` es opcional; al seleccionarlo, queda guardado para ese anuncio programado.
- `/anuncio reprogramar id fecha-hora` cambia la hora de un anuncio programado y puede cambiar su `canal`.
- `/anuncio cancelar id` cancela un envío programado; no elimina mensajes publicados.
- `/anuncio listar` muestra estado, destino, horario e ID de mensaje.

Todos requieren que la persona sea dueña del servidor o tenga `Manage Channels`. El bot no usa `Administrator`. Revisa la respuesta del comando si falta un permiso en el canal específico; para foros, el bot revisa `View Channel`, `Create Public Threads` y `Send Messages in Threads`. Para imágenes locales también necesita `Attach Files`; para embeds, `Embed Links`; y para fijar mensajes, `Manage Messages`.

### Assets y preparación de contenido

Coloca los archivos aprobados en `Assets/Launch/` (la carpeta es relativa a la raíz del bot). La configuración inicial espera:

- `teaser-helada.png`
- `devlog-final.png`
- `class-card.png`
- `jotunn-card.png`
- `launch-main.png`
- `patch-notes.png`
- `launch-trailer.gif`
- `devlog-48h.png`

`launch-main.png` ya está incluido: es el thumbnail de Jotunn que se copió desde `Vandrheim-Roblox/Assets/Images/Marketing/Thumbnails/Candidates`. Los demás assets de la lista deben agregarse cuando estén aprobados. Los assets locales aceptados son PNG, JPG, JPEG, GIF o WEBP de hasta 8 MB. Una imagen remota debe ser HTTPS, tener extensión y tipo MIME de imagen permitidos, responder a una validación HEAD y declarar un tamaño menor a 8 MB. La ruta local debe existir antes de publicar. Los posts de foro de ideas y bugs usan una plantilla de texto y etiquetas; no se les asigna una imagen.

El enlace compartido de Roblox ya está configurado en los anuncios que lo usan. Completa en `config/announcements.json` los marcadores `[[FECHA_Y_HORA_CONFIRMADAS]]`, `[[KNOWN_ISSUES]]` y `[[HOTFIX_NOTES]]` antes de publicar esos anuncios. Los campos `publishAt` comienzan en `null`; la hora se fija con `/anuncio programar`.

### State, scheduler y logs

- El state se guarda en `data/announcements-state.json`, con escritura temporal y renombrado atómico. La carpeta `data/` está excluida de Git.
- Cada acción se registra en `data/announcements.log` en formato JSON Lines; los registros no incluyen copys ni tokens.
- El scheduler revisa cada 30 segundos mientras `npm start` siga activo. Si el bot se apaga, no puede enviar durante ese periodo.
- Al volver a iniciar, envía anuncios vencidos dentro de los 60 minutos de gracia con `late=true`; los más antiguos pasan a `missed` y se notifican en `#equipo-general` o, si el canal no está disponible, por DM a la persona propietaria.
- Un anuncio con `messageId` o estado `sent` no se vuelve a publicar. El state se conserva al reiniciar el bot.

Para aplicar cambios a los comandos, detén el bot con `Ctrl+C`, ejecuta `npm run commands` y vuelve a iniciar con `npm start`. El comando `/dcv-setup` conserva su comportamiento.

## Foros de ideas y errores

- `#ideas-y-feedback` será un foro con una publicación por propuesta y etiquetas como **Nueva idea**, **Gameplay**, **Balance**, **Interfaz**, **Aceptada** y **No planificada**.
- `#reportar-bugs` será un foro con una publicación por error y etiquetas como **Nuevo**, **Necesita información**, **Confirmado**, **En progreso** y **Resuelto**.
- Las etiquetas clasifican las publicaciones; las respuestas quedan agrupadas dentro de cada una. Este formato mantiene las ideas y los informes de errores organizados y fáciles de encontrar. ([Cómo funcionan los canales de foro](https://support.discord.com/hc/en-us/articles/6208479917079-Forum-Channels-FAQ))
- Si ya existe un canal de texto con alguno de esos nombres, el bot lo conserva como `*-archivo` y crea el foro nuevo. Así se mantiene el historial anterior.

El bot necesita los permisos que asignará a Administración y Moderación. Discord no permite que un bot otorgue permisos que él mismo no posee. ([Documentación de permisos de Discord](https://discord.com/developers/docs/topics/permissions#permission-hierarchy))

Los nombres, textos, colores, permisos de roles y canales están en `config/server.json`. La configuración reconoce las categorías y canales que ya existían en DCV Studios, para reutilizarlos en vez de duplicarlos.

## Roles iniciales

- **Fundador**: color y etiqueta visual; se intenta asignar automáticamente a quien es dueño del servidor.
- **Administración**: puede administrar canales, gestionar mensajes y aplicar timeout a miembros.
- **Moderación**: puede gestionar mensajes y aplicar timeout.
- **Desarrollo**, **Arte y Diseño** y **QA Tester**: acceso a la categoría privada de equipo.
- **Anuncios**: rol mencionable para avisos puntuales.

No se concede `Administrator`, `Kick Members` ni `Ban Members`. El bot crea los roles, pero deja las asignaciones del equipo para que decidas quién corresponde a cada área. Discord solo permite a un bot gestionar roles que estén por debajo de su rol más alto; coloca el rol del bot por encima de los roles que deba modificar. Para que Moderación pueda aplicar timeout, deja ese rol por encima de los roles de los miembros. ([Referencia de jerarquía de roles](https://discord.com/developers/docs/topics/permissions#permission-hierarchy))

La categoría **🔒 EQUIPO** queda visible solo para Fundador, Administración, Moderación, Desarrollo, Arte y Diseño y QA Tester. Al mover canales existentes hacia allí, sus permisos se sincronizan con los de la categoría; revisa la vista previa antes de confirmar.

## Saludo automático al entrar

El mensaje inicial y las normas se publican al aplicar la estructura. Si además quieres que el bot salude a cada persona que se una:

1. En Developer Portal > **Bot**, activa **Server Members Intent**.
2. Cambia `ENABLE_MEMBER_WELCOME=false` a `ENABLE_MEMBER_WELCOME=true` en `.env`.
3. Reinicia el bot con `npm start`.

## Seguridad

- `.env` está excluido de Git. No compartas el token del bot; si se expone, regénéralo desde Developer Portal.
- Usa un bot de aplicación, nunca automatices tu cuenta personal.
- El comando está restringido a la persona propietaria o a miembros con `Manage Channels`.
- Mantén el bot ejecutándose para que los comandos estén disponibles; cerrar la terminal detiene el proceso.
