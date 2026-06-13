local phoneOpen = false

-- Function to toggle the phone UI
local function TogglePhone(state)
    phoneOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = "togglePhone",
        state = state
    })
end

-- Command to open the phone for testing
RegisterCommand('phone_setup', function()
    TogglePhone(not phoneOpen)
end, false)

-- NUI Callback to close the phone from JS
RegisterNUICallback('closePhone', function(data, cb)
    TogglePhone(false)
    cb('ok')
end)

-- NUI Callback when language is selected
RegisterNUICallback('languageSelected', function(data, cb)
    -- Here we just print and close for now, as requested "kol kas padiark setupa nikeo daugeu nediark"
    print("Language selected: " .. tostring(data.language))
    TogglePhone(false)
    cb('ok')
end)
