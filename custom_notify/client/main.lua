local ESX = exports['es_extended']:getSharedObject()

-- Išorinis eventas, leidžiantis kitiems skriptams kviesti pranešimą
RegisterNetEvent('custom_notify:showNotify')
AddEventHandler('custom_notify:showNotify', function(message, type, title, duration)
    SendNUIMessage({
        action = 'showNotification',
        message = message,
        type = type or 'success',
        title = title,
        duration = duration or 3500
    })
end)

-- Komanda testavimui (/testnotify)
RegisterCommand('testnotify', function(source, args, rawCommand)
    -- Wrap in a thread to allow Citizen.Wait
    Citizen.CreateThread(function()
        TriggerEvent('custom_notify:showNotify', 'Sėkmingai atrakintos durys', 'success', nil, 4000)

        Citizen.Wait(500)
        TriggerEvent('custom_notify:showNotify', 'Naujas pagalbos bilietas: durys', 'report', 'Pagalba', 6000)

        Citizen.Wait(500)
        TriggerEvent('custom_notify:showNotify', 'Naudojama Bintas', 'progress', nil, 5000)

        Citizen.Wait(500)
        TriggerEvent('custom_notify:showNotify', 'Jūs gavote atlyginimą: $10', 'info', nil, 4000)
    end)
end, false)
