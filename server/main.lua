QBCore = exports['qb-core']:GetCoreObject()


RegisterServerEvent('begging:begsomemoney')
AddEventHandler('begging:begsomemoney', function(targetPed)
    local source = source
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local pPed = GetPlayerPed(source)
    local money = math.random(Config.MinMoney, Config.MaxMoney)
    local playerPos = GetEntityCoords(pPed, true)
    local targetPedPos = GetEntityCoords(targetPed, true)
    local distance = #(playerPos - targetPedPos)

    if distance >= Config.MaxDistance + 4 then
        xPlayer.Functions.AddMoney('cash', money)
        TriggerClientEvent('QBCore:Notify', source, 'The person was nice and gave you ' .. money .. '$')
    end
end)
