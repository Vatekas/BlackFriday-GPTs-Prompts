fx_version 'cerulean'
game 'gta5'

author 'Jules'
description 'Custom Notification System for ESX'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    'client/main.lua'
}

shared_scripts {
    '@es_extended/imports.lua'
}
