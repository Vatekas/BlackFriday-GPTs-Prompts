-- Client side script for vata-notify

--- Displays a notification on screen
--- @param title string|table Title or options table
--- @param text string|nil Text content
--- @param notifyType string|nil Notification type ('success', 'error', 'warning', 'info')
--- @param duration number|nil Duration in milliseconds
--- @param position string|nil Screen position
function Notify(title, text, notifyType, duration, position)
    local options = {}

    if type(title) == 'table' then
        options = title
    else
        options.title = title
        options.text = text
        options.type = notifyType or 'info'
        options.duration = duration or Config.DefaultDuration
        options.position = position or Config.DefaultPosition
    end

    if not options.type or not Config.Types[options.type] then
        options.type = 'info'
    end

    if not options.title or options.title == '' then
        options.title = Config.Types[options.type].defaultTitle
    end

    if not options.duration then
        options.duration = Config.DefaultDuration
    end

    if not options.position then
        options.position = Config.DefaultPosition
    end

    SendNUIMessage({
        action = 'notify',
        data = {
            title = options.title,
            text = options.text or '',
            type = options.type,
            duration = options.duration,
            position = options.position
        }
    })
end

-- Exports
exports('Notify', Notify)
exports('SendNotification', Notify)

-- Events
RegisterNetEvent('vata-notify:client:SendNotification', function(title, text, notifyType, duration, position)
    Notify(title, text, notifyType, duration, position)
end)

-- Register test command
RegisterCommand('testnotify', function(source, args, rawCommand)
    local testType = args[1] or 'success'
    if testType == 'success' then
        Notify('Transportų sistema', 'Jūs gavote transporto raktelius!', 'success', 5000)
    elseif testType == 'error' then
        Notify('Klaida', 'Transporto priemonė užrakinta!', 'error', 5000)
    elseif testType == 'warning' then
        Notify('Įspėjimas', 'Transporto priemonės kuras baigiasi!', 'warning', 5000)
    elseif testType == 'info' then
        Notify('Informacija', 'Naujas pranešimas gautas sistemoje.', 'info', 5000)
    else
        Notify('Transportų sistema', 'Jūs gavote transporto raktelius!', 'success', 5000)
    end
end, false)
