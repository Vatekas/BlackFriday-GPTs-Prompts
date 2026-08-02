local ESX = exports["es_extended"]:getSharedObject()

-- Structure: activeTickets[source] = { creator = source, messages = {} }
-- Structure: activeTickets[source] = { creator = source, assignedAdmin = nil, messages = {} }
-- Structure: adminTickets[adminSource] = ticketSource
local activeTickets = {}
local adminTickets = {}

-- Helper to check if player is admin
local function isAdmin(xPlayer)
    if not xPlayer then return false end
    local group = xPlayer.getGroup()
    return group == 'admin' or group == 'superadmin'
end

-- Helper to get all online admins
local function getOnlineAdmins()
    local admins = {}
    local xPlayers = ESX.GetExtendedPlayers()
    for _, xPlayer in pairs(xPlayers) do
        if isAdmin(xPlayer) then
            table.insert(admins, xPlayer.source)
        end
    end
    return admins
end

RegisterNetEvent('vata-report:server:sendMessage')
AddEventHandler('vata-report:server:sendMessage', function(message)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer then return end

    local playerName = xPlayer.getName()
    local adminStatus = isAdmin(xPlayer)

    local messageData = {
        name = playerName,
        message = message,
        isAdmin = adminStatus
    }

    -- Normal player sending a report
    if not adminStatus then
        -- Create ticket if it doesn't exist
        if not activeTickets[_source] then
            activeTickets[_source] = {
                creator = _source,
                assignedAdmin = nil,
                messages = {}
            }
        end

        table.insert(activeTickets[_source].messages, messageData)

        -- Send back to the user
        TriggerClientEvent('vata-report:client:receiveMessage', _source, messageData)

        if activeTickets[_source].assignedAdmin then
             TriggerClientEvent('vata-report:client:receiveMessage', activeTickets[_source].assignedAdmin, messageData)
        else
            -- Broadcast to all admins if unassigned
            local admins = getOnlineAdmins()
            for _, adminSrc in ipairs(admins) do
                TriggerClientEvent('vata-report:client:receiveMessage', adminSrc, messageData)
            end
        end

    else
        -- Admin replying
        local targetTicketSrc = adminTickets[_source]

        if targetTicketSrc and activeTickets[targetTicketSrc] then
             table.insert(activeTickets[targetTicketSrc].messages, messageData)
             TriggerClientEvent('vata-report:client:receiveMessage', targetTicketSrc, messageData)
             TriggerClientEvent('vata-report:client:receiveMessage', _source, messageData)
        else
             -- No ticket assigned, do nothing or send error
        end
    end
end)

RegisterCommand('reply', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not isAdmin(xPlayer) then return end

    local targetSrc = tonumber(args[1])
    if not targetSrc or not activeTickets[targetSrc] then return end

    -- Assign admin to ticket
    adminTickets[source] = targetSrc
    activeTickets[targetSrc].assignedAdmin = source

    -- Could trigger an event to open the UI for the admin here with the ticket history
end, false)

RegisterNetEvent('vata-report:server:closeTicket')
AddEventHandler('vata-report:server:closeTicket', function()
    local _source = source
    local targetTicketSrc = _source

    -- If admin clicked close
    local xPlayer = ESX.GetPlayerFromId(_source)
    if isAdmin(xPlayer) and adminTickets[_source] then
         targetTicketSrc = adminTickets[_source]
         adminTickets[_source] = nil
    end

    if activeTickets[targetTicketSrc] then
        activeTickets[targetTicketSrc] = nil
    end
end)

AddEventHandler('playerDropped', function(reason)
    local _source = source

    if activeTickets[_source] then
        activeTickets[_source] = nil
    end

    if adminTickets[_source] then
        local targetTicketSrc = adminTickets[_source]
        if activeTickets[targetTicketSrc] then
             activeTickets[targetTicketSrc].assignedAdmin = nil
        end
        adminTickets[_source] = nil
    end
end)