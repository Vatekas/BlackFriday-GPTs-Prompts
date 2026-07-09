fx_version 'cerulean'
game 'gta5'

description 'Spotify Radio for Cars'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/img/*.png',
    'html/img/*.jpg'
}

dependency 'es_extended'
dependency 'xsound'
dependency 'oxmysql'
