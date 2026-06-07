local TVCoords = vector3(-686.4661, 331.7252, 83.0832)
local TVHeading = 353.1292
local TVModelHash = GetHashKey('prop_tv_flat_01')
-- Standard TV prop that supports render targets.
local TVProp = nil
local scaleform = nil

local isPlaying = false
local currentUrl = ""
local clientVolume = 50 -- Track volume locally for the UI default

-- Render target setup for "no pixels" sharp display
local duiObj = nil
local duiUrl = "nui://vata-tv/html/index.html"
local renderTargetName = "tvscreen" -- typical render target for TVs in GTA V
local txd = "vata_tv_txd"
local txn = "vata_tv_txn"

Citizen.CreateThread(function()
    -- Request model and spawn the TV
    RequestModel(TVModelHash)
    while not HasModelLoaded(TVModelHash) do
        Wait(10)
    end

    -- Check if it already exists, to avoid duplicates
    local existingProp = GetClosestObjectOfType(TVCoords.x, TVCoords.y, TVCoords.z, 2.0, TVModelHash, false, false, false)
    if existingProp == 0 then
        TVProp = CreateObject(TVModelHash, TVCoords.x, TVCoords.y, TVCoords.z, false, false, false)
        SetEntityHeading(TVProp, TVHeading)
        FreezeEntityPosition(TVProp, true)
    else
        TVProp = existingProp
    end

    -- Set up render target
    RegisterNamedRendertarget(renderTargetName, false)
    LinkNamedRendertarget(TVModelHash)
    local handle = GetNamedRendertargetRenderId(renderTargetName)

    -- Set up DUI (1920x1080 for sharp image)
    duiObj = CreateDui(duiUrl, 1920, 1080)
    local duiHandle = GetDuiHandle(duiObj)

    -- Create texture dict and texture from DUI
    local txdHashes = CreateRuntimeTxd(txd)
    local txnHashes = CreateRuntimeTextureFromDuiHandle(txdHashes, txn, duiHandle)

    while true do
        local waitTime = 1000
        if isPlaying then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - TVCoords)

            if distance < 50.0 then
                waitTime = 0
                -- Render the texture to the TV
                SetTextRenderId(handle)
                Set_2dLayer(4)
                SetScriptGfxDrawOrder(4)
                SetScriptGfxDrawBehindPausemenu(true)
                DrawSprite(txd, txn, 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
                SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            end
        end
        Wait(waitTime)
    end
end)

-- Event to sync the TV screen from the server
RegisterNetEvent('vata-tv:syncClient')
AddEventHandler('vata-tv:syncClient', function(url, volume)
    if volume then
        clientVolume = math.floor(volume * 100)
    end

    if url and url ~= "" then
        isPlaying = true
        currentUrl = url

        -- Send message to NUI (inside the DUI) to start playing the video visually
        SendDuiMessage(duiObj, json.encode({
            type = "playVideo",
            url = url
        }))
    else
        isPlaying = false
        currentUrl = ""

        -- Send message to NUI to stop
        SendDuiMessage(duiObj, json.encode({
            type = "stopVideo"
        }))
    end
end)

-- Command to open the UI
RegisterCommand('tv', function(source, args, rawCommand)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - TVCoords)

    -- Only allow if nearby
    if distance > 10.0 then
        lib.notify({
            title = 'vata-tv',
            description = 'Jūs esate per toli nuo televizoriaus.',
            type = 'error'
        })
        return
    end

    -- Open ox_lib input dialog
    local input = lib.inputDialog('Televizoriaus Valdymas', {
        {type = 'input', label = 'Video URL (pvz: YouTube)', description = 'Įveskite norimo video nuorodą', default = currentUrl, icon = 'link', required = false},
        {type = 'slider', label = 'Garsas (0-100)', min = 0, max = 100, default = clientVolume, icon = 'volume-high', required = true},
        {type = 'input', label = 'Kūrėjas', default = 'vateko sytema - by vatekas', icon = 'user', disabled = true}
    })

    if not input then return end

    local inputUrl = input[1]
    local inputVolume = input[2] / 100.0 -- Convert 0-100 to 0.0-1.0

    if inputUrl and inputUrl ~= "" then
        -- Trigger server to play the video for everyone
        TriggerServerEvent('vata-tv:play', inputUrl, inputVolume)
    else
        -- If no URL is provided, consider it a stop command
        TriggerServerEvent('vata-tv:stop')
    end
end, false)