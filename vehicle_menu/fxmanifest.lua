fx_version 'cerulean'
game 'gta5'

author 'Jules'
description 'Vehicle Control Menu'
version '1.0.1'

ui_page 'html/index.html'

shared_script '@ox_lib/init.lua'

shared_scripts {
    'config.lua',
    'locales/en.lua',
    'locales/lt.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    'client/main.lua'
}