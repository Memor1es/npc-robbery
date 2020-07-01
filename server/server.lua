ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_robnpc:giveMoney', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = math.random(Config.MinMoney, Config.MaxMoney)
    xPlayer.addMoney(money)
    callback(money)
end)


RegisterServerEvent('civRobberyNotify')
AddEventHandler('civRobberyNotify', function()
	TriggerClientEvent("civRobbingEnable", source)
end)

RegisterServerEvent('robbingCivInProgressPos')
AddEventHandler('robbingCivInProgressPos', function(gx, gy, gz)
	TriggerClientEvent('civRobberyPlace', -1, gx, gy, gz)
end)

RegisterServerEvent('civRobberyInProgressS1')
AddEventHandler('civRobberyInProgressS1', function(street1, sex)
	TriggerClientEvent("civRobOutlawNotify", -1, "~r~Pedestrian robbery taking place by ~w~"..sex.." ~r~ at ~w~"..street1)
end)

RegisterServerEvent('civRobberyInProgress')
AddEventHandler('civRobberyInProgress', function(street1, street2, sex)
	TriggerClientEvent("civRobOutlawNotify", -1, "~r~Pedestrian robbery taking place by ~w~"..sex.." ~r~ between ~w~"..street1.."~r~ and ~w~"..street2)
end)