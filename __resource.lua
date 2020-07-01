description 'ESX Rob NPC'

server_scripts {
     'config.lua',
     'server/server.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'client/client.lua'
}

dependencies {
    'es_extended'
}