local isBegging = false
local cooldown = false
QBCore = exports['qb-core']:GetCoreObject()

--------------------------
--------- UTILS     ------
--------------------------

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

function LoadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(0)
    end
end

------------------------------
------- FUN STUFF      -------
------------------------------

-- Function to start begging
function StartBegging()
    if isBegging then
        QBCore.Functions.Notify("You are already begging.")
        return
    end

    -- Add targeting options for peds
    exports.ox_target:addGlobalPed({
        {
            name = 'ped_interaction',
            icon = 'fas fa-info-circle',
            label = 'Beg for some cash',
            onSelect = function(data)
                local ped = data.entity
                local playerPed = PlayerPedId()
                local pCoords, tCoords = GetEntityCoords(playerPed, true), GetEntityCoords(ped, true)

                if cooldown then
                    QBCore.Function.Notify("You need to wait a bit, let's not abuse the kindess of strangers!")
                end

                if DoesEntityExist(ped) and IsEntityAPed(ped) and not cooldown and not IsPedDeadOrDying(ped, true) then
                    if #(pCoords - tCoords) >= Config.MaxDistance then
                        QBCore.Functions.Notify("Go closer so you don't have to shout")
                    else
                        begSomeMoney(playerPed, ped)
                    end
                end
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then return false end

                local playerData = QBCore.Functions.GetPlayerData()
                local playerJob = playerData.job.name
                return playerJob == 'unemployed'
            end
        }
    })

    isBegging = true
    QBCore.Functions.Notify("You have started begging. Aim at someone to ask for money.")
end

-- Function to stop begging
function StopBegging()
    if not isBegging then
        QBCore.Functions.Notify("You are not currently begging.")
        return
    end

    -- Remove the targeting options for peds
    exports.ox_target:removeGlobalPed('ped_interaction')

    isBegging = false
    QBCore.Functions.Notify("You have stopped begging.")
end

-- Toggle function
function ToggleBegging()
    if isBegging then
        StopBegging()
    else
        StartBegging()
    end
end

-- Register the /beg command
RegisterCommand('beg', function(source, args)
    ToggleBegging()
end)

-- Event handler for radial menu option
RegisterNetEvent('begging:client:ToggleBegging', function()
    ToggleBegging()
end)


------------------------------------
------- DO THE THING ---------------
------------------------------------


function begSomeMoney(playerPed, targetPed)
    cooldown = true

    local dict = 'timetable@amanda@ig_4'
    local dict2 = 'special_ped@jane@monologue_5@monologue_5c'
    RequestAnimDict(dict)
    RequestAnimDict(dict2)
    while not HasAnimDictLoaded(dict) or not HasAnimDictLoaded(dict2) do
        Wait(10)
    end

    TaskPlayAnim(playerPed, dict, 'ig_4_base', 8.0, -8, .01, 49, 0, 0, 0, 0)

    local chance = math.random(1, 100)
    if chance > 10 then
        local playerCoords = GetEntityCoords(playerPed)

        -- Move ped closer to the player
        TaskGoToCoordAnyMeans(targetPed, playerCoords, 1.0, 0, false, 1, 0.0)
        repeat
            Wait(10)
            -- until (IsEntityAtCoord(targetPed, playerCoords, 1.0, 1.0, 1.0, false, false, 0))
        until #(GetEntityCoords(targetPed) - playerCoords) < 2.0

        ClearPedTasks(targetPed)
        SetEntityAsMissionEntity(targetPed, true, true)
        PlayPedAmbientSpeechNative(targetPed, "GENERIC_HI", "Speech_Params_Force")
        SetBlockingOfNonTemporaryEvents(targetPed, true)
        TaskLookAtEntity(targetPed, playerPed, 5500.0, 2048, 3)
        TaskTurnPedToFaceEntity(targetPed, playerPed, 5500)

        ClearPedTasks(targetPed)
        local MomeyModel = "p_banknote_onedollar_s"
        LoadModel(MomeyModel)
        local MoneyProp = CreateObject(GetHashKey(MomeyModel), GetEntityCoords(targetPed), false, true, false)
        AttachEntityToEntity(MoneyProp, targetPed, GetPedBoneIndex(targetPed, 6286), 0.13, 0.0, 0.0, 0.0, 0.0, 90.0, 20.0,
            true, true, false, true, 1, true)
        -- Hand the nomey
        LoadAnimDict("mp_common")
        TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -1, -1, 49, 0, 0, 0, 0)
        TaskPlayAnim(targetPed, "mp_common", "givetake1_a", 8.0, -1, -1, 49, 0, 0, 0, 0)

        Wait(2000)
        -- Trigger server event
        TriggerServerEvent('begging:begsomemoney', targetPed)

        Wait(50)
        DeleteEntity(MoneyProp)

        -- Now clean up the rest
        Wait(1000)
        ClearPedTasks(targetPed)
        ClearPedTasks(playerPed)
        SetEntityAsMissionEntity(targetPed, false, false)
        SetEntityAsNoLongerNeeded(targetPed)
    else
        QBCore.Functions.Notify("The person didn't want to give you any money")
        ClearPedSecondaryTask(playerPed)
    end

    if Config.ShouldWaitBetweenBegging then
        Wait(Config.Cooldown * 1000)
    end

    cooldown = false
end
