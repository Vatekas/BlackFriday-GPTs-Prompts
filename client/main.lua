local QB = nil
local ESX = nil
local playerLoaded = false
local currentData = {
    id = 0,
    cash = 0,
    bank = 0,
    dirty = 0,
    job = Config.JobLabelFallback,
    time = "00:00",
    talking = false,
    voiceRange = 2,
    voiceMax = Config.VoiceLevels
}

-- Detect Framework and Init Safely
CreateThread(function()
    if Config.Framework == 'auto' or Config.Framework == 'qb-core' then
        if GetResourceState('qb-core') == 'started' then
            pcall(function()
                QB = exports['qb-core']:GetCoreObject()
            end)
            if QB then
                Config.Framework = 'qb-core'
            end
        end
    end

    if (Config.Framework == 'auto' or Config.Framework == 'esx') and not QB then
        if GetResourceState('es_extended') == 'started' then
            pcall(function()
                ESX = exports['es_extended']:getSharedObject()
            end)
        end

        if not ESX then
            -- Fallback old ESX import method (with safety timeout)
            local timeout = 0
            while not ESX and timeout < 30 do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Wait(100)
                timeout = timeout + 1
            end
            if ESX then
                Config.Framework = 'esx'
            end
        else
            Config.Framework = 'esx'
        end
    end

    -- Fallback to standalone if none of the above are running
    if Config.Framework == 'auto' or not Config.Framework then
        Config.Framework = 'standalone'
    end

    -- Initial load wait
    Wait(2000)
    InitializeHUD()
end)

function InitializeHUD()
    currentData.id = GetPlayerServerId(PlayerId())
    playerLoaded = true

    -- Load character headshot
    CreateThread(function()
        LoadPlayerHeadshot()
    end)

    -- Force the square radar shape once the player has officially loaded
    SetupSquareRadar()

    -- Trigger initial data fetch from server
    TriggerServerEvent('jg-hud:server:initPlayer')
end

-- Ped Headshot (Profile Picture) Loader
local headshotTxd = nil
local headshotId = nil

function LoadPlayerHeadshot()
    local ped = PlayerPedId()
    local timeout = 0

    -- Wait for player ped to exist and be valid
    while not DoesEntityExist(ped) or GetEntityModel(ped) == 0 do
        Wait(500)
        ped = PlayerPedId()
    end

    if headshotId then
        UnregisterPedheadshot(headshotId)
        headshotId = nil
    end

    headshotId = RegisterPedheadshot(ped)

    while not IsPedheadshotReady(headshotId) or not IsPedheadshotValid(headshotId) do
        Wait(200)
        timeout = timeout + 1
        if timeout > 80 then -- 16 seconds timeout
            break
        end
    end

    if IsPedheadshotReady(headshotId) and IsPedheadshotValid(headshotId) then
        headshotTxd = GetPedheadshotTxdString(headshotId)
        -- Send the texture path via img:// protocol to NUI
        SendNUIMessage({
            action = 'updateHud',
            avatarUrl = 'img://' .. headshotTxd .. '/' .. headshotTxd
        })
    else
        -- Retry after 10 seconds if it failed (e.g. skin not loaded yet)
        SetTimeout(10000, function()
            if playerLoaded then
                LoadPlayerHeadshot()
            end
        end)
    end
end

-- Refresh headshot on player spawn / model change
AddEventHandler('playerSpawned', function()
    Wait(3000)
    if playerLoaded then
        LoadPlayerHeadshot()
    end
end)

RegisterNetEvent('skinchanger:modelLoaded', function()
    Wait(3000)
    if playerLoaded then
        LoadPlayerHeadshot()
    end
end)

-- Receive UI updates from Server
RegisterNetEvent('jg-hud:client:updateData', function(data)
    if not playerLoaded then return end

    if data.cash ~= nil then currentData.cash = data.cash end
    if data.bank ~= nil then currentData.bank = data.bank end
    if data.dirty ~= nil then currentData.dirty = data.dirty end

    if data.job ~= nil then
        if data.job == "" or not data.job then
            currentData.job = Config.JobLabelFallback
        else
            currentData.job = data.job
        end
    end

    UpdateHUDUI()
end)

-- Main NUI Updater
function UpdateHUDUI()
    SendNUIMessage({
        action = 'updateHud',
        id = currentData.id,
        cash = currentData.cash,
        bank = currentData.bank,
        dirty = currentData.dirty,
        job = currentData.job,
        time = currentData.time,
        talking = currentData.talking,
        voiceRange = currentData.voiceRange,
        voiceMax = currentData.voiceMax,
        voiceColor = Config.VoiceColors[currentData.voiceRange] or '#ffffff',
        hideDirty = Config.HideDirtyMoneyIfZero
    })
end

-- Loop for Time and general HUD updates (runs less frequently for performance)
CreateThread(function()
    while true do
        if playerLoaded then
            -- Time formatting
            local hours, minutes
            if Config.RealTime then
                -- os.date is sandboxed in FiveM Lua. Use GetLocalTime() instead
                local _, _, _, h, m = GetLocalTime()
                hours = h
                minutes = m
            else
                hours = GetClockHours()
                minutes = GetClockMinutes()
            end

            local formattedTime = ""
            if Config.TimeFormat == 12 then
                local ampm = hours >= 12 and "PM" or "AM"
                local h12 = hours % 12
                if h12 == 0 then h12 = 12 end
                formattedTime = string.format("%02d:%02d %s", h12, minutes, ampm)
            else
                formattedTime = string.format("%02d:%02d", hours, minutes)
            end

            if currentData.time ~= formattedTime then
                currentData.time = formattedTime
                UpdateHUDUI()
            end
        end
        Wait(2000) -- Update time every 2 seconds
    end
end)

-- MULTI-FRAMEWORK VOICE INTEGRATION (PMA-Voice, SaltyChat, TokoVoip, Native)

-- 1. PMA-Voice state bag change listener
AddEventHandler('onClientMapStart', function()
    local playerId = PlayerId()
    local serverId = GetPlayerServerId(playerId)

    AddStateBagChangeHandler('talking', ('player:%s'):format(serverId), function(bagName, key, value, reserved, replicated)
        if playerLoaded then
            local isTalking = value or false
            if currentData.talking ~= isTalking then
                currentData.talking = isTalking
                UpdateHUDUI()
            end
        end
    end)
end)

-- Fallback check for PMA state bags just in case event handler didn't register yet
CreateThread(function()
    while true do
        if playerLoaded then
            local serverId = GetPlayerServerId(PlayerId())
            local pmaTalking = Player(serverId).state.talking
            if pmaTalking ~= nil and currentData.talking ~= pmaTalking then
                currentData.talking = pmaTalking
                UpdateHUDUI()
            end
        end
        Wait(500)
    end
end)

-- 2. SaltyChat event listener
RegisterNetEvent('SaltyChat_TalkStateChanged', function(isTalking)
    if playerLoaded then
        if currentData.talking ~= isTalking then
            currentData.talking = isTalking or false
            UpdateHUDUI()
        end
    end
end)

-- 3. TokoVoip event listener
RegisterNetEvent('TokoVoip:talkStatus', function(isTalking)
    if playerLoaded then
        local talkingState = (isTalking == 1 or isTalking == true)
        if currentData.talking ~= talkingState then
            currentData.talking = talkingState
            UpdateHUDUI()
        end
    end
end)

-- 4. Voice Range and Native voice backup loop
CreateThread(function()
    while true do
        if playerLoaded then
            local voiceRange = 2 -- Default medium range

            -- Check voice range/proximity safely with pcall to prevent crash if exports don't exist
            if GetResourceState('pma-voice') == 'started' then
                local success, level = pcall(function()
                    return exports['pma-voice']:getVoiceLevel()
                end)
                if success and level then
                    voiceRange = level
                else
                    local proximity = MumbleGetTalkerProximity()
                    if proximity <= 3.0 then voiceRange = 1
                    elseif proximity <= 8.0 then voiceRange = 2
                    else voiceRange = 3 end
                end
            elseif GetResourceState('saltychat') == 'started' then
                local success, saltyRange = pcall(function()
                    return exports['saltychat']:GetVoiceRange()
                end)
                if success and saltyRange then
                    if saltyRange <= 3.1 then voiceRange = 1
                    elseif saltyRange <= 8.1 then voiceRange = 2
                    else voiceRange = 3 end
                else
                    voiceRange = 2
                end
            else
                -- Fallback to native mumble range mapping
                local proximity = MumbleGetTalkerProximity()
                if proximity <= 3.0 then voiceRange = 1
                elseif proximity <= 8.0 then voiceRange = 2
                else voiceRange = 3 end
            end

            -- If using standalone/native mumble (no custom voice resources) we check native talking status
            if GetResourceState('pma-voice') ~= 'started' and GetResourceState('saltychat') ~= 'started' then
                local nativeTalking = NetworkIsPlayerTalking(PlayerId()) or false
                if currentData.talking ~= nativeTalking then
                    currentData.talking = nativeTalking
                end
            end

            if currentData.voiceRange ~= voiceRange then
                currentData.voiceRange = voiceRange
                UpdateHUDUI()
            end
        end
        Wait(250) -- Update range and backup voice state every 250ms
    end
end)

-- 5. SPEEDOMETER SYSTEM LOOP (Smooth & Optimized)
CreateThread(function()
    local odometers = {}
    local inVehicle = false

    while true do
        if playerLoaded then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            -- Check if player is actually inside a vehicle and is the driver
            if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
                inVehicle = true

                local speed = GetEntitySpeed(veh) * 3.6 -- Convert to KMH
                local rpm = GetVehicleCurrentRpm(veh) or 0.0
                local gear = GetVehicleCurrentRpm(veh) > 0.0 and GetVehicleCurrentGear(veh) or 0
                local plate = GetVehicleNumberPlateText(veh) or "00000000"
                local fuel = GetVehicleFuelLevel(veh) or 100.0
                local engine = GetVehicleEngineHealth(veh) or 1000.0

                -- Initialize odometer for this vehicle plate if not tracked yet
                if not odometers[plate] then
                    -- Generate realistic start mileage (e.g. 500 to 15000 KM)
                    odometers[plate] = math.random(500, 15000) + 0.0
                end

                -- Calculate distance traveled: GetEntitySpeed gives m/s. Loop wait is 100ms (0.1 seconds)
                local speedMS = GetEntitySpeed(veh)
                local distanceKM = (speedMS * 0.1) / 1000.0
                odometers[plate] = odometers[plate] + distanceKM

                -- Format gear symbol
                local gearText = tostring(gear)
                if gear == 0 then
                    if speed > 1.0 then
                        gearText = "R" -- Reverse
                    else
                        gearText = "N" -- Neutral
                    end
                end

                SendNUIMessage({
                    action = 'updateSpeedometer',
                    show = true,
                    speed = speed,
                    rpm = rpm,
                    gear = gearText,
                    odo = odometers[plate],
                    fuel = fuel,
                    engine = engine
                })
                Wait(100) -- Update speed/RPM 10 times per second for fluid rendering
            else
                -- If player just exited vehicle, hide speedometer
                if inVehicle then
                    inVehicle = false
                    SendNUIMessage({
                        action = 'updateSpeedometer',
                        show = false
                    })
                end
                Wait(1000) -- Check less frequently when not in a vehicle (saves CPU performance)
            end
        else
            Wait(1000)
        end
    end
end)

-- Exports for Standalone use
exports('UpdateMoney', function(cash, bank, dirty)
    if cash ~= nil then currentData.cash = cash end
    if bank ~= nil then currentData.bank = bank end
    if dirty ~= nil then currentData.dirty = dirty end
    UpdateHUDUI()
end)

exports('UpdateJob', function(jobLabel)
    if jobLabel ~= nil then
        currentData.job = jobLabel
    end
    UpdateHUDUI()
end)

-- 6. LOCATION SYSTEM
function SetupSquareRadar()
    -- Credit to Dalrae for the solve.
    local defaultAspectRatio = 1920/1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX/resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio-aspectRatio)/3.6)-0.008
    end

    RequestStreamedTextureDict("minimap", false)
    if not HasStreamedTextureDictLoaded("minimap") then
        Wait(150)
    end

    -- Ensure standard rectangle clipping for our custom minimap.ytd mask
    SetMinimapClipType(0)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "minimap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "minimap", "radarmasksm")

    -- Reshape the standard GTA V rectangular radar into a square
    SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)
    SetMinimapComponentPosition("minimap_blur", "L", "B", -0.01 + minimapOffset, 0.025, 0.262, 0.300)

    -- Refresh radar to apply changes
    SetRadarBigmapEnabled(true, false)
    Wait(50)
    SetRadarBigmapEnabled(false, false)
end

CreateThread(function()
    Wait(1000)
    SetupSquareRadar()

    while true do
        if playerLoaded then
            -- Only update location UI if minimap/radar is currently visible
            if not IsRadarHidden() and not IsPauseMenuActive() then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)

                -- Fetch Street name
                local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                local streetName = GetStreetNameFromHashKey(streetHash)
                local crossingName = GetStreetNameFromHashKey(crossingHash)
                local streetText = streetName ~= "" and streetName or "Nežinoma gatvė"
                if crossingName ~= "" then
                    streetText = streetName .. " / " .. crossingName
                end

                -- Fetch Zone name
                local zone = GetNameOfZone(coords.x, coords.y, coords.z)
                local zoneText = GetLabelText(zone)
                if zoneText == "NULL" or not zoneText then
                    zoneText = zone
                end

                -- Calculate heading direction (N, NE, E, SE, S, SW, W, NW)
                local heading = GetEntityHeading(ped)
                local directions = {"N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"}
                local dirIndex = math.floor((heading + 22.5) / 45.0) + 1
                local directionText = directions[dirIndex] or "N"

                -- Calculate elevation in feet
                local elevation = math.floor(coords.z * 3.28084)

                -- Fetch postal code (safe check for nearest-postal exports)
                local postal = ""
                if GetResourceState('nearest-postal') == 'started' then
                    local pcallSuccess, postalVal = pcall(function()
                        return exports['nearest-postal']:getPostal()
                    end)
                    if pcallSuccess and postalVal then
                        postal = tostring(postalVal)
                    end
                end

                if postal == "" then
                    -- Generate a mock postal code based on global grid coordinates if no script exists
                    local gridX = math.floor((coords.x + 8000) / 25)
                    local gridY = math.floor((coords.y + 8000) / 25)
                    postal = tostring((gridX + gridY) % 9000 + 1000)
                end

                -- Format details (matches the Grapeseed, 2024 (484ft) layout)
                local detailsText = string.format("%s, %s (%sft)", zoneText, postal, elevation)

                SendNUIMessage({
                    action = 'updateLocation',
                    show = true,
                    direction = directionText,
                    street = streetText,
                    details = detailsText
                })
            else
                -- Hide location HUD if minimap is not active
                SendNUIMessage({
                    action = 'updateLocation',
                    show = false
                })
            end
        end
        Wait(350) -- Update location details 3 times per second
    end
end)
