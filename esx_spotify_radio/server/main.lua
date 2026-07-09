ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('esx_spotify_radio:getSavedSongs', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb({}) return end

    MySQL.query('SELECT * FROM spotify_saved_songs WHERE identifier = ?', {xPlayer.identifier}, function(result)
        if result then
            cb(result)
        else
            cb({})
        end
    end)
end)

RegisterNetEvent('esx_spotify_radio:server:saveSong')
AddEventHandler('esx_spotify_radio:server:saveSong', function(url, title, thumbnail)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    MySQL.insert('INSERT INTO spotify_saved_songs (identifier, youtube_url, title, thumbnail) VALUES (?, ?, ?, ?)', {
        xPlayer.identifier,
        url,
        title,
        thumbnail
    }, function(id)
        TriggerClientEvent('esx:showNotification', source, 'Song saved to your playlist!')
    end)
end)

-- Helper function to verify if player is in the vehicle
local function isPlayerInVehicle(playerId, netId)
    local ped = GetPlayerPed(playerId)
    local veh = GetVehiclePedIsIn(ped, false)
    if veh and veh ~= 0 then
        return NetworkGetNetworkIdFromEntity(veh) == netId
    end
    return false
end

RegisterNetEvent('esx_spotify_radio:server:playSong')
AddEventHandler('esx_spotify_radio:server:playSong', function(netId, url)
    local source = source
    if not isPlayerInVehicle(source, netId) then return end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        local soundId = "spotify_car_" .. netId
        exports.xsound:PlayUrlPos(soundId, url, Config.MaxVolume, GetEntityCoords(entity), false)
        exports.xsound:Distance(soundId, Config.Distance)
        exports.xsound:Attach(soundId, netId)
    end
end)

RegisterNetEvent('esx_spotify_radio:server:pauseSong')
AddEventHandler('esx_spotify_radio:server:pauseSong', function(netId)
    local source = source
    if not isPlayerInVehicle(source, netId) then return end

    local soundId = "spotify_car_" .. netId
    exports.xsound:Pause(soundId)
end)

RegisterNetEvent('esx_spotify_radio:server:resumeSong')
AddEventHandler('esx_spotify_radio:server:resumeSong', function(netId)
    local source = source
    if not isPlayerInVehicle(source, netId) then return end

    local soundId = "spotify_car_" .. netId
    exports.xsound:Resume(soundId)
end)

RegisterNetEvent('esx_spotify_radio:server:stopSong')
AddEventHandler('esx_spotify_radio:server:stopSong', function(netId)
    local source = source
    if not isPlayerInVehicle(source, netId) then return end

    local soundId = "spotify_car_" .. netId
    exports.xsound:Destroy(soundId)
end)

RegisterNetEvent('esx_spotify_radio:server:setVolume')
AddEventHandler('esx_spotify_radio:server:setVolume', function(netId, volume)
    local source = source
    if not isPlayerInVehicle(source, netId) then return end

    local soundId = "spotify_car_" .. netId
    local vol = tonumber(volume)
    if vol and vol >= 0.0 and vol <= 1.0 then
        exports.xsound:setVolume(soundId, vol)
    end
end)
