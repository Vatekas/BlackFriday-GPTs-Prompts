local ESX = exports['es_extended']:getSharedObject()

-- Išorinis eventas, leidžiantis kitiems skriptams kviesti pranešimą
RegisterNetEvent('custom_notify:showNotify')
AddEventHandler('custom_notify:showNotify', function(message, type)
    SendNUIMessage({
        action = 'showNotification',
        message = message,
        type = type or 'success' -- Numatytasis tipas yra 'success'
    })
end)

-- Komanda testavimui (/testnotify)
RegisterCommand('testnotify', function(source, args, rawCommand)
    local message = "Atrakintos durys"

    if args[1] then
        message = table.concat(args, " ")
    end

    TriggerEvent('custom_notify:showNotify', message, 'success')
end, false)
