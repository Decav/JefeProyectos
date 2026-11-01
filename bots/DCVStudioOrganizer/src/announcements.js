import { appendFile, mkdir, readFile, rename, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  ActionRowBuilder,
  AttachmentBuilder,
  ButtonBuilder,
  ButtonStyle,
  ChannelType,
  EmbedBuilder,
  PermissionFlagsBits,
  SlashCommandBuilder,
} from 'discord.js';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const configPath = path.join(projectRoot, 'config', 'announcements.json');
const serverConfigPath = path.join(projectRoot, 'config', 'server.json');
const dataDirectory = path.join(projectRoot, 'data');
const statePath = path.join(dataDirectory, 'announcements-state.json');
const logPath = path.join(dataDirectory, 'announcements.log');
const maxImageBytes = 8 * 1024 * 1024;
const allowedImageExtensions = new Set(['.png', '.jpg', '.jpeg', '.gif', '.webp']);
const allowedStatuses = new Set(['draft', 'scheduled', 'sent', 'cancelled', 'missed']);
const scheduledActionLock = new Set();
const pendingConfirmations = new Map();

const announcementConfig = JSON.parse(await readFile(configPath, 'utf8'));
const serverConfig = JSON.parse(await readFile(serverConfigPath, 'utf8'));
const announcementById = new Map();

for (const announcement of announcementConfig.announcements ?? []) {
  if (!announcement?.id || announcementById.has(announcement.id)) {
    throw new Error(`ID de anuncio vacío o duplicado en ${configPath}.`);
  }
  if (!allowedStatuses.has(announcement.status)) {
    throw new Error(`Estado inicial inválido para el anuncio ${announcement.id}.`);
  }
  announcementById.set(announcement.id, announcement);
}

let state = { version: 1, announcements: {} };
let stateLoaded = false;
let stateWriteQueue = Promise.resolve();
let scheduler = null;
let schedulerClient = null;

export function buildAnnouncementCommands() {
  const command = new SlashCommandBuilder()
    .setName('anuncio')
    .setDescription('Previsualiza, publica y programa anuncios de DCV Studios.')
    .setDefaultMemberPermissions(PermissionFlagsBits.ManageChannels)
    .addSubcommand((subcommand) => subcommand
      .setName('previsualizar')
      .setDescription('Muestra un anuncio y sus validaciones sin modificar el state.')
      .addStringOption((option) => option
        .setName('id')
        .setDescription('ID del anuncio en config/announcements.json.')
        .setRequired(true)
        .setAutocomplete(true))
      .addStringOption((option) => option
        .setName('canal')
        .setDescription('Destino alternativo para esta previsualización.')
        .setAutocomplete(true)))
    .addSubcommand((subcommand) => subcommand
      .setName('publicar')
      .setDescription('Pide confirmación y publica un anuncio una sola vez.')
      .addStringOption((option) => option
        .setName('id')
        .setDescription('ID del anuncio en config/announcements.json.')
        .setRequired(true)
        .setAutocomplete(true))
      .addStringOption((option) => option
        .setName('canal')
        .setDescription('Destino alternativo de esta publicación.')
        .setAutocomplete(true)))
    .addSubcommand((subcommand) => subcommand
      .setName('programar')
      .setDescription('Programa un anuncio con fecha ISO 8601 o DD/MM/AAAA HH:mm.')
      .addStringOption((option) => option
        .setName('id')
        .setDescription('ID del anuncio en config/announcements.json.')
        .setRequired(true)
        .setAutocomplete(true))
      .addStringOption((option) => option
        .setName('fecha-hora')
        .setDescription(`Fecha futura; zona horaria ${announcementConfig.timezone}.`)
        .setRequired(true))
      .addStringOption((option) => option
        .setName('canal')
        .setDescription('Canal donde publicar; si se omite, usa el configurado.')
        .setAutocomplete(true)))
    .addSubcommand((subcommand) => subcommand
      .setName('cancelar')
      .setDescription('Cancela un anuncio programado.')
      .addStringOption((option) => option
        .setName('id')
        .setDescription('ID del anuncio programado.')
        .setRequired(true)
        .setAutocomplete(true)))
    .addSubcommand((subcommand) => subcommand
      .setName('listar')
      .setDescription('Lista estados, destinos y horarios de los anuncios.'))
    .addSubcommand((subcommand) => subcommand
      .setName('reprogramar')
      .setDescription('Cambia la hora de un anuncio que ya está programado.')
      .addStringOption((option) => option
        .setName('id')
        .setDescription('ID del anuncio programado.')
        .setRequired(true)
        .setAutocomplete(true))
      .addStringOption((option) => option
        .setName('fecha-hora')
        .setDescription(`Nueva fecha futura; zona horaria ${announcementConfig.timezone}.`)
        .setRequired(true))
      .addStringOption((option) => option
        .setName('canal')
        .setDescription('Nuevo destino; si se omite, conserva el programado.')
        .setAutocomplete(true)));

  return command;
}

function normalize(value) {
  return String(value ?? '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLocaleLowerCase('es')
    .replace(/[^\p{L}\p{N}]/gu, '');
}

function channelDefinitions() {
  return serverConfig.categories.flatMap((category) => category.channels);
}

function resolveChannel(guild, configuredName) {
  const definition = channelDefinitions().find((item) =>
    [item.name, ...(item.aliases ?? [])].some((candidate) => normalize(candidate) === normalize(configuredName)),
  );
  const acceptedNames = definition
    ? [definition.name, ...(definition.aliases ?? [])]
    : [configuredName];
  return guild.channels.cache.find((channel) =>
    acceptedNames.some((name) => normalize(name) === normalize(channel.name)),
  ) ?? null;
}

function resolveRole(guild, key) {
  if (!key) return null;
  const roleDefinition = serverConfig.roles.find((role) => role.key === key);
  if (!roleDefinition) return null;
  const accepted = [roleDefinition.name, ...(roleDefinition.aliases ?? [])].map(normalize);
  return guild.roles.cache.find((role) => accepted.includes(normalize(role.name))) ?? null;
}

async function ensureStateLoaded() {
  if (stateLoaded) return;
  try {
    const saved = JSON.parse(await readFile(statePath, 'utf8'));
    if (!saved || saved.version !== 1 || typeof saved.announcements !== 'object' || Array.isArray(saved.announcements)) {
      throw new Error('El state de anuncios no tiene el formato esperado.');
    }
    state = saved;
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
  stateLoaded = true;
}

async function writeState() {
  stateWriteQueue = stateWriteQueue.catch(() => {}).then(async () => {
    await mkdir(dataDirectory, { recursive: true });
    const temporaryPath = `${statePath}.${process.pid}.${Date.now()}.tmp`;
    await writeFile(temporaryPath, `${JSON.stringify(state, null, 2)}\n`, 'utf8');
    await rename(temporaryPath, statePath);
  });
  return stateWriteQueue;
}

async function updateState(announcementId, changes) {
  await ensureStateLoaded();
  const previous = state.announcements[announcementId] ?? {};
  state.announcements[announcementId] = { ...previous, ...changes };
  await writeState();
  return state.announcements[announcementId];
}

async function logAction({ announcementId, action, userId = null, channelId = null, messageId = null, late = false, error = null }) {
  const entry = {
    timestamp: new Date().toISOString(),
    announcementId,
    action,
    userId,
    channelId,
    messageId,
    late: Boolean(late),
    error: error ? String(error).slice(0, 500) : null,
  };
  try {
    await mkdir(dataDirectory, { recursive: true });
    await appendFile(logPath, `${JSON.stringify(entry)}\n`, 'utf8');
  } catch (writeError) {
    console.error('No pude escribir en data/announcements.log:', writeError.message);
  }
  if (error) console.error(`[anuncios:${action}] ${announcementId}: ${entry.error}`);
}

function runtimeRecord(announcement) {
  const saved = state.announcements[announcement.id] ?? {};
  return { ...announcement, ...saved };
}

function selectedDestination(announcement, requestedChannelName = null) {
  if (requestedChannelName) return requestedChannelName;
  return runtimeRecord(announcement).channelOverride || announcement.channel;
}

function mentionRoleKeyFor(announcement) {
  return Object.hasOwn(announcement, 'mentionRoleKey')
    ? announcement.mentionRoleKey
    : announcementConfig.defaultMentionRoleKey ?? null;
}

function statusFor(announcement) {
  return runtimeRecord(announcement).status ?? 'draft';
}

function formatOffsetDate(timestamp, timezone) {
  const date = new Date(timestamp);
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: timezone,
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', second: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(date);
  const values = Object.fromEntries(parts.map((part) => [part.type, part.value]));
  const localAsUtc = Date.UTC(
    Number(values.year), Number(values.month) - 1, Number(values.day),
    Number(values.hour), Number(values.minute), Number(values.second),
  );
  const offsetMinutes = Math.round((localAsUtc - date.getTime()) / 60_000);
  const sign = offsetMinutes >= 0 ? '+' : '-';
  const offset = Math.abs(offsetMinutes);
  const hours = String(Math.floor(offset / 60)).padStart(2, '0');
  const minutes = String(offset % 60).padStart(2, '0');
  return `${values.year}-${values.month}-${values.day}T${values.hour}:${values.minute}:${values.second}${sign}${hours}:${minutes}`;
}

function localTimeToTimestamp({ year, month, day, hour, minute }, timezone) {
  const targetUtc = Date.UTC(year, month - 1, day, hour, minute);
  let candidate = targetUtc;
  for (let attempt = 0; attempt < 4; attempt += 1) {
    const parts = new Intl.DateTimeFormat('en-CA', {
      timeZone: timezone,
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit', hourCycle: 'h23',
    }).formatToParts(new Date(candidate));
    const values = Object.fromEntries(parts.map((part) => [part.type, Number(part.value)]));
    const representedUtc = Date.UTC(values.year, values.month - 1, values.day, values.hour, values.minute);
    const difference = targetUtc - representedUtc;
    if (difference === 0) break;
    candidate += difference;
  }
  const check = new Intl.DateTimeFormat('en-CA', {
    timeZone: timezone,
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', hourCycle: 'h23',
  }).formatToParts(new Date(candidate));
  const values = Object.fromEntries(check.map((part) => [part.type, Number(part.value)]));
  if (values.year !== year || values.month !== month || values.day !== day || values.hour !== hour || values.minute !== minute) {
    throw new Error(`La fecha local no existe en ${timezone}; revisa el día o el cambio de horario.`);
  }
  return candidate;
}

function parsePublishDate(input) {
  const value = String(input ?? '').trim();
  const isoWithOffset = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2}(?:\.\d{1,3})?)?(?:Z|[+-]\d{2}:\d{2})$/i;
  let timestamp;
  if (isoWithOffset.test(value)) {
    timestamp = Date.parse(value);
  } else {
    const localMatch = /^(\d{2})\/(\d{2})\/(\d{4})\s+(\d{2}):(\d{2})$/.exec(value);
    if (!localMatch) {
      throw new Error('Usa ISO 8601 con zona (2026-11-06T18:00:00-03:00) o DD/MM/AAAA HH:mm en la zona configurada.');
    }
    const [, dayText, monthText, yearText, hourText, minuteText] = localMatch;
    const parts = {
      day: Number(dayText), month: Number(monthText), year: Number(yearText),
      hour: Number(hourText), minute: Number(minuteText),
    };
    if (parts.month < 1 || parts.month > 12 || parts.day < 1 || parts.day > 31 ||
        parts.hour > 23 || parts.minute > 59) {
      throw new Error('La fecha u hora no es válida.');
    }
    timestamp = localTimeToTimestamp(parts, announcementConfig.timezone);
  }
  if (!Number.isFinite(timestamp)) throw new Error('La fecha u hora no es válida.');
  if (timestamp <= Date.now()) throw new Error('La fecha debe ser futura.');
  return { timestamp, isoWithOffset: formatOffsetDate(timestamp, announcementConfig.timezone) };
}

function imageFilePath(image) {
  if (typeof image !== 'string' || !image.trim()) return null;
  const resolved = path.resolve(projectRoot, image);
  if (resolved !== projectRoot && !resolved.startsWith(`${projectRoot}${path.sep}`)) {
    throw new Error('La ruta de imagen debe quedarse dentro de la carpeta del bot.');
  }
  return resolved;
}

function isHttpsImageUrl(imageUrl) {
  try {
    const url = new URL(imageUrl);
    return url.protocol === 'https:' && !url.username && !url.password &&
      allowedImageExtensions.has(path.extname(url.pathname).toLowerCase());
  } catch {
    return false;
  }
}

function isValidRobloxExperienceUrl(url) {
  if (!/(^|\.)roblox\.com$/i.test(url.hostname)) return true;
  if (/^\/games\/\d+(?:\/|$)/.test(url.pathname)) return true;
  return url.pathname === '/share' &&
    /^[a-f0-9]{32}$/i.test(url.searchParams.get('code') ?? '') &&
    url.searchParams.get('type') === 'ExperienceDetails';
}

async function validateRemoteImage(imageUrl) {
  let response;
  try {
    response = await fetch(imageUrl, { method: 'HEAD', signal: AbortSignal.timeout(5000), redirect: 'follow' });
  } catch (error) {
    throw new Error(error.name === 'TimeoutError' ? 'la solicitud superó 5 segundos' : 'falló la solicitud HTTPS');
  }
  if (!response.ok) throw new Error(`El servidor de imagen respondió HTTP ${response.status}.`);
  const finalUrl = new URL(response.url || imageUrl);
  if (finalUrl.protocol !== 'https:') throw new Error('La imagen redirige fuera de HTTPS.');
  const contentType = (response.headers.get('content-type') ?? '').split(';')[0].trim().toLowerCase();
  if (!['image/png', 'image/jpeg', 'image/gif', 'image/webp'].includes(contentType)) {
    throw new Error(`La URL no entrega un formato de imagen permitido (Content-Type: ${contentType || 'desconocido'}).`);
  }
  const contentLength = Number(response.headers.get('content-length'));
  if (!Number.isFinite(contentLength)) {
    throw new Error('El servidor no informó el tamaño de la imagen; no puedo verificar el límite de 8 MB.');
  }
  if (Number.isFinite(contentLength) && contentLength > maxImageBytes) {
    throw new Error('La imagen remota supera el límite de 8 MB.');
  }
}

async function inspectAnnouncement(announcement, guild, client, { checkPermissions = false, targetChannelName = null } = {}) {
  const errors = [];
  const notes = [];
  const destination = selectedDestination(announcement, targetChannelName);
  const channel = resolveChannel(guild, destination);
  let role = null;
  let imagePath = null;
  let imageName = null;
  let imageRemote = null;

  if (!channel) {
    errors.push(`No existe el canal destino «${destination}».`);
  } else if (announcement.mode === 'forum-post' && channel.type !== ChannelType.GuildForum) {
    errors.push(`«${channel.name}» no es un canal de foro; forum-post requiere un foro.`);
  } else if (announcement.mode !== 'forum-post' &&
    ![ChannelType.GuildText, ChannelType.GuildAnnouncement].includes(channel.type)) {
    errors.push(`«${channel.name}» no es un canal de texto compatible con ${announcement.mode}.`);
  }

  if (!['announcement', 'forum-post', 'thread'].includes(announcement.mode)) {
    errors.push(`Modo desconocido: ${announcement.mode}.`);
  }
  if (!announcement.title || announcement.title.length > 256) {
    errors.push('El título debe tener entre 1 y 256 caracteres.');
  }
  if (typeof announcement.body !== 'string' || !announcement.body.trim()) {
    errors.push('El cuerpo del anuncio está vacío.');
  } else if (announcement.body.length > 2000) {
    errors.push(`El cuerpo tiene ${announcement.body.length} caracteres; Discord permite hasta 2000.`);
  }
  if (typeof announcement.body === 'string' && /\[\[[A-Z0-9_ -]+\]\]/.test(announcement.body)) {
    errors.push('El texto conserva campos por completar como [[ROBLOX_GAME_URL]] o [[KNOWN_ISSUES]].');
  }
  if (announcement.mode !== 'forum-post' && !announcement.image && !announcement.imageUrl) {
    errors.push('Falta la imagen requerida para esta publicación.');
  }
  if (announcement.image && announcement.imageUrl) {
    errors.push('Configura solo una opción de imagen: image o imageUrl.');
  }
  if (announcement.image) {
    try {
      imagePath = imageFilePath(announcement.image);
      const extension = path.extname(imagePath).toLowerCase();
      if (!allowedImageExtensions.has(extension)) {
        errors.push('La imagen debe ser PNG, JPG, JPEG, GIF o WEBP.');
      } else {
        const fileInfo = await stat(imagePath).catch((error) => error.code === 'ENOENT' ? null : Promise.reject(error));
        if (!fileInfo?.isFile()) {
          errors.push(`No se encontró el asset ${announcement.image}; añade un archivo aprobado antes de publicar.`);
          imagePath = null;
        } else if (fileInfo.size > maxImageBytes) {
          errors.push(`El asset ${announcement.image} supera el límite de 8 MB.`);
          imagePath = null;
        } else {
          imageName = path.basename(imagePath);
        }
      }
    } catch (error) {
      errors.push(error.message);
    }
  }
  if (announcement.imageUrl) {
    if (!isHttpsImageUrl(announcement.imageUrl)) {
      errors.push('imageUrl debe ser HTTPS y terminar en PNG, JPG, JPEG, GIF o WEBP.');
    } else {
      try {
        await validateRemoteImage(announcement.imageUrl);
        imageRemote = announcement.imageUrl;
      } catch (error) {
        errors.push(`No pude validar imageUrl: ${error.message}`);
      }
    }
  }
  if (announcement.color && !/^#[0-9A-F]{6}$/i.test(announcement.color)) {
    errors.push('El color debe usar formato hexadecimal #RRGGBB.');
  }

  const threadName = announcement.threadName || announcement.title;
  if (announcement.mode !== 'announcement' && (!threadName || threadName.length > 100)) {
    errors.push('El nombre del post o hilo debe tener entre 1 y 100 caracteres.');
  }
  if (announcement.mode === 'forum-post' && (announcement.forumTags ?? []).length > 5) {
    errors.push('Un post de foro puede usar hasta 5 etiquetas.');
  }

  if (announcement.link) {
    let url;
    try {
      url = new URL(announcement.link.url);
    } catch {
      url = null;
    }
    if (!url || url.protocol !== 'https:' || !announcement.link.label || announcement.link.label.length > 80) {
      errors.push('El botón requiere una etiqueta de hasta 80 caracteres y una URL HTTPS válida.');
    }
    if (url && !isValidRobloxExperienceUrl(url)) {
      errors.push('El enlace de Roblox todavía no tiene el ID de la experiencia confirmado.');
    }
  }

  const mentionRoleKey = mentionRoleKeyFor(announcement);
  if (mentionRoleKey) {
    role = resolveRole(guild, mentionRoleKey);
    if (!role) errors.push(`No existe el rol configurado con key «${mentionRoleKey}» en server.json.`);
  }

  if (announcement.mode === 'forum-post' && channel?.type === ChannelType.GuildForum) {
    const tagsByName = new Map((channel.availableTags ?? []).map((tag) => [normalize(tag.name), tag]));
    for (const tagName of announcement.forumTags ?? []) {
      if (!tagsByName.has(normalize(tagName))) errors.push(`Falta la etiqueta «${tagName}» en el foro #${channel.name}.`);
    }
  }

  if (announcement.pin && announcement.mode === 'forum-post') {
    errors.push('pin no se aplica a un post de foro; usa forumTags para destacarlo por estado.');
  }
  if (announcement.crosspost && channel?.type !== ChannelType.GuildAnnouncement) {
    notes.push('crosspost se omitirá porque el destino no es un canal Announcement.');
  }

  const missingPermissions = [];
  if (checkPermissions && channel && client.user) {
    const permissions = channel.permissionsFor(client.user);
    const needed = new Map([
      [PermissionFlagsBits.ViewChannel, 'Ver canal'],
    ]);
    if (announcement.mode === 'announcement') {
      needed.set(PermissionFlagsBits.SendMessages, 'Enviar mensajes');
      needed.set(PermissionFlagsBits.EmbedLinks, 'Insertar enlaces');
    } else if (announcement.mode === 'thread') {
      needed.set(PermissionFlagsBits.SendMessages, 'Enviar mensajes');
      needed.set(PermissionFlagsBits.EmbedLinks, 'Insertar enlaces');
      needed.set(PermissionFlagsBits.CreatePublicThreads, 'Crear hilos públicos');
      needed.set(PermissionFlagsBits.SendMessagesInThreads, 'Enviar mensajes en hilos');
    } else if (announcement.mode === 'forum-post') {
      needed.set(PermissionFlagsBits.CreatePublicThreads, 'Crear publicaciones en foros');
      needed.set(PermissionFlagsBits.SendMessagesInThreads, 'Enviar mensajes en hilos');
      if (imageRemote) needed.set(PermissionFlagsBits.EmbedLinks, 'Insertar enlaces');
    }
    if (imagePath) needed.set(PermissionFlagsBits.AttachFiles, 'Adjuntar archivos');
    if (role && !role.mentionable) needed.set(PermissionFlagsBits.MentionEveryone, 'Mencionar roles no mencionables');
    for (const [permission, label] of needed) {
      if (!permissions?.has(permission)) missingPermissions.push(label);
    }
    if (announcement.crosspost && channel.type === ChannelType.GuildAnnouncement &&
        !permissions?.has(PermissionFlagsBits.ManageMessages)) {
      notes.push('Falta Gestionar mensajes; el post se publicará pero no se podrá crosspostear.');
    }
    if (announcement.pin && !permissions?.has(PermissionFlagsBits.ManageMessages)) {
      notes.push('Falta Gestionar mensajes; se intentará publicar y fijar, pero puede quedar sin pin.');
    }
  }
  if (missingPermissions.length) {
    errors.push(`Al bot le faltan permisos en #${channel?.name ?? announcement.channel}: ${missingPermissions.join(', ')}.`);
  }

  return { errors, notes, channel, role, imagePath, imageName, imageRemote, threadName };
}

function buildEmbed(announcement, { imageName = null, imageRemote = null } = {}) {
  const color = Number.parseInt((announcement.color ?? '#C89445').slice(1), 16);
  const embed = new EmbedBuilder()
    .setColor(Number.isFinite(color) ? color : 0xC89445)
    .setTitle(announcement.title)
    .setFooter({ text: `DCV Studios · ${announcement.id}` });
  if (announcement.mode === 'announcement' || announcement.mode === 'thread') {
    embed.setDescription(announcement.body);
  }
  if (imageName) embed.setImage(`attachment://${imageName}`);
  if (imageRemote) embed.setImage(imageRemote);
  return embed;
}

function linkComponents(announcement) {
  if (!announcement.link) return [];
  let linkUrl;
  try {
    linkUrl = new URL(announcement.link.url);
  } catch {
    return [];
  }
  if (linkUrl.protocol !== 'https:' || !announcement.link.label || announcement.link.label.length > 80 ||
      !isValidRobloxExperienceUrl(linkUrl)) return [];
  const button = new ButtonBuilder()
    .setLabel(announcement.link.label)
    .setURL(announcement.link.url)
    .setStyle(ButtonStyle.Link);
  return [new ActionRowBuilder().addComponents(button)];
}

function mentionPayload(role) {
  return {
    content: role ? role.toString() : undefined,
    allowedMentions: { parse: [], roles: role ? [role.id] : [], repliedUser: false },
  };
}

function isAuthorized(interaction) {
  return interaction.guild && (
    interaction.user.id === interaction.guild.ownerId ||
    interaction.memberPermissions?.has(PermissionFlagsBits.ManageChannels)
  );
}

function statusLabel(record) {
  if (record.status === 'sent' && record.late) return 'sent (atrasado)';
  return record.status ?? 'draft';
}

function formatSchedule(record) {
  return record.publishAt ? record.publishAt.replace('T', ' ') : 'sin programar';
}

function previewEmbed(announcement, inspection) {
  const embed = buildEmbed(announcement, inspection);
  if (announcement.mode === 'forum-post') {
    embed.setDescription(announcement.body);
  }
  return embed;
}

async function respondWithPreview(interaction, announcement, { log = true, targetChannelName = null } = {}) {
  await ensureStateLoaded();
  const inspection = await inspectAnnouncement(announcement, interaction.guild, interaction.client, {
    targetChannelName,
    checkPermissions: true,
  });
  if (log) await logAction({
    announcementId: announcement.id,
    action: 'preview',
    userId: interaction.user.id,
    channelId: inspection.channel?.id ?? null,
  });
  const record = runtimeRecord(announcement);
  const destination = inspection.channel ? `<#${inspection.channel.id}>` : `#${announcement.channel} (no encontrado)`;
  const mentionRoleKey = mentionRoleKeyFor(announcement);
  const mention = mentionRoleKey ? `@${inspection.role?.name ?? mentionRoleKey}` : 'sin mención';
  const metadata = [
    `**${announcement.id}** · fase ${announcement.phase} · estado **${statusLabel(record)}**`,
    `Destino: ${destination} · modo: **${announcement.mode}**`,
    `Mención: ${mention} · pin: ${announcement.pin ? 'sí' : 'no'} · crosspost: ${announcement.crosspost ? 'sí' : 'no'}`,
    `Horario: ${record.publishAt ?? 'sin programar'} (${announcementConfig.timezone})`,
    ...(announcement.mode !== 'announcement' ? [`Hilo/post: ${inspection.threadName}`] : []),
    ...(announcement.mode === 'forum-post' ? [`Etiquetas: ${(announcement.forumTags ?? []).join(', ') || 'ninguna'}`] : []),
    ...(inspection.errors.length ? [`⛔ **No se puede publicar:**\n${inspection.errors.map((error) => `• ${error}`).join('\n')}`] : ['✅ Validaciones de contenido completas.']),
    ...inspection.notes.map((note) => `ℹ️ ${note}`),
  ];
  await interaction.reply({
    content: metadata.join('\n').slice(0, 1900),
    embeds: [previewEmbed(announcement, inspection)],
    components: linkComponents(announcement),
    ephemeral: true,
  });
}

async function notifyOwner(client, guild, message) {
  const notifyChannel = resolveChannel(guild, announcementConfig.adminNotifyChannel);
  if (notifyChannel?.isTextBased()) {
    const delivered = await notifyChannel.send({ content: message, allowedMentions: { parse: [] } })
      .then(() => true)
      .catch((error) => {
        console.error('No pude notificar al canal de administración:', error.message);
        return false;
      });
    if (delivered) return;
  }
  try {
    const owner = await guild.members.fetch(guild.ownerId);
    await owner.send(message);
  } catch (error) {
    console.error('No pude notificar por DM a la persona propietaria:', error.message);
  }
}

async function sendAnnouncement(client, guild, announcement, { late = false, userId = null, targetChannelName = null } = {}) {
  await ensureStateLoaded();
  const record = runtimeRecord(announcement);
  if (record.messageId || record.status === 'sent') {
    throw new Error(`El anuncio ${announcement.id} ya fue enviado (messageId ${record.messageId ?? 'guardado'}).`);
  }
  if (record.status === 'cancelled' || record.status === 'missed') {
    throw new Error(`El anuncio está en estado ${record.status}; reprográmalo antes de publicar.`);
  }
  if (scheduledActionLock.has(announcement.id)) {
    throw new Error('Este anuncio ya está en proceso de envío. Espera un momento y consulta /anuncio listar.');
  }
  scheduledActionLock.add(announcement.id);
  try {
    const inspection = await inspectAnnouncement(announcement, guild, client, { checkPermissions: true, targetChannelName });
    if (inspection.errors.length) throw new Error(inspection.errors.join(' '));
    const { channel, role, imagePath, imageName, imageRemote } = inspection;
    const embed = buildEmbed(announcement, { imageName, imageRemote });
    const components = linkComponents(announcement);
    const mention = mentionPayload(role);
    const files = imagePath ? [new AttachmentBuilder(imagePath, { name: imageName })] : [];
    let message;
    let thread = null;
    const sendOptions = {
      ...mention,
      files,
      components,
      allowedMentions: mention.allowedMentions,
    };

    if (announcement.mode === 'announcement') {
      message = await channel.send({ ...sendOptions, embeds: [embed] });
    } else if (announcement.mode === 'thread') {
      message = await channel.send({ ...sendOptions, embeds: [embed] });
      thread = await message.startThread({ name: inspection.threadName });
    } else {
      const tags = new Map((channel.availableTags ?? []).map((tag) => [normalize(tag.name), tag.id]));
      const appliedTags = (announcement.forumTags ?? []).map((name) => tags.get(normalize(name)));
      if (appliedTags.some((id) => !id)) throw new Error('Una etiqueta del foro dejó de existir; revisa las etiquetas y vuelve a intentarlo.');
      if (`${role ? `${role} ` : ''}${announcement.body}`.length > 2000) {
        throw new Error('La mención y el cuerpo superan juntos el límite de 2000 caracteres de Discord.');
      }
      const forumMessage = {
        content: `${role ? `${role} ` : ''}${announcement.body}`,
        allowedMentions: mention.allowedMentions,
        ...(files.length ? { files } : {}),
        ...(components.length ? { components } : {}),
        ...(imageRemote ? { embeds: [new EmbedBuilder().setImage(imageRemote).setColor(0xC89445)] } : {}),
      };
      thread = await channel.threads.create({
        name: inspection.threadName,
        appliedTags,
        message: forumMessage,
        reason: `Anuncio ${announcement.id} de DCV Studios`,
      });
      message = await thread.fetchStarterMessage().catch(() => null);
    }

    const warnings = [...inspection.notes];
    let pinError = null;
    if (announcement.pin && message) {
      try {
        await message.pin(`Anuncio ${announcement.id}`);
      } catch (error) {
        pinError = error.message;
        warnings.push(`El mensaje se publicó, pero no pude fijarlo: ${error.message}`);
        await logAction({
          announcementId: announcement.id,
          action: 'error',
          userId,
          channelId: channel.id,
          messageId: message.id,
          error: `pin: ${error.message}`,
        });
      }
    }

    let crosspostError = null;
    if (announcement.crosspost && channel.type === ChannelType.GuildAnnouncement && message) {
      try {
        await message.crosspost();
      } catch (error) {
        crosspostError = error.message;
        warnings.push(`El mensaje se publicó, pero crosspost falló: ${error.message}`);
        await logAction({
          announcementId: announcement.id,
          action: 'error',
          userId,
          channelId: channel.id,
          messageId: message.id,
          error: `crosspost: ${error.message}`,
        });
      }
    }

    const messageId = message?.id ?? thread?.id ?? null;
    const sentAt = new Date().toISOString();
    await updateState(announcement.id, {
      status: 'sent',
      sentAt,
      messageId,
      channelId: channel.id,
      ...(thread ? { threadId: thread.id } : {}),
      late: Boolean(late),
      ...(pinError ? { pinError } : { pinError: null }),
      ...(crosspostError ? { crosspostError } : { crosspostError: null }),
      lastError: null,
      nextAttemptAt: null,
    });
    await logAction({
      announcementId: announcement.id,
      action: 'send',
      userId,
      channelId: channel.id,
      messageId,
      late,
    });
    return { channel, messageId, threadId: thread?.id ?? null, late, warnings };
  } finally {
    scheduledActionLock.delete(announcement.id);
  }
}

async function requireReadyToSchedule(announcement, guild, client, targetChannelName = null) {
  const inspection = await inspectAnnouncement(announcement, guild, client, { checkPermissions: true, targetChannelName });
  if (inspection.errors.length) throw new Error(inspection.errors.join(' '));
}

async function showList(interaction) {
  await ensureStateLoaded();
  const rows = announcementConfig.announcements.slice(0, 20).map((announcement) => {
    const record = runtimeRecord(announcement);
    const channel = record.channelId
      ? interaction.guild.channels.cache.get(record.channelId)
      : resolveChannel(interaction.guild, record.channelOverride || announcement.channel);
    const message = record.messageId ? ` · msg ${record.messageId}` : '';
    return `**${announcement.id}** · **${statusLabel(record)}** · ${channel ? `<#${channel.id}>` : `#${announcement.channel}`} · ${formatSchedule(record)}${message}`;
  });
  const embed = new EmbedBuilder()
    .setColor(0xC89445)
    .setTitle('Anuncios de Vandrheim')
    .setDescription(rows.join('\n') || 'No hay anuncios configurados.')
    .setFooter({ text: `Zona horaria: ${announcementConfig.timezone}` });
  await interaction.reply({ embeds: [embed], ephemeral: true });
}

async function handleCommand(interaction) {
  if (!interaction.inGuild() || interaction.guildId !== process.env.DISCORD_GUILD_ID) {
    await interaction.reply({ content: 'Este comando solo está habilitado en el servidor configurado de DCV Studios.', ephemeral: true });
    return;
  }
  if (!isAuthorized(interaction)) {
    await interaction.reply({ content: 'Solo la persona propietaria o alguien con Administrar canales puede usar este comando.', ephemeral: true });
    return;
  }
  await ensureStateLoaded();
  const subcommand = interaction.options.getSubcommand();
  if (subcommand === 'listar') {
    await logAction({ announcementId: '*', action: 'list', userId: interaction.user.id });
    await showList(interaction);
    return;
  }
  const announcementId = interaction.options.getString('id', true);
  const requestedChannelName = interaction.options.getString('canal');
  const announcement = announcementById.get(announcementId);
  if (!announcement) {
    await interaction.reply({ content: `No existe el anuncio **${announcementId}** en config/announcements.json.`, ephemeral: true });
    return;
  }
  const record = runtimeRecord(announcement);

  if (subcommand === 'previsualizar') {
    await respondWithPreview(interaction, announcement, { targetChannelName: requestedChannelName });
    return;
  }

  if (subcommand === 'publicar') {
    if (record.messageId || record.status === 'sent') {
      await interaction.reply({ content: `**${announcementId}** ya está enviado; no lo publicaré dos veces.`, ephemeral: true });
      return;
    }
    if (record.status === 'cancelled' || record.status === 'missed') {
      await interaction.reply({ content: `El anuncio está **${record.status}**; usa /anuncio programar con una fecha nueva antes de publicarlo.`, ephemeral: true });
      return;
    }
    const targetChannelName = selectedDestination(announcement, requestedChannelName);
    const inspection = await inspectAnnouncement(announcement, interaction.guild, interaction.client, { checkPermissions: true, targetChannelName });
    if (inspection.errors.length) {
      await logAction({ announcementId, action: 'error', userId: interaction.user.id, channelId: inspection.channel?.id ?? null, error: inspection.errors.join(' ') });
      await interaction.reply({ content: `No se puede publicar:\n${inspection.errors.map((error) => `• ${error}`).join('\n')}`.slice(0, 1900), ephemeral: true });
      return;
    }
    const confirmId = `${interaction.id}:${announcementId}`;
    for (const [key, pending] of pendingConfirmations) {
      if (pending.expiresAt < Date.now()) pendingConfirmations.delete(key);
    }
    pendingConfirmations.set(confirmId, { userId: interaction.user.id, guildId: interaction.guildId, targetChannelName, expiresAt: Date.now() + 60_000 });
    const row = new ActionRowBuilder().addComponents(
      new ButtonBuilder().setCustomId(`announcement-confirm:${confirmId}`).setLabel('Confirmar publicación').setStyle(ButtonStyle.Danger),
      new ButtonBuilder().setCustomId(`announcement-cancel:${confirmId}`).setLabel('Cancelar').setStyle(ButtonStyle.Secondary),
    );
    await logAction({ announcementId, action: 'publish', userId: interaction.user.id, channelId: inspection.channel.id });
    await interaction.reply({
      content: `Vas a publicar **${announcement.title}** en <#${inspection.channel.id}>. El contenido se enviará públicamente y no se repetirá si ya queda registrado.\n\n¿Confirmas?`,
      components: [row],
      ephemeral: true,
    });
    return;
  }

  if (subcommand === 'programar' || subcommand === 'reprogramar') {
    const isRescheduling = subcommand === 'reprogramar';
    if (record.messageId || record.status === 'sent') {
      await interaction.reply({ content: `**${announcementId}** ya está enviado y no se puede programar.`, ephemeral: true });
      return;
    }
    if (isRescheduling && record.status !== 'scheduled') {
      await interaction.reply({ content: `Solo puedes reprogramar anuncios en estado **scheduled**; este está **${record.status}**.`, ephemeral: true });
      return;
    }
    if (!isRescheduling && !['draft', 'cancelled', 'missed'].includes(record.status)) {
      await interaction.reply({ content: `No se puede programar un anuncio en estado **${record.status}**.`, ephemeral: true });
      return;
    }
    const dateInput = interaction.options.getString('fecha-hora', true);
    const targetChannelName = selectedDestination(announcement, requestedChannelName);
    let parsed;
    try {
      parsed = parsePublishDate(dateInput);
      await requireReadyToSchedule(announcement, interaction.guild, interaction.client, targetChannelName);
    } catch (error) {
      await logAction({ announcementId, action: 'error', userId: interaction.user.id, error: error.message });
      await interaction.reply({ content: `No se pudo programar: ${error.message}`.slice(0, 1900), ephemeral: true });
      return;
    }
    await updateState(announcementId, {
      status: 'scheduled',
      publishAt: parsed.isoWithOffset,
      channelOverride: targetChannelName === announcement.channel ? null : targetChannelName,
      late: false,
      lastError: null,
      nextAttemptAt: null,
      ...(record.messageId ? { messageId: null } : {}),
    });
    await logAction({ announcementId, action: isRescheduling ? 'reschedule' : 'schedule', userId: interaction.user.id });
    await interaction.reply({
      content: `✅ **${announcement.title}** quedó **${isRescheduling ? 'reprogramado' : 'programado'}** para **${parsed.isoWithOffset}** (${announcementConfig.timezone}).`,
      ephemeral: true,
    });
    return;
  }

  if (subcommand === 'cancelar') {
    if (record.status !== 'scheduled') {
      await interaction.reply({ content: `Solo puedes cancelar anuncios **scheduled**; este está **${record.status}**.`, ephemeral: true });
      return;
    }
    await updateState(announcementId, { status: 'cancelled', late: false, nextAttemptAt: null });
    await logAction({ announcementId, action: 'cancel', userId: interaction.user.id });
    await interaction.reply({ content: `✅ Se canceló **${announcementId}**. El anuncio no se enviará.`, ephemeral: true });
  }
}

async function handleConfirmation(interaction) {
  const isConfirm = interaction.customId.startsWith('announcement-confirm:');
  const confirmationId = interaction.customId.slice(interaction.customId.indexOf(':') + 1);
  const [requestId, ...announcementIdParts] = confirmationId.split(':');
  const announcementId = announcementIdParts.join(':');
  const pending = pendingConfirmations.get(confirmationId);
  pendingConfirmations.delete(confirmationId);
  if (!pending || pending.expiresAt < Date.now()) {
    await interaction.reply({ content: 'Esta confirmación venció. Ejecuta /anuncio publicar para generar una nueva.', ephemeral: true });
    return;
  }
  if (pending.userId !== interaction.user.id || pending.guildId !== interaction.guildId) {
    await interaction.reply({ content: 'Solo quien inició la publicación puede confirmarla.', ephemeral: true });
    return;
  }
  const announcement = announcementById.get(announcementId);
  if (!announcement || !interaction.guild || interaction.guildId !== process.env.DISCORD_GUILD_ID || !isAuthorized(interaction)) {
    await interaction.reply({ content: 'No se pudo autorizar esta publicación.', ephemeral: true });
    return;
  }
  if (!isConfirm) {
    await logAction({ announcementId, action: 'cancel', userId: interaction.user.id });
    await interaction.update({ content: 'Cancelado. No se publicó ningún mensaje.', components: [] });
    return;
  }
  await interaction.update({ content: 'Publicando…', components: [] });
  try {
    const result = await sendAnnouncement(interaction.client, interaction.guild, announcement, {
      userId: interaction.user.id,
      targetChannelName: pending.targetChannelName,
    });
    const warnings = result.warnings.length ? `\n\n⚠️ ${result.warnings.join('\n⚠️ ')}` : '';
    await interaction.editReply({
      content: `✅ **${announcement.id}** se publicó en <#${result.channel.id}>.\nMensaje: ${result.messageId ? `https://discord.com/channels/${interaction.guildId}/${result.threadId ?? result.channel.id}/${result.messageId}` : 'publicado'}${warnings}`.slice(0, 1900),
      components: [],
    });
  } catch (error) {
    await logAction({ announcementId, action: 'error', userId: interaction.user.id, error: error.message });
    await interaction.editReply({ content: `No se publicó **${announcementId}**: ${error.message}`.slice(0, 1900), components: [] });
  }
}

export async function handleAnnouncementInteraction(interaction) {
  if (interaction.isButton() && (interaction.customId.startsWith('announcement-confirm:') || interaction.customId.startsWith('announcement-cancel:'))) {
    await handleConfirmation(interaction);
    return true;
  }
  if (interaction.isAutocomplete() && interaction.commandName === 'anuncio') {
    const focusedOption = interaction.options.getFocused(true);
    if (focusedOption.name === 'id') {
      const focused = normalize(focusedOption.value);
      const choices = announcementConfig.announcements
        .filter((announcement) => normalize(announcement.id).includes(focused) || normalize(announcement.title).includes(focused))
        .slice(0, 25)
        .map((announcement) => ({ name: `${announcement.id} · ${announcement.title}`.slice(0, 100), value: announcement.id }));
      await interaction.respond(choices);
    } else if (focusedOption.name === 'canal') {
      const focused = normalize(focusedOption.value);
      const selectedId = interaction.options.getString('id');
      const announcement = selectedId ? announcementById.get(selectedId) : null;
      const definitions = channelDefinitions().filter((definition) => {
        if (!announcement) return ['text', 'forum'].includes(definition.type);
        return announcement.mode === 'forum-post'
          ? definition.type === 'forum'
          : ['text', 'forum'].includes(definition.type) && definition.type === 'text';
      });
      const seen = new Set();
      const choices = definitions.flatMap((definition) => {
        const channel = interaction.guild?.channels.cache.find((candidate) =>
          [definition.name, ...(definition.aliases ?? [])].some((name) => normalize(name) === normalize(candidate.name)),
        );
        if (!channel || seen.has(definition.name)) return [];
        seen.add(definition.name);
        const searchText = normalize(`${definition.name} ${channel.name} ${(definition.aliases ?? []).join(' ')}`);
        if (focused && !searchText.includes(focused)) return [];
        return [{ name: `#${channel.name} (${channel.type === ChannelType.GuildForum ? 'foro' : 'texto'})`.slice(0, 100), value: definition.name }];
      }).slice(0, 25);
      await interaction.respond(choices);
    } else {
      await interaction.respond([]);
    }
    return true;
  }
  if (interaction.isChatInputCommand() && interaction.commandName === 'anuncio') {
    try {
      await handleCommand(interaction);
    } catch (error) {
      await logAction({ announcementId: '*', action: 'error', userId: interaction.user.id, error: error.message }).catch(() => {});
      const response = { content: `Falló /anuncio: ${error.message}`.slice(0, 1900), ephemeral: true };
      if (interaction.replied || interaction.deferred) {
        await interaction.followUp(response).catch(() => {});
      } else {
        await interaction.reply(response).catch(() => {});
      }
    }
    return true;
  }
  return false;
}

async function handleScheduledItem(client, guild, announcement, record, now) {
  const scheduledAt = Date.parse(record.publishAt);
  if (!Number.isFinite(scheduledAt)) {
    await updateState(announcement.id, { status: 'missed', lastError: 'publishAt inválido' });
    await logAction({ announcementId: announcement.id, action: 'error', error: 'publishAt inválido en state.' });
    await notifyOwner(client, guild, `⚠️ El anuncio programado **${announcement.id}** tiene una fecha inválida; no se envió.`);
    return;
  }
  if (scheduledAt > now) return;
  if (record.nextAttemptAt && Date.parse(record.nextAttemptAt) > now) return;
  const lateBy = now - scheduledAt;
  const grace = Number(announcementConfig.catchUpGraceMinutes ?? 60) * 60_000;
  if (lateBy > grace) {
    await updateState(announcement.id, { status: 'missed', late: false, missedAt: new Date(now).toISOString() });
    await logAction({ announcementId: announcement.id, action: 'missed', channelId: record.channelId ?? null, late: false });
    await notifyOwner(client, guild, `⏰ El anuncio **${announcement.id}** venció fuera de la ventana de ${announcementConfig.catchUpGraceMinutes} min y quedó **missed**. No se publicó; revísalo y vuelve a programarlo si corresponde.`);
    return;
  }
  try {
    await sendAnnouncement(client, guild, announcement, { late: lateBy > 0 });
  } catch (error) {
    const retryAt = new Date(now + 5 * 60_000).toISOString();
    await updateState(announcement.id, { lastError: error.message, nextAttemptAt: retryAt });
    await logAction({ announcementId: announcement.id, action: 'error', channelId: record.channelId ?? null, error: error.message });
    await notifyOwner(client, guild, `⚠️ No pude publicar **${announcement.id}** a la hora programada. Se volverá a intentar a las ${formatOffsetDate(Date.parse(retryAt), announcementConfig.timezone)}.\nMotivo: ${error.message}`);
  }
}

async function schedulerTick(client) {
  await ensureStateLoaded();
  const guild = await client.guilds.fetch(process.env.DISCORD_GUILD_ID);
  const now = Date.now();
  for (const announcement of announcementConfig.announcements) {
    const record = runtimeRecord(announcement);
    if (record.status !== 'scheduled' || record.messageId) continue;
    await handleScheduledItem(client, guild, announcement, record, now);
  }
}

export async function startAnnouncementScheduler(client) {
  if (scheduler) return;
  await ensureStateLoaded();
  schedulerClient = client;
  const safeTick = async () => {
    try {
      await schedulerTick(client);
    } catch (error) {
      console.error('Falló el ciclo del scheduler de anuncios:', error);
    }
  };
  await safeTick();
  scheduler = setInterval(safeTick, Math.max(10, Number(announcementConfig.schedulerIntervalSeconds) || 30) * 1000);
  scheduler.unref?.();
  console.log(`Scheduler de anuncios activo cada ${announcementConfig.schedulerIntervalSeconds}s (${announcementConfig.timezone}).`);
}

export async function stopAnnouncementScheduler() {
  if (scheduler) clearInterval(scheduler);
  scheduler = null;
  await stateWriteQueue.catch(() => {});
  if (schedulerClient) console.log('Scheduler de anuncios detenido.');
  schedulerClient = null;
}
