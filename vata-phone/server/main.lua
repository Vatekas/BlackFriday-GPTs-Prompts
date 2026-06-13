local ESX = exports["es_extended"]:getSharedObject()

-- Table to store active calls
local activeCalls = {}
local inCallState = {}

RegisterNetEvent('vata-phone:server:completeSetup')
AddEventHandler('vata-phone:server:completeSetup', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        -- Generate a random phone number (simple mock logic for now)
        local phoneNumber = string.format("%03d-%04d", math.random(100, 999), math.random(1000, 9999))

        -- You would typically save this to the database here
        -- MySQL.Async.execute('UPDATE users SET phone_number = @num WHERE identifier = @id', ...)

        -- Send the data back to the client UI
        TriggerClientEvent('vata-phone:client:setupCompleted', src, {
            name = xPlayer.getName(),
            number = phoneNumber
        })
    end
end)

RegisterNetEvent('vata-phone:server:shareNumber')
AddEventHandler('vata-phone:server:shareNumber', function(targetId, myNumber)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer and targetId then
        local myName = xPlayer.getName()
        -- Notify the target player that a number was shared
        TriggerClientEvent('ox_lib:notify', targetId, {
            title = 'Kontaktas gautas',
            description = myName .. ' pasidalino savo numeriu: ' .. tostring(myNumber),
            type = 'success'
        })
    end
end)

-- Call logic
RegisterNetEvent('vata-phone:server:startCall')
AddEventHandler('vata-phone:server:startCall', function(targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer and targetId then
        local myName = xPlayer.getName()

        -- Record state
        activeCalls[src] = targetId
        activeCalls[targetId] = src
        inCallState[src] = false
        inCallState[targetId] = false

        -- Tell target they are receiving a call
        TriggerClientEvent('vata-phone:client:receiveCall', targetId, myName, src)
    end
end)

RegisterNetEvent('vata-phone:server:answerCall')
AddEventHandler('vata-phone:server:answerCall', function()
    local src = source
    local callerId = activeCalls[src]

    if callerId then
        inCallState[src] = true
        inCallState[callerId] = true

        -- Create a unique voice channel based on the lowest ID
        local channelId = math.min(src, callerId) + 1000

        -- Tell both clients to enter the voice channel
        TriggerClientEvent('vata-phone:client:callAnswered', src, channelId)
        TriggerClientEvent('vata-phone:client:callAnswered', callerId, channelId)
    end
end)

RegisterNetEvent('vata-phone:server:endCall')
AddEventHandler('vata-phone:server:endCall', function()
    local src = source
    local otherId = activeCalls[src]

    if otherId then
        -- Tell both clients the call ended
        TriggerClientEvent('vata-phone:client:callEnded', src)
        TriggerClientEvent('vata-phone:client:callEnded', otherId)

        -- Clean up state
        activeCalls[src] = nil
        activeCalls[otherId] = nil
        inCallState[src] = nil
        inCallState[otherId] = nil
    end
end)
