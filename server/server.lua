ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_robnpc:giveMoney', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = getStolenItem()
    if(item.Name == 'money')
    then
    local money = math.random(Config.MinMoney, Config.MaxMoney)
    xPlayer.addMoney(money)
    callback('$'..money)
    else
        xPlayer.addInventoryItem(item.Name,1) 
        callback(item.Label)
    end
    
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

function getStolenItem()
    local chanceNumber = math.random(Config.StolenItems.MinChance, Config.StolenItems.MaxChance)
    print("number " .. chanceNumber)
        for i=1, #Config.StolenItems.Items, 1 do
             if(Config.StolenItems.Items[i].ChanceRangeMin <= chanceNumber and Config.StolenItems.Items[i].ChanceRangeMax >= chanceNumber)
            then
            return Config.StolenItems.Items[i];
            end
    end
end