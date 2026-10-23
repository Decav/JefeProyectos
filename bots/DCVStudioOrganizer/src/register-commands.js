import { REST, Routes, SlashCommandBuilder, PermissionFlagsBits } from 'discord.js';

const { DISCORD_TOKEN, DISCORD_CLIENT_ID, DISCORD_GUILD_ID } = process.env;

for (const [name, value] of Object.entries({ DISCORD_TOKEN, DISCORD_CLIENT_ID, DISCORD_GUILD_ID })) {
  if (!value || value.startsWith('PEGA_AQUI') || value.startsWith('ID_')) {
    throw new Error(`Falta configurar ${name} en el archivo .env.`);
  }
}

const command = new SlashCommandBuilder()
  .setName('dcv-setup')
  .setDescription('Previsualiza o aplica la estructura oficial de DCV Studios.')
  .setDefaultMemberPermissions(PermissionFlagsBits.ManageChannels)
  .addSubcommand((subcommand) =>
    subcommand
      .setName('previsualizar')
      .setDescription('Muestra qué cambios haría el bot, sin modificar el servidor.'),
  )
  .addSubcommand((subcommand) =>
    subcommand
      .setName('aplicar')
      .setDescription('Pide confirmación antes de ordenar canales y publicar la bienvenida.'),
  );

const rest = new REST({ version: '10' }).setToken(DISCORD_TOKEN);
await rest.put(Routes.applicationGuildCommands(DISCORD_CLIENT_ID, DISCORD_GUILD_ID), {
  body: [command.toJSON()],
});

console.log('Comando /dcv-setup registrado en el servidor configurado.');
