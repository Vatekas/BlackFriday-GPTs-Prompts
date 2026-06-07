local isTvOpen = false
local tvProp = nil
local cam = nil

local tvModels = {
    GetHashKey('prop_tv_flat_01'),
    GetHashKey('prop_tv_flat_02'),
    GetHashKey('prop_trev_tv_01')
}

-- Add ESX support
local ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
end)

-- Command to spawn a TV
RegisterCommand('spawntv', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local forward = GetEntityForwardVector(playerPed)

    local spawnCoords = coords + forward * 2.0

    -- Load model
    local model = GetHashKey('prop_tv_flat_01')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end

    -- Spawn prop
    tvProp = CreateObject(model, spawnCoords.x, spawnCoords.y, spawnCoords.z - 1.0, true, false, false)
    SetEntityHeading(tvProp, heading - 180.0)
    PlaceObjectOnGroundProperly(tvProp)
    SetModelAsNoLongerNeeded(model)

    ESX.ShowNotification("TV Spawned! Use /tv to interact.")
end, false)

-- Command to open the TV
RegisterCommand('tv', function()
    if isTvOpen then
        ToggleTV(false)
        return
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Find nearest TV
    local nearestTv = nil
    local minDistance = 5.0

    for _, model in ipairs(tvModels) do
        local prop = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0, model, false, false, false)
        if prop ~= 0 then
            local dist = #(coords - GetEntityCoords(prop))
            if dist < minDistance then
                minDistance = dist
                nearestTv = prop
            end
        end
    end

    if nearestTv ~= nil then
        FocusOnTv(nearestTv)
        ToggleTV(true)
    else
        ESX.ShowNotification("No TV nearby!")
    end
end, false)

function FocusOnTv(propEntity)
    local tvCoords = GetEntityCoords(propEntity)
    local tvHeading = GetEntityHeading(propEntity)

    -- Calculate camera position (in front of the TV)
    local angle = math.rad(tvHeading)
    local camX = tvCoords.x - math.sin(angle) * 1.5
    local camY = tvCoords.y + math.cos(angle) * 1.5
    local camZ = tvCoords.z + 0.5

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, camX, camY, camZ)
    PointCamAtEntity(cam, propEntity, 0.0, 0.0, 0.0, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, true)
end

function StopFocus()
    if cam ~= nil then
        SetCamActive(cam, false)
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

function ToggleTV(state)
    isTvOpen = state

    if isTvOpen then
        -- Open NUI
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "ui",
            status = true
        })
    else
        -- Close NUI
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "ui",
            status = false
        })
        StopFocus()
    end
end

-- NUI Callback to close the TV
RegisterNUICallback('close', function(data, cb)
    ToggleTV(false)
    if cb then cb('ok') end
end)
