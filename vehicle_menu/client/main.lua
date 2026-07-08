local menuOpen = false
local updateLoopActive = false

-- Open Menu Command and KeyMapping
RegisterCommand('openvehiclemenu', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        if not menuOpen then
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = "openMenu"
            })
            menuOpen = true

            if not updateLoopActive then
                updateLoopActive = true
                StartUpdateLoop()
            end
        end
    end
end, false)

RegisterKeyMapping('openvehiclemenu', 'Open Vehicle Menu', 'keyboard', 'G')

-- Update Loop for NUI Data
function StartUpdateLoop()
    Citizen.CreateThread(function()
        while updateLoopActive do
            Citizen.Wait(1000) -- Update every second

            if menuOpen then
                local ped = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped, false)

                if vehicle and vehicle ~= 0 then
                    local coords = GetEntityCoords(ped)
                    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                    local streetName = GetStreetNameFromHashKey(streetHash)

                    local engineTemp = GetVehicleEngineTemperature(vehicle)
                    local fuelLevel = GetVehicleFuelLevel(vehicle)
                    local engineRunning = GetIsVehicleEngineRunning(vehicle)

                    SendNUIMessage({
                        type = "updateData",
                        street = streetName,
                        temperature = engineTemp,
                        fuel = fuelLevel,
                        engineRunning = engineRunning
                    })
                else
                    -- Auto close if player left vehicle while menu was open
                    CloseMenu()
                end
            else
                updateLoopActive = false
            end
        end
    end)
end

function CloseMenu()
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "closeMenu"
    })
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('toggleEngine', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then
        local isRunning = GetIsVehicleEngineRunning(vehicle)
        SetVehicleEngineOn(vehicle, not isRunning, false, true)
    end
    cb('ok')
end)

RegisterNUICallback('changeSeat', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then
        local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
        local currentSeat = -1 -- Default to attempting to find a seat if we can't determine current

        -- Find current seat
        for i = -1, maxSeats - 1 do
            if GetPedInVehicleSeat(vehicle, i) == ped then
                currentSeat = i
                break
            end
        end

        -- Find next available seat
        local foundSeat = false
        for i = 1, maxSeats do
            local nextSeat = currentSeat + i
            if nextSeat >= maxSeats then nextSeat = nextSeat - (maxSeats + 1) end -- Wrap around (-1 to maxSeats-1)

            if IsVehicleSeatFree(vehicle, nextSeat) then
                TaskWarpPedIntoVehicle(ped, vehicle, nextSeat)
                foundSeat = true
                break
            end
        end
    end
    cb('ok')
end)

RegisterNUICallback('toggleLock', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then
        local lockStatus = GetVehicleDoorLockStatus(vehicle)
        if lockStatus == 1 or lockStatus == 0 then
            SetVehicleDoorsLocked(vehicle, 2) -- Locked
        else
            SetVehicleDoorsLocked(vehicle, 1) -- Unlocked
        end
    end
    cb('ok')
end)

RegisterNUICallback('toggleDoor', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then
        local doorIndex = data.door
        if GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0.0 then
            SetVehicleDoorShut(vehicle, doorIndex, false)
        else
            SetVehicleDoorOpen(vehicle, doorIndex, false, false)
        end
    end
    cb('ok')
end)

RegisterNUICallback('toggleInteriorLight', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then
        -- Native for interior lights toggle isn't straightforward without specific state tracking,
        -- but SetVehicleInteriorlight can be used.
        local state = IsVehicleInteriorLightOn(vehicle)
        SetVehicleInteriorlight(vehicle, not state)
    end
    cb('ok')
end)

RegisterNUICallback('toggleLights', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then
        local _, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
        if lightsOn == 1 or highbeamsOn == 1 then
            SetVehicleLights(vehicle, 0) -- Off
        else
            SetVehicleLights(vehicle, 2) -- On
        end
    end
    cb('ok')
end)

RegisterNUICallback('toggleHazards', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then
        if data.state then
            SetVehicleIndicatorLights(vehicle, 0, true) -- Left
            SetVehicleIndicatorLights(vehicle, 1, true) -- Right
        else
            SetVehicleIndicatorLights(vehicle, 0, false)
            SetVehicleIndicatorLights(vehicle, 1, false)
        end
    end
    cb('ok')
end)
