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
6. Si ya añadiste el bot con el enlace anterior, puedes habilitar esos permisos en **Ajustes del servidor > Roles > rol del bot**. Mantén el rol del bot por encima de los roles que vaya a administrar.
7. Activa **Comunidad** en **Ajustes del servidor > Activar Comunidad**. Discord exige Comunidad para crear foros. En la configuración puedes usar `#bienvenida-y-normas` como canal de reglas y `#anuncios` como canal de actualizaciones de Comunidad. ([Guía oficial para activar Comunidad](https://support.discord.com/hc/en-us/articles/360047132851-Enabling-Your-Community-Server), [preguntas frecuentes sobre foros](https://support.discord.com/hc/en-us/articles/6208479917079-Forum-Channels-FAQ))
8. Abre PowerShell en esta carpeta y ejecuta:

   ```powershell
   npm install
   npm run commands
   npm start
   ```

9. En Discord, ejecuta `/dcv-setup previsualizar`. Si la vista previa está bien, usa `/dcv-setup aplicar` y confirma el botón. Si Comunidad sigue desactivada, el bot bloqueará la aplicación completa y no hará cambios.

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
