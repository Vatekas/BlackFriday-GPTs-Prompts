local phoneOpen = false

-- Command to open the phone
RegisterCommand('phone', function()
    if not phoneOpen then
        SetDisplay(true)
    end
end, false)

-- Register a key mapping for the phone (optional, e.g., F1)
-- RegisterKeyMapping('phone', 'Open Phone', 'keyboard', 'F1')

function SetDisplay(bool)
    phoneOpen = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

RegisterNUICallback("close", function(data, cb)
    SetDisplay(false)
    if cb then cb("ok") end
end)

CreateThread(function()
    while true do
        Wait(0)
        if phoneOpen then
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        else
            Wait(500)
        end
    end
end)
