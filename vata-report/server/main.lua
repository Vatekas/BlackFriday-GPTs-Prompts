ESX = exports["es_extended"]:getSharedObject()

local activeTickets = {} -- [playerId] = { targetAdmin = adminId, messages = {} }
local activeAdmins = {} -- [adminId] = { isHandling = playerId }

-- Rate limiting mechanism
local messageCooldowns = {}
local COOLDOWN_TIME = 1000 -- 1 second

local function getPlayerName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getName()
    end
    return GetPlayerName(source)
end

local function isAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local group = xPlayer.getGroup()
        if group == 'admin' or group == 'superadmin' then
            return true
        end
    end
    return false
end

RegisterCommand('report', function(source, args, rawCommand)
    if source == 0 then return end
    TriggerClientEvent('vata-report:client:openUI', source, isAdmin(source))
end, false)

RegisterCommand('reply', function(source, args, rawCommand)
    if source == 0 then return end

    if not isAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1KLAIDA', 'Neturite teisės naudoti šios komandos.' } })
        return
    end

    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1KLAIDA', 'Naudojimas: /reply [ID]' } })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1KLAIDA', 'Žaidėjas nerastas.' } })
        return
    end

    -- Clear admin's chat history in UI when switching tickets
    TriggerClientEvent('vata-report:client:clearChat', source)

    -- Assign admin to ticket
    if not activeTickets[targetId] then
        activeTickets[targetId] = { messages = {} }
    end
    activeTickets[targetId].targetAdmin = source
    activeAdmins[source] = { isHandling = targetId }

    local adminName = getPlayerName(source)
    TriggerClientEvent('vata-report:client:receiveSystemMessage', targetId, "Administratorius " .. adminName .. " priėmė Jūsų pagalbos bilietą")
    TriggerClientEvent('chat:addMessage', source, { args = { '^2SISTEMA', 'Dabar aptarnaujate žaidėją ' .. targetId } })

    -- Send ticket history to admin
    for _, msg in ipairs(activeTickets[targetId].messages) do
        TriggerClientEvent('vata-report:client:receiveMessage', source, msg)
    end

    TriggerClientEvent('vata-report:client:openUI', source, true)
end, false)


RegisterNetEvent('vata-report:server:sendMessage')
AddEventHandler('vata-report:server:sendMessage', function(data)
    local src = source

    -- Rate limiting check
    local currentTime = GetGameTimer()
    if messageCooldowns[src] and (currentTime - messageCooldowns[src]) < COOLDOWN_TIME then
        return -- Ignore if spamming
    end
    messageCooldowns[src] = currentTime

    local message = data.message
    if not message or message == "" then return end

    local senderName = getPlayerName(src)
    local isSenderAdmin = isAdmin(src)

    -- Check if admin is currently handling a ticket
    local handlingData = isSenderAdmin and activeAdmins[src] or nil

    if handlingData and handlingData.isHandling then
        -- Admin replying to an active ticket
        local targetId = handlingData.isHandling

        local msgPayloadToUser = {
            sender = senderName,
            message = message,
            role = 'admin',
            time = 'ką tik'
        }

        local msgPayloadToAdmin = {
            sender = senderName,
            message = message,
            role = 'admin',
            time = 'ką tik'
        }

        if activeTickets[targetId] then
             table.insert(activeTickets[targetId].messages, msgPayloadToAdmin)
        end

        -- Send to user
        TriggerClientEvent('vata-report:client:receiveMessage', targetId, msgPayloadToUser)
        -- Send back to admin for UI update
        TriggerClientEvent('vata-report:client:receiveMessage', src, msgPayloadToAdmin)
    else
        -- Regular user sending report (or admin sending their own report)
        if not activeTickets[src] then
            activeTickets[src] = { messages = {} }
        end

        local msgPayload = {
            sender = senderName,
            message = message,
            role = 'user',
            time = 'ką tik',
            playerId = src
        }

        table.insert(activeTickets[src].messages, msgPayload)

        -- Send back to user for UI
        TriggerClientEvent('vata-report:client:receiveMessage', src, {
            sender = senderName,
            message = message,
            role = 'self',
            time = 'ką tik'
        })

        local targetAdmin = activeTickets[src].targetAdmin

        if targetAdmin and GetPlayerName(targetAdmin) then
            -- Send directly to handling admin
            TriggerClientEvent('vata-report:client:receiveMessage', targetAdmin, msgPayload)
        else
            -- Broadcast to all admins that a new unassigned message came in
            local players = ESX.GetPlayers()
            for i=1, #players, 1 do
                local adminSrc = players[i]
                if isAdmin(adminSrc) and (not activeAdmins[adminSrc] or not activeAdmins[adminSrc].isHandling) then
                    -- Only broadcast to admins NOT currently handling a ticket
                    TriggerClientEvent('vata-report:client:receiveMessage', adminSrc, msgPayload)
                end
            end
        end
    end
end)

RegisterNetEvent('vata-report:server:closeTicket')
AddEventHandler('vata-report:server:closeTicket', function()
    local src = source
    local isSenderAdmin = isAdmin(src)

    if isSenderAdmin then
        local handlingData = activeAdmins[src]
        if handlingData and handlingData.isHandling then
            local targetId = handlingData.isHandling
            activeTickets[targetId] = nil
            activeAdmins[src] = nil
            TriggerClientEvent('vata-report:client:receiveSystemMessage', targetId, "Administratorius uždarė jūsų pagalbos bilietą.")
            TriggerClientEvent('chat:addMessage', src, { args = { '^2SISTEMA', 'Bilietas uždarytas.' } })
        end
    else
        if activeTickets[src] then
            local targetAdmin = activeTickets[src].targetAdmin
            if targetAdmin and GetPlayerName(targetAdmin) then
                TriggerClientEvent('chat:addMessage', targetAdmin, { args = { '^3SISTEMA', 'Žaidėjas '..src..' uždarė savo bilietą.' } })
                if activeAdmins[targetAdmin] and activeAdmins[targetAdmin].isHandling == src then
                    activeAdmins[targetAdmin] = nil
                end
            end
            activeTickets[src] = nil
            TriggerClientEvent('vata-report:client:receiveSystemMessage', src, "Jūs uždarėte pagalbos bilietą.")
        end
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if activeTickets[src] then
        local targetAdmin = activeTickets[src].targetAdmin
        if targetAdmin and GetPlayerName(targetAdmin) then
             TriggerClientEvent('chat:addMessage', targetAdmin, { args = { '^3SISTEMA', 'Žaidėjas '..src..' atsijungė.' } })
             if activeAdmins[targetAdmin] and activeAdmins[targetAdmin].isHandling == src then
                activeAdmins[targetAdmin] = nil
             end
        end
        activeTickets[src] = nil
    end
    if activeAdmins[src] then
        local handling = activeAdmins[src].isHandling
        if handling and activeTickets[handling] then
            activeTickets[handling].targetAdmin = nil
            TriggerClientEvent('vata-report:client:receiveSystemMessage', handling, "Administratorius atsijungė.")
        end
        activeAdmins[src] = nil
    end
    messageCooldowns[src] = nil
end)
