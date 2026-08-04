-- Vata Recoil Script
-- Custom recoil script for different weapons, with grip attachment support.

local recoils = {
    -- Assault Rifles (Automatukai)
    [GetHashKey("WEAPON_ASSAULTRIFLE")] = { recoil = 0.6, canHaveGrip = true },
    [GetHashKey("WEAPON_CARBINERIFLE")] = { recoil = 0.6, canHaveGrip = true },
    [GetHashKey("WEAPON_ADVANCEDRIFLE")] = { recoil = 0.6, canHaveGrip = true },
    [GetHashKey("WEAPON_SPECIALCARBINE")] = { recoil = 0.6, canHaveGrip = true },
    [GetHashKey("WEAPON_BULLPUPRIFLE")] = { recoil = 0.6, canHaveGrip = true },
    [GetHashKey("WEAPON_COMPACTRIFLE")] = { recoil = 0.6, canHaveGrip = false },

    -- SMGs (Pusautomačiai)
    [GetHashKey("WEAPON_SMG")] = { recoil = 0.5, canHaveGrip = true },
    [GetHashKey("WEAPON_MICROSMG")] = { recoil = 0.5, canHaveGrip = false },
    [GetHashKey("WEAPON_ASSAULTSMG")] = { recoil = 0.5, canHaveGrip = true },
    [GetHashKey("WEAPON_COMBATPDW")] = { recoil = 0.5, canHaveGrip = true },
    [GetHashKey("WEAPON_MACHINEPISTOL")] = { recoil = 0.5, canHaveGrip = false },
    [GetHashKey("WEAPON_MINISMG")] = { recoil = 0.5, canHaveGrip = false },

    -- Shotguns (Šautuvai)
    [GetHashKey("WEAPON_PUMPSHOTGUN")] = { recoil = 2.2, canHaveGrip = false },
    [GetHashKey("WEAPON_SAWNOFFSHOTGUN")] = { recoil = 2.4, canHaveGrip = false },
    [GetHashKey("WEAPON_ASSAULTSHOTGUN")] = { recoil = 1.7, canHaveGrip = true },
    [GetHashKey("WEAPON_BULLPUPSHOTGUN")] = { recoil = 1.8, canHaveGrip = true },
    [GetHashKey("WEAPON_HEAVYSHOTGUN")] = { recoil = 2.2, canHaveGrip = true },
    [GetHashKey("WEAPON_DBSHOTGUN")] = { recoil = 2.4, canHaveGrip = false },
    [GetHashKey("WEAPON_AUTOSHOTGUN")] = { recoil = 1.8, canHaveGrip = false },

    -- Pistols (Pistoletai ir Deagle)
    [GetHashKey("WEAPON_PISTOL")] = { recoil = 0.7, isPistol = true },
    [GetHashKey("WEAPON_COMBATPISTOL")] = { recoil = 0.7, isPistol = true },
    [GetHashKey("WEAPON_APPISTOL")] = { recoil = 0.6, isPistol = true },
    [GetHashKey("WEAPON_PISTOL50")] = { recoil = 1.9, isPistol = true }, -- Deagle (stipresnė atatranka)
    [GetHashKey("WEAPON_SNSPISTOL")] = { recoil = 0.7, isPistol = true },
    [GetHashKey("WEAPON_HEAVYPISTOL")] = { recoil = 1.0, isPistol = true },
    [GetHashKey("WEAPON_VINTAGEPISTOL")] = { recoil = 0.7, isPistol = true },
    [GetHashKey("WEAPON_MARKSMANPISTOL")] = { recoil = 1.2, isPistol = true },
    [GetHashKey("WEAPON_REVOLVER")] = { recoil = 1.7, isPistol = true },
    [GetHashKey("WEAPON_CERAMICPISTOL")] = { recoil = 0.7, isPistol = true },
    [GetHashKey("WEAPON_NAVYREVOLVER")] = { recoil = 1.7, isPistol = true },
}

local gripHashes = {
    [GetHashKey("WEAPON_ASSAULTRIFLE")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_CARBINERIFLE")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_ADVANCEDRIFLE")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_SPECIALCARBINE")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_BULLPUPRIFLE")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_SMG")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_ASSAULTSMG")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_COMBATPDW")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_ASSAULTSHOTGUN")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_BULLPUPSHOTGUN")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
    [GetHashKey("WEAPON_HEAVYSHOTGUN")] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()

        -- Tikriname, ar žaidėjas ginkluotas šaunamuoju ginklu (6)
        if IsPedArmed(ped, 6) then
            if IsPedShooting(ped) then
                local _, weaponHash = GetCurrentPedWeapon(ped, true)
                local recoilData = recoils[weaponHash]

                if recoilData then
                    local recoilAmount = recoilData.recoil

                    -- Jei ginklas nėra pistoletas, gali turėti laikiklį ir mes jį aptinkame
                    if not recoilData.isPistol and recoilData.canHaveGrip and gripHashes[weaponHash] then
                        if HasPedGotWeaponComponent(ped, weaponHash, gripHashes[weaponHash]) then
                            -- Sumažiname atatranką 25%, padarant ją lengvesnę
                            recoilAmount = recoilAmount * 0.75
                        end
                    end

                    -- Gauname dabartinį kameros kampą
                    local pitch = GetGameplayCamRelativePitch()

                    -- Šiek tiek randomizuojame atatranką (nuo 80% iki 120%), kad atrodytų natūraliau
                    local multiplier = math.random(80, 120) / 100.0
                    local finalRecoil = recoilAmount * multiplier

                    -- Pritaikius naują kameros kampą
                    SetGameplayCamRelativePitch(pitch + finalRecoil, 1.0)
                end
            end
        else
            -- Jei žaidėjas neginkluotas, palaukiame ilgiau, kad sutaupytume resursų
            Citizen.Wait(500)
        end
    end
end)
