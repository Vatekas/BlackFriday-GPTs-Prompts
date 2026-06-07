local TVCoords = vector3(-686.4661, 331.7252, 83.0832)

local currentUrl = nil
local currentVolume = 0.5
local isPlaying = false

RegisterNetEvent('vata-tv:play')
AddEventHandler('vata-tv:play', function(url, volume)
    local src = source
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)

    if #(playerCoords - TVCoords) > 15.0 then
        -- Add a little buffer compared to client check
        return
    end

    -- Check if URL is provided
    if url and url ~= "" then
        currentUrl = url
        currentVolume = volume
        isPlaying = true

        -- Trigger all clients to sync the video via NUI
        TriggerClientEvent('vata-tv:syncClient', -1, currentUrl, currentVolume)

        -- If the server uses xsound for 3D spatial audio
        -- Use standard PLACEHOLDER_EXPORT or user defined export function for xsound
        -- NOTE: Users should map 'PlayUrlPos' or their specific xsound export function here to play the audio from the URL
        if exports.xsound then
            -- Note for user: ensure this export is available or modify according to your specific audio implementation
            pcall(function()
                exports.xsound:PlayUrlPos(-1, "vata-tv-audio", currentUrl, currentVolume, TVCoords, false)
            end)
        else
            print("[vata-tv] xsound was not found or not mapped properly.")
        end
    end
end)

RegisterNetEvent('vata-tv:stop')
AddEventHandler('vata-tv:stop', function()
    local src = source
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)

    if #(playerCoords - TVCoords) > 15.0 then
        return
    end

    currentUrl = nil
    isPlaying = false

    -- Sync stop to all clients
    TriggerClientEvent('vata-tv:syncClient', -1, nil, 0)

    -- Destroy the xsound audio
    if exports.xsound then
        pcall(function()
            exports.xsound:Destroy(-1, "vata-tv-audio")
        end)
    end
end)

-- Sync late joiners
AddEventHandler('playerJoining', function()
    local src = source
    if isPlaying and currentUrl then
        -- Delay slightly to ensure client is ready
        SetTimeout(5000, function()
            TriggerClientEvent('vata-tv:syncClient', src, currentUrl, currentVolume)
        end)
    end
end)