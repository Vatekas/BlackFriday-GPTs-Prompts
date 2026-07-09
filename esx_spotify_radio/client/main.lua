ESX = exports['es_extended']:getSharedObject()

local isUIOpen = false
local currentCar = nil

RegisterCommand(Config.Command, function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if GetPedInVehicleSeat(vehicle, -1) == playerPed or GetPedInVehicleSeat(vehicle, 0) == playerPed then
            currentCar = vehicle
            OpenSpotifyUI()
        else
            ESX.ShowNotification("You must be the driver or front passenger to use the radio.")
        end
    else
        ESX.ShowNotification("You must be in a vehicle to use the radio.")
    end
end, false)

function OpenSpotifyUI()
    if isUIOpen then return end
    isUIOpen = true
    SetNuiFocus(true, true)

    -- Request saved songs from server
    ESX.TriggerServerCallback('esx_spotify_radio:getSavedSongs', function(songs)
        SendNUIMessage({
            action = "openUI",
            savedSongs = songs
        })
    end)
end

function CloseSpotifyUI()
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeUI"
    })
end

RegisterNUICallback('close', function(data, cb)
    CloseSpotifyUI()
    cb('ok')
end)

RegisterNUICallback('playSong', function(data, cb)
    if not currentCar then return end
    local netId = NetworkGetNetworkIdFromEntity(currentCar)
    TriggerServerEvent('esx_spotify_radio:server:playSong', netId, data.url)
    cb('ok')
end)

RegisterNUICallback('pauseSong', function(data, cb)
    if not currentCar then return end
    local netId = NetworkGetNetworkIdFromEntity(currentCar)
    TriggerServerEvent('esx_spotify_radio:server:pauseSong', netId)
    cb('ok')
end)

RegisterNUICallback('resumeSong', function(data, cb)
    if not currentCar then return end
    local netId = NetworkGetNetworkIdFromEntity(currentCar)
    TriggerServerEvent('esx_spotify_radio:server:resumeSong', netId)
    cb('ok')
end)

RegisterNUICallback('stopSong', function(data, cb)
    if not currentCar then return end
    local netId = NetworkGetNetworkIdFromEntity(currentCar)
    TriggerServerEvent('esx_spotify_radio:server:stopSong', netId)
    cb('ok')
end)

RegisterNUICallback('setVolume', function(data, cb)
    if not currentCar then return end
    local netId = NetworkGetNetworkIdFromEntity(currentCar)
    TriggerServerEvent('esx_spotify_radio:server:setVolume', netId, data.volume)
    cb('ok')
end)

RegisterNUICallback('saveSong', function(data, cb)
    TriggerServerEvent('esx_spotify_radio:server:saveSong', data.url, data.title, data.thumbnail)
    cb('ok')
end)
