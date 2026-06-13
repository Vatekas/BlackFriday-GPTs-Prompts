local phoneOpen = false
local myPhoneNumber = nil
local inCall = false
local currentCallChannel = 0

-- Function to toggle the phone UI
local function TogglePhone(state)
    phoneOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = "togglePhone",
        state = state
    })
end

-- Command to open the phone
RegisterCommand('phone', function()
    TogglePhone(not phoneOpen)
end, false)
RegisterKeyMapping('phone', 'Atidaryti Telefoną', 'keyboard', 'M')

-- NUI Callback to close the phone from JS
RegisterNUICallback('closePhone', function(data, cb)
    TogglePhone(false)
    cb('ok')
end)

-- NUI Callback when language is selected
-- NUI Callback when setup is complete
RegisterNUICallback('setupComplete', function(data, cb)
    -- Trigger server to complete setup and get our generated number
    TriggerServerEvent('vata-phone:server:completeSetup', data)
    cb('ok')
end)

RegisterNetEvent('vata-phone:client:setupCompleted')
AddEventHandler('vata-phone:client:setupCompleted', function(info)
    myPhoneNumber = info.number
    SendNUIMessage({
        action = "setupData",
        name = info.name,
        number = info.number
    })
end)

-- Share Number Callback
RegisterNUICallback('shareNumber', function(data, cb)
    -- Use ox_lib to get closest player
    local closestPlayer, closestDistance = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)

    if closestPlayer and closestDistance < 3.0 then
        local targetServerId = GetPlayerServerId(closestPlayer)
        TriggerServerEvent('vata-phone:server:shareNumber', targetServerId, myPhoneNumber)
        lib.notify({
            title = 'Pavyko',
            description = 'Numeris pasidalintas!',
            type = 'success'
        })
    else
        lib.notify({
            title = 'Klaida',
            description = 'Nėra žaidėjų netoliese',
            type = 'error'
        })
    end
    cb('ok')
end)

-- Voice / Call Logic
RegisterNetEvent('vata-phone:client:receiveCall')
AddEventHandler('vata-phone:client:receiveCall', function(callerName, callerSrc)
    SendNUIMessage({
        action = "incomingCall",
        caller = callerName
    })

    -- Play ringtone using xsound
    exports.xsound:PlayUrl("ringtone", "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", 0.5, true)

    -- If phone isn't open, open it
    if not phoneOpen then
        TogglePhone(true)
    end
end)

RegisterNUICallback('answerCall', function(data, cb)
    exports.xsound:Destroy("ringtone")
    TriggerServerEvent('vata-phone:server:answerCall')
    cb('ok')
end)

RegisterNetEvent('vata-phone:client:callAnswered')
AddEventHandler('vata-phone:client:callAnswered', function(channelId)
    inCall = true
    currentCallChannel = channelId

    -- Join pma-voice radio/call channel
    exports['pma-voice']:setCallChannel(channelId)

    SendNUIMessage({
        action = "callAnswered"
    })
end)

RegisterNUICallback('endCall', function(data, cb)
    exports.xsound:Destroy("ringtone")
    TriggerServerEvent('vata-phone:server:endCall')
    cb('ok')
end)

RegisterNetEvent('vata-phone:client:callEnded')
AddEventHandler('vata-phone:client:callEnded', function()
    if inCall then
        exports['pma-voice']:setCallChannel(0)
        inCall = false
        currentCallChannel = 0
    end

    exports.xsound:Destroy("ringtone")

    SendNUIMessage({
        action = "endCall"
    })
end)

-- Command to test calling someone
RegisterCommand('calltest', function(source, args)
    local targetId = tonumber(args[1])
    if targetId then
        TriggerServerEvent('vata-phone:server:startCall', targetId)
    else
        lib.notify({description = "Provide a server ID", type = "error"})
    end
end, false)
