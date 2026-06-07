fx_version 'cerulean'
game 'gta5'

author 'Jules'
description 'vata-tv - FiveM TV Script'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png',
    'html/img/*.jpg'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
