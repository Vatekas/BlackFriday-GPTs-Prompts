local display = false

-- Function to toggle UI
function SetDisplay(bool, isAdmin)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
        isAdmin = isAdmin or false
    })
end

RegisterNetEvent('vata-report:client:openUI')
AddEventHandler('vata-report:client:openUI', function(isAdmin)
    SetDisplay(true, isAdmin)
end)

RegisterNetEvent('vata-report:client:clearChat')
AddEventHandler('vata-report:client:clearChat', function()
    SendNUIMessage({
        type = "clearChat"
    })
end)

-- NUI Callback to close UI
RegisterNUICallback("closeUI", function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

-- NUI Callback to send a message
RegisterNUICallback("sendMessage", function(data, cb)
    local msg = data.message
    if msg and msg ~= "" then
        TriggerServerEvent('vata-report:server:sendMessage', { message = msg })
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

RegisterNetEvent('vata-report:client:receiveSystemMessage')
AddEventHandler('vata-report:client:receiveSystemMessage', function(message)
    SendNUIMessage({
        type = "systemMessage",
        message = message
    })
end)
