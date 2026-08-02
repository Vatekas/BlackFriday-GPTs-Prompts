local display = false

-- Register command to open UI
RegisterCommand('report', function()
    SetDisplay(not display)
end, false)

-- Function to toggle UI
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

-- NUI Callback to close UI
RegisterNUICallback("closeUI", function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

-- NUI Callback to send a message
RegisterNUICallback("sendMessage", function(data, cb)
    local msg = data.message
    if msg and msg ~= "" then
        TriggerServerEvent('vata-report:server:sendMessage', msg)
    end
    cb('ok')
end)

-- NUI Callback to close ticket
RegisterNUICallback("closeTicket", function(data, cb)
    TriggerServerEvent('vata-report:server:closeTicket')
    cb('ok')
end)

-- Event from server to append a new message in UI
RegisterNetEvent('vata-report:client:receiveMessage')
AddEventHandler('vata-report:client:receiveMessage', function(messageData)
    SendNUIMessage({
        type = "newMessage",
        messageData = messageData
    })
end)
