import { readFile } from 'node:fs/promises';
import {
  ActionRowBuilder,
  ButtonBuilder,
  ButtonStyle,
  ChannelType,
  Client,
  EmbedBuilder,
  Events,
  ForumLayoutType,
  GatewayIntentBits,
  OverwriteType,
  PermissionFlagsBits,
  PermissionsBitField,
  SortOrderType,
} from 'discord.js';

const { DISCORD_TOKEN, DISCORD_GUILD_ID } = process.env;
if (!DISCORD_TOKEN || !DISCORD_GUILD_ID) {
  throw new Error('Configura DISCORD_TOKEN y DISCORD_GUILD_ID en .env antes de iniciar.');
}

const config = JSON.parse(await readFile(new URL('../config/server.json', import.meta.url), 'utf8'));
const memberWelcomeEnabled = process.env.ENABLE_MEMBER_WELCOME?.toLowerCase() === 'true';
const intents = [GatewayIntentBits.Guilds];
if (memberWelcomeEnabled) intents.push(GatewayIntentBits.GuildMembers);

const client = new Client({ intents });
const reason = 'Estructura inicial de DCV Studios solicitada por un administrador';

function normalize(value) {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLocaleLowerCase('es')
    .replace(/[^\p{L}\p{N}]/gu, '');
}

function matchesName(channel, item) {
  const accepted = [item.name, ...(item.aliases ?? [])].map(normalize);
  return accepted.includes(normalize(channel.name));
}

function isExpectedType(channel, definition) {
  if (definition.type === 'voice') return channel.type === ChannelType.GuildVoice;
  if (definition.type === 'forum') return channel.type === ChannelType.GuildForum;
  return channel.type === ChannelType.GuildText || channel.type === ChannelType.GuildAnnouncement;
}

function getForumLayout(definition) {
  return definition.defaultForumLayout === 'gallery' ? ForumLayoutType.GalleryView : ForumLayoutType.ListView;
}

function getForumSortOrder(definition) {
  return definition.defaultSortOrder === 'creation_date' ? SortOrderType.CreationDate : SortOrderType.LatestActivity;
}

function forumNeedsUpdate(channel, definition) {
  const existingTags = new Set((channel.availableTags ?? []).map((tag) => normalize(tag.name)));
  return channel.topic !== (definition.topic ?? null) ||
    channel.defaultForumLayout !== getForumLayout(definition) ||
    channel.defaultSortOrder !== getForumSortOrder(definition) ||
    (definition.tags ?? []).some((tag) => !existingTags.has(normalize(tag)));
}

function mergedForumTags(channel, definition) {
  const tags = (channel.availableTags ?? []).map((tag) => ({
    id: tag.id,
    name: tag.name,
    moderated: tag.moderated,
    ...(tag.emoji ? { emoji: tag.emoji } : {}),
  }));
  const existingTags = new Set(tags.map((tag) => normalize(tag.name)));
  for (const name of definition.tags ?? []) {
    if (!existingTags.has(normalize(name)) && tags.length < 20) {
      tags.push({ name });
      existingTags.add(normalize(name));
    }
  }
  return tags;
}

function uniqueArchiveName(channelName, channels) {
  const used = new Set([...channels.values()].map((channel) => normalize(channel.name)));
  const baseName = `${channelName}-archivo`;
  if (!used.has(normalize(baseName))) return baseName;
  let index = 2;
  while (used.has(normalize(`${channelName}-archivo-${index}`))) index += 1;
  return `${channelName}-archivo-${index}`;
}

function getRolePermissions(definition) {
  return new PermissionsBitField((definition.permissions ?? []).map((name) => PermissionFlagsBits[name]));
}

function roleNeedsUpdate(role, definition) {
  return role.name !== definition.name ||
    role.color !== Number.parseInt(definition.color.slice(1), 16) ||
    role.hoist !== definition.hoist ||
    role.mentionable !== definition.mentionable ||
    role.permissions.bitfield !== getRolePermissions(definition).bitfield;
}

function findConfiguredRole(roles, definition) {
  return roles.find((role) => matchesName(role, definition));
}

function privateTeamOverwrites(guild, roleMap) {
  const allowed = [
    PermissionFlagsBits.ViewChannel,
    PermissionFlagsBits.SendMessages,
    PermissionFlagsBits.ReadMessageHistory,
    PermissionFlagsBits.EmbedLinks,
    PermissionFlagsBits.AttachFiles,
    PermissionFlagsBits.Connect,
    PermissionFlagsBits.Speak,
  ];
  const accessKeys = new Set(
    config.categories.find((category) => category.private)?.accessRoles ?? [],
  );
  const roleOverwrites = [...accessKeys]
    .map((key) => roleMap.get(key))
    .filter(Boolean)
    .map((role) => ({ id: role.id, type: OverwriteType.Role, allow: allowed }));

  return [
    {
      id: guild.roles.everyone.id,
      type: OverwriteType.Role,
      deny: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.Connect],
    },
    ...roleOverwrites,
    {
      id: client.user.id,
      type: OverwriteType.Member,
      allow: allowed,
    },
  ];
}

async function buildPlan(guild) {
  const channels = await guild.channels.fetch();
  const roles = await guild.roles.fetch();
  const forumChannels = config.categories.flatMap((category) => category.channels)
    .filter((channel) => channel.type === 'forum');
  const communityEnabled = guild.features.includes('COMMUNITY');
  const roleChanges = config.roles.map((definition) => {
    const existing = findConfiguredRole(roles, definition) ?? null;
    return {
      definition,
      existing,
      action: !existing ? 'crear' : roleNeedsUpdate(existing, definition) ? 'actualizar' : 'mantener',
    };
  });
  const categories = [];
  const channelChanges = [];
  const conflicts = [];

  for (const categoryDefinition of config.categories) {
    const foundCategory = channels.find(
      (channel) => channel?.type === ChannelType.GuildCategory && matchesName(channel, categoryDefinition),
    );
    categories.push({ definition: categoryDefinition, existing: foundCategory ?? null });

    for (const channelDefinition of categoryDefinition.channels) {
      const matchingChannels = [...channels.values()].filter(
        (channel) => channel && channel.type !== ChannelType.GuildCategory && matchesName(channel, channelDefinition),
      );
      const foundChannel = matchingChannels.find((channel) => isExpectedType(channel, channelDefinition)) ?? null;
      const legacyTextChannel = !foundChannel && channelDefinition.type === 'forum'
        ? matchingChannels.find((channel) => channel.type === ChannelType.GuildText) ?? null
        : null;
      if (!foundChannel && !legacyTextChannel && matchingChannels.length) {
        conflicts.push(`⚠️ **#${channelDefinition.name}**: existe con un tipo de canal distinto; no se tocará.`);
        continue;
      }

      const categoryId = foundCategory?.id ?? null;
      let action = 'mantener';
      if (legacyTextChannel) {
        action = 'migrar-foro';
      } else if (!foundChannel) {
        action = 'crear';
      } else if (!foundCategory || foundChannel.name !== channelDefinition.name || foundChannel.parentId !== categoryId) {
        action = 'ordenar';
      } else if (channelDefinition.type === 'forum' && forumNeedsUpdate(foundChannel, channelDefinition)) {
        action = 'configurar-foro';
      }
      const archiveName = legacyTextChannel ? uniqueArchiveName(channelDefinition.name, channels) : null;
      channelChanges.push({
        definition: channelDefinition,
        category: categoryDefinition,
        existing: foundChannel ?? null,
        legacyTextChannel,
        archiveName,
        action,
      });
    }
  }

  return {
    roles: roleChanges,
    categories,
    channelChanges,
    conflicts,
    communityEnabled,
    requiresCommunity: forumChannels.length > 0 && !communityEnabled,
  };
}

function renderPlan(plan) {
  const lines = ['**Vista previa profesional de DCV Studios**', '', '**Roles**'];
  for (const item of plan.roles) {
    const symbol = item.action === 'crear' ? '➕' : item.action === 'actualizar' ? '🛠️' : '✅';
    lines.push(`${symbol} ${item.definition.name}${item.definition.key === 'admin' ? ' · canales, mensajes y timeout' : ''}${item.definition.key === 'moderator' ? ' · mensajes y timeout' : ''}`);
  }
  lines.push('👑 El dueño del servidor recibirá **Fundador**. Los demás roles quedan creados para que tú los asignes.');
  lines.push('🛡️ Administración no tendrá `Administrator`, expulsión ni baneo; los roles usan permisos concretos.');
  lines.push('', '**Categorías y canales**');
  for (const { definition, existing } of plan.categories) {
    lines.push(existing
      ? `📁 ${existing.name === definition.name ? 'Se conserva' : `Se renombra a`} **${definition.name}**`
      : `➕ Se creará la categoría **${definition.name}**`);
    if (definition.private) lines.push('  🔒 Solo roles de equipo y moderación podrán ver esta categoría.');
    const items = plan.channelChanges.filter((change) => change.category === definition);
    const channelSummary = items.map((item) => {
      const symbol = item.action === 'crear' || item.action === 'migrar-foro'
        ? '➕'
        : ['ordenar', 'configurar-foro'].includes(item.action) ? '↪️' : '';
      const label = item.definition.type === 'voice' ? item.definition.name : `#${item.definition.name}`;
      const forumNote = item.definition.type === 'forum'
        ? ` 🗂️ [${(item.definition.tags ?? []).join(', ')}]`
        : '';
      const archiveNote = item.action === 'migrar-foro' ? ` (texto previo → #${item.archiveName})` : '';
      return `${symbol ? `${symbol} ` : ''}${label}${forumNote}${archiveNote}`;
    });
    if (channelSummary.length) lines.push(`  ${channelSummary.join(' · ')}`);
  }
  if (plan.requiresCommunity) {
    lines.push('', '⚠️ Para crear foros primero debes activar **Comunidad** en este servidor. El comando aplicar no hará cambios hasta que esté activada.');
  }
  if (plan.conflicts.length) lines.push('', ...plan.conflicts);
  lines.push('', 'No se borran canales ni mensajes. Se conserva el historial; los canales públicos conservan sus permisos. Los canales de EQUIPO quedarán privados.');
  let preview = lines.join('\n');
  if (preview.length > 1900) {
    // Leave the important warnings and safety note visible if a customized
    // server has many channels or unusually long forum tag names.
    const safetyNotes = lines.slice(-1);
    const warnings = plan.requiresCommunity ? lines.filter((line) => line.includes('⚠️ Para crear foros')) : [];
    const conflicts = plan.conflicts;
    const tail = [...warnings, ...conflicts, ...safetyNotes].filter(Boolean).join('\n');
    const tailLines = new Set([...warnings, ...conflicts, ...safetyNotes]);
    const body = lines.filter((line) => !tailLines.has(line));
    const available = Math.max(0, 1850 - tail.length);
    preview = `${body.join('\n').slice(0, available)}\n${tail}`;
  }
  return preview;
}

async function applyPlan(guild) {
  if (config.categories.flatMap((category) => category.channels).some((channel) => channel.type === 'forum') &&
      !guild.features.includes('COMMUNITY')) {
    throw new Error('Discord requiere activar Comunidad antes de crear canales de foro.');
  }

  const outcome = {
    createdRoles: 0,
    updatedRoles: 0,
    createdCategories: 0,
    renamedCategories: 0,
    createdChannels: 0,
    updatedChannels: 0,
    archivedTextChannels: 0,
    securedChannels: 0,
    founderStatus: 'missing',
    welcomePublished: false,
    welcomeSkipped: false,
  };
  const roleMap = new Map();

  for (const definition of config.roles) {
    const roles = await guild.roles.fetch();
    let role = findConfiguredRole(roles, definition);
    const properties = {
      name: definition.name,
      color: definition.color,
      hoist: definition.hoist,
      mentionable: definition.mentionable,
      permissions: getRolePermissions(definition),
      reason,
    };
    if (!role) {
      role = await guild.roles.create(properties);
      outcome.createdRoles += 1;
    } else if (roleNeedsUpdate(role, definition)) {
      await role.edit(properties);
      outcome.updatedRoles += 1;
    }
    roleMap.set(definition.key, role);
  }

  const founderRole = roleMap.get('founder');
  const owner = await guild.members.fetch(guild.ownerId);
  if (founderRole) {
    if (owner.roles.cache.has(founderRole.id)) {
      outcome.founderStatus = 'already';
    } else {
      try {
        await owner.roles.add(founderRole, reason);
        outcome.founderStatus = 'assigned';
      } catch (error) {
        outcome.founderStatus = 'manual';
        console.error('No pude asignar Fundador al propietario; se podrá asignar manualmente:', error);
      }
    }
  }

  for (const categoryDefinition of config.categories) {
    const categoryOptions = categoryDefinition.private
      ? { permissionOverwrites: privateTeamOverwrites(guild, roleMap) }
      : {};
    let category = (await guild.channels.fetch()).find(
      (channel) => channel?.type === ChannelType.GuildCategory && matchesName(channel, categoryDefinition),
    );
    if (!category) {
      category = await guild.channels.create({
        name: categoryDefinition.name,
        type: ChannelType.GuildCategory,
        ...categoryOptions,
        reason,
      });
      outcome.createdCategories += 1;
    } else {
      const editOptions = { ...categoryOptions, reason };
      if (category.name !== categoryDefinition.name) {
        editOptions.name = categoryDefinition.name;
        outcome.renamedCategories += 1;
      }
      if (categoryDefinition.private || category.name !== categoryDefinition.name) {
        await category.edit(editOptions);
      }
    }

    for (const definition of categoryDefinition.channels) {
      const allChannels = await guild.channels.fetch();
      const matchingChannels = [...allChannels.values()].filter(
        (candidate) => candidate && candidate.type !== ChannelType.GuildCategory && matchesName(candidate, definition),
      );
      let channel = matchingChannels.find((candidate) => isExpectedType(candidate, definition)) ?? null;

      if (!channel && definition.type === 'forum') {
        const legacyTextChannel = matchingChannels.find((candidate) => candidate.type === ChannelType.GuildText);
        if (legacyTextChannel) {
          const archiveName = uniqueArchiveName(definition.name, allChannels);
          await legacyTextChannel.edit({ name: archiveName, reason });
          outcome.archivedTextChannels += 1;
        }
      }

      if (!channel) {
        const options = {
          name: definition.name,
          type: definition.type === 'voice'
            ? ChannelType.GuildVoice
            : definition.type === 'forum'
              ? ChannelType.GuildForum
              : ChannelType.GuildText,
          parent: category.id,
          reason,
        };
        if (definition.type === 'text' && definition.topic) options.topic = definition.topic;
        if (definition.type === 'forum') {
          options.topic = definition.topic;
          options.availableTags = (definition.tags ?? []).map((name) => ({ name }));
          options.defaultForumLayout = getForumLayout(definition);
          options.defaultSortOrder = getForumSortOrder(definition);
        }
        if (categoryDefinition.private) {
          options.permissionOverwrites = privateTeamOverwrites(guild, roleMap);
          outcome.securedChannels += 1;
        }
        channel = await guild.channels.create(options);
        outcome.createdChannels += 1;
      } else {
        const needsMoveOrRename = channel.name !== definition.name || channel.parentId !== category.id;
        const needsForumUpdate = definition.type === 'forum' && forumNeedsUpdate(channel, definition);
        if (needsMoveOrRename || categoryDefinition.private || needsForumUpdate) {
          const editOptions = { name: definition.name, parent: category.id, reason };
          if (categoryDefinition.private) editOptions.lockPermissions = true;
          if (definition.type === 'forum') {
            editOptions.topic = definition.topic;
            editOptions.availableTags = mergedForumTags(channel, definition);
            editOptions.defaultForumLayout = getForumLayout(definition);
            editOptions.defaultSortOrder = getForumSortOrder(definition);
          }
          await channel.edit(editOptions);
          if (needsMoveOrRename) outcome.updatedChannels += 1;
          if (needsForumUpdate) outcome.updatedChannels += 1;
          if (categoryDefinition.private) outcome.securedChannels += 1;
        }
      }
    }
  }

  const channels = await guild.channels.fetch();
  const welcomeDefinition = config.categories
    .flatMap((category) => category.channels)
    .find((channel) => channel.name === 'bienvenida-y-normas');
  const welcomeChannel = channels.find(
    (channel) => channel && isExpectedType(channel, welcomeDefinition) && matchesName(channel, welcomeDefinition),
  );

  if (welcomeChannel?.isTextBased()) {
    const latest = await welcomeChannel.messages.fetch({ limit: 1 });
    if (latest.size === 0) {
      const welcome = config.welcome;
      const rules = welcome.rules.map((rule, index) => `**${index + 1}.** ${rule}`).join('\n\n');
      const embed = new EmbedBuilder()
        .setColor(0x5865f2)
        .setTitle(welcome.title)
        .setDescription(welcome.description)
        .addFields({ name: 'Normas de la comunidad', value: rules })
        .setFooter({ text: welcome.footer });
      await welcomeChannel.send({ embeds: [embed] });
      outcome.welcomePublished = true;
    } else {
      outcome.welcomeSkipped = true;
    }
  }

  return outcome;
}

function isAuthorized(interaction) {
  return interaction.guild && (
    interaction.user.id === interaction.guild.ownerId ||
    interaction.memberPermissions?.has(PermissionFlagsBits.ManageChannels)
  );
}

client.once(Events.ClientReady, (readyClient) => {
  console.log(`Conectado como ${readyClient.user.tag}.`);
  console.log(`Bienvenida automática al entrar: ${memberWelcomeEnabled ? 'activada' : 'desactivada'}.`);
});

client.on(Events.InteractionCreate, async (interaction) => {
  if (!interaction.isChatInputCommand() || interaction.commandName !== 'dcv-setup') return;

  if (!interaction.inGuild() || interaction.guildId !== DISCORD_GUILD_ID) {
    await interaction.reply({ content: 'Este comando solo está configurado para el servidor de DCV Studios.', ephemeral: true });
    return;
  }
  if (!isAuthorized(interaction)) {
    await interaction.reply({ content: 'Solo la persona propietaria o alguien con Administrar canales puede usar este comando.', ephemeral: true });
    return;
  }
  const requiredBotPermissions = [
    ['ManageChannels', 'Administrar canales'],
    ['ManageRoles', 'Administrar roles'],
    ['ManageMessages', 'Administrar mensajes'],
    ['ModerateMembers', 'Moderar miembros'],
    ['ViewChannel', 'Ver canales'],
    ['SendMessages', 'Enviar mensajes'],
    ['ReadMessageHistory', 'Leer historial'],
    ['EmbedLinks', 'Insertar enlaces'],
    ['AttachFiles', 'Adjuntar archivos'],
    ['Connect', 'Conectar a voz'],
    ['Speak', 'Hablar en voz'],
  ];
  const missingBotPermissions = requiredBotPermissions
    .filter(([permission]) => !interaction.appPermissions?.has(PermissionFlagsBits[permission]))
    .map(([, label]) => label);
  if (missingBotPermissions.length) {
    await interaction.reply({
      content: `Al bot le faltan permisos: **${missingBotPermissions.join(', ')}**. Actívalos en Ajustes del servidor → Roles, en el rol del bot. No necesita Administrador.`,
      ephemeral: true,
    });
    return;
  }

  try {
    const plan = await buildPlan(interaction.guild);
    if (interaction.options.getSubcommand() === 'previsualizar') {
      await interaction.reply({ content: renderPlan(plan), ephemeral: true });
      return;
    }
    if (plan.requiresCommunity) {
      await interaction.reply({
        content: `${renderPlan(plan)}\n\nNo apliqué cambios. Activa Comunidad en los ajustes del servidor y luego vuelve a previsualizar.`,
        ephemeral: true,
      });
      return;
    }

    const confirmButton = new ButtonBuilder()
      .setCustomId(`dcv-setup-confirm:${interaction.id}`)
      .setLabel('Confirmar cambios')
      .setStyle(ButtonStyle.Primary);
    const cancelButton = new ButtonBuilder()
      .setCustomId(`dcv-setup-cancel:${interaction.id}`)
      .setLabel('Cancelar')
      .setStyle(ButtonStyle.Secondary);
    const row = new ActionRowBuilder().addComponents(confirmButton, cancelButton);
    await interaction.reply({
      content: `${renderPlan(plan)}\n\n¿Aplicamos estos cambios?`,
      components: [row],
      ephemeral: true,
    });

    const reply = await interaction.fetchReply();
    const confirmation = await reply.awaitMessageComponent({
      filter: (buttonInteraction) =>
        buttonInteraction.user.id === interaction.user.id &&
        buttonInteraction.customId.endsWith(interaction.id),
      time: 60_000,
    }).catch(() => null);

    if (!confirmation) return;
    if (confirmation.customId.startsWith('dcv-setup-cancel:')) {
      await confirmation.update({ content: 'Cancelado. No se modificó el servidor.', components: [] });
      return;
    }

    await confirmation.update({ content: 'Aplicando cambios…', components: [] });
    const result = await applyPlan(interaction.guild);
    const summary = [
      '✅ Estructura aplicada.',
      `Roles nuevos: **${result.createdRoles}** · roles actualizados: **${result.updatedRoles}**.`,
      result.founderStatus === 'assigned' ? 'Asigné 👑 Fundador a la persona propietaria del servidor.' : '',
      result.founderStatus === 'already' ? 'La persona propietaria ya tiene 👑 Fundador.' : '',
      result.founderStatus === 'manual' ? 'Asigna 👑 Fundador manualmente a la persona propietaria desde Ajustes del servidor → Roles.' : '',
      `Categorías nuevas: **${result.createdCategories}** · categorías renombradas: **${result.renamedCategories}**.`,
      `Canales nuevos: **${result.createdChannels}** · canales reordenados/renombrados: **${result.updatedChannels}**.`,
      `Canales de equipo con acceso privado sincronizado: **${result.securedChannels}**.`,
      result.welcomePublished ? 'Publiqué la bienvenida y las normas en #bienvenida-y-normas.' : '',
      result.welcomeSkipped ? 'No publiqué el mensaje inicial porque #bienvenida-y-normas ya tiene mensajes.' : '',
      result.archivedTextChannels ? `Conservé **${result.archivedTextChannels}** canal(es) de texto anterior(es) con sufijo -archivo y creé los foros nuevos.` : '',
      'No se borró ningún canal ni mensaje. Los roles de trabajo restantes no se asignaron a miembros; revisa su posición para la moderación.',
    ].filter(Boolean).join('\n');
    await confirmation.editReply({ content: summary, components: [] });
  } catch (error) {
    console.error('Falló /dcv-setup:', error);
    const message = 'No pude completar la operación. Revisa los permisos del bot y la consola para ver el detalle.';
    if (interaction.replied || interaction.deferred) {
      await interaction.followUp({ content: message, ephemeral: true }).catch(() => {});
    } else {
      await interaction.reply({ content: message, ephemeral: true }).catch(() => {});
    }
  }
});

if (memberWelcomeEnabled) {
  client.on(Events.GuildMemberAdd, async (member) => {
    if (member.guild.id !== DISCORD_GUILD_ID) return;
    const welcomeDefinition = config.categories.flatMap((category) => category.channels)
      .find((channel) => channel.name === 'bienvenida-y-normas');
    const channel = member.guild.channels.cache.find(
      (candidate) => candidate && isExpectedType(candidate, welcomeDefinition) && matchesName(candidate, welcomeDefinition),
    );
    if (!channel?.isTextBased()) return;
    const arrival = config.welcome.arrival.replace('{user}', `<@${member.id}>`);
    await channel.send({ content: arrival }).catch((error) => console.error('No pude enviar bienvenida:', error));
  });
}

client.login(DISCORD_TOKEN);
