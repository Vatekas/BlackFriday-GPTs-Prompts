fx_version 'cerulean'
game 'gta5'

author 'LunaX'
description 'Vata Notification system for FiveM'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/cl_main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

exports {
    'Notify',
    'SendNotification'
}
