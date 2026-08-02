-- vata-report/server/main.lua

-- Assuming ESX is imported via fxmanifest shared_scripts
-- local ESX = exports["es_extended"]:getSharedObject() -- Alternative if imports.lua is not enough depending on ESX version, but imports.lua is standard.

RegisterNetEvent('vata-report:server:sendMessage')
AddEventHandler('vata-report:server:sendMessage', function(message)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if not xPlayer then return end

    local playerName = xPlayer.getName()
    -- Check if admin (simplified for demo, adapt to your actual admin group logic)
    local isAdmin = false
    local group = xPlayer.getGroup()
    if group == 'admin' or group == 'superadmin' then
        isAdmin = true
    end

    local messageData = {
        name = playerName,
        message = message,
        isAdmin = isAdmin
    }

    -- For now, just send it back to the sender as a demo.
    -- In a real scenario, you'd route this to admins or the specific ticket channel.
    TriggerClientEvent('vata-report:client:receiveMessage', _source, messageData)

    -- Example of sending to admins:
    -- local xPlayers = ESX.GetExtendedPlayers('group', 'admin')
    -- for _, admin in pairs(xPlayers) do
    --     TriggerClientEvent('vata-report:client:receiveMessage', admin.source, messageData)
    -- end
end)

RegisterNetEvent('vata-report:server:closeTicket')
AddEventHandler('vata-report:server:closeTicket', function()
    local _source = source
    -- Logic to close ticket
    -- print("Ticket closed by " .. _source)
end)