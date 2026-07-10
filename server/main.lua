local QBCore = nil
local ESX = nil

-- Detect Framework on Startup Safely
CreateThread(function()
    Wait(500)
    -- Try QB-Core
    if GetResourceState('qb-core') == 'started' then
        pcall(function()
            QBCore = exports['qb-core']:GetCoreObject()
        end)
    end

    -- Try ESX
    if not QBCore and GetResourceState('es_extended') == 'started' then
        pcall(function()
            ESX = exports['es_extended']:getSharedObject()
        end)

        if not ESX then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
    end
end)

-- Fetch player data based on framework
function GetPlayerData(source)
    local cash = 0
    local bank = 0
    local dirty = 0
    local jobLabel = Config.JobLabelFallback

    if QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            cash = Player.PlayerData.money['cash'] or 0
            bank = Player.PlayerData.money['bank'] or 0
            dirty = Player.PlayerData.money['black_money'] or Player.PlayerData.money['dirty'] or 0

            -- Check for QB-Core marked bills item if no dirty money account exists
            if dirty == 0 then
                local markedBills = Player.Functions.GetItemByName('markedbills')
                if markedBills then
                    if markedBills.info and markedBills.info.worth then
                        dirty = markedBills.info.worth
                    else
                        dirty = (markedBills.amount or 0) * 100
                    end
                end
            end

            -- Format job
            local job = Player.PlayerData.job
            if job and job.name ~= 'unemployed' then
                local jobName = job.label or Config.JobLabelFallback
                local gradeName = (job.grade and job.grade.name) or ''
                if gradeName ~= '' then
                    jobLabel = string.format("%s (%s)", jobName, gradeName)
                else
                    jobLabel = jobName
                end
            else
                jobLabel = Config.JobLabelFallback
            end
        end
        return cash, bank, dirty, jobLabel
    elseif ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            -- ESX money
            cash = xPlayer.getMoney() or 0
            bank = xPlayer.getAccount('bank') and xPlayer.getAccount('bank').money or 0
            dirty = xPlayer.getAccount('black_money') and xPlayer.getAccount('black_money').money or 0

            -- Format job
            local job = xPlayer.getJob()
            if job and job.name ~= 'unemployed' then
                local jobName = job.label or Config.JobLabelFallback
                local gradeLabel = job.grade_label or ''
                if gradeLabel ~= '' then
                    jobLabel = string.format("%s (%s)", jobName, gradeLabel)
                else
                    jobLabel = jobName
                end
            else
                jobLabel = Config.JobLabelFallback
            end
        end
        return cash, bank, dirty, jobLabel
    end

    -- Standalone fallback
    return nil
end

-- Update a single player's HUD
function UpdatePlayerHUD(source)
    local cash, bank, dirty, job = GetPlayerData(source)
    if cash ~= nil then
        TriggerClientEvent('jg-hud:client:updateData', source, {
            cash = cash,
            bank = bank,
            dirty = dirty,
            job = job
        })
    end
end

-- Client requested initial load
RegisterNetEvent('jg-hud:server:initPlayer', function()
    local src = source
    UpdatePlayerHUD(src)
end)

-- Framework Event Handlers for Real-Time Updates
-- 1. QB-Core Hooks
RegisterNetEvent('QBCore:Server:OnMoneyChange', function(playerId, moneyType, amount, operation)
    UpdatePlayerHUD(playerId)
end)

RegisterNetEvent('QBCore:Server:OnJobUpdate', function(playerId, job)
    UpdatePlayerHUD(playerId)
end)

-- 2. ESX Hooks
RegisterNetEvent('esx:setAccountMoney', function(playerId, accountName, money)
    UpdatePlayerHUD(playerId)
end)

RegisterNetEvent('esx:setJob', function(playerId, job)
    UpdatePlayerHUD(playerId)
end)

-- Sync loop for ESX and fallback systems (checks every 4 seconds to ensure perfect sync)
CreateThread(function()
    while true do
        local players = {}
        if QBCore then
            players = QBCore.Functions.GetPlayers()
        elseif ESX then
            players = ESX.GetPlayers()
        end

        for _, playerId in ipairs(players) do
            UpdatePlayerHUD(playerId)
        end
        Wait(4000)
    end
end)

-- Exports/Events for Standalone use or manually updating from server scripts
RegisterNetEvent('jg-hud:server:updateStandaloneData', function(playerId, cash, bank, dirty, job)
    TriggerClientEvent('jg-hud:client:updateData', playerId, {
        cash = cash,
        bank = bank,
        dirty = dirty,
        job = job
    })
end)
