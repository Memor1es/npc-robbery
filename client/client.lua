ESX = nil

local robbedRecently = false
local PlayerData = {}
local isRobbingNPC = false;
local civRobbingInProgress = false;


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if IsControlJustPressed(0, 38) then
            local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))

            if aiming then
                local playerPed = GetPlayerPed(-1)
                local pCoords = GetEntityCoords(playerPed, true)
                local tCoords = GetEntityCoords(targetPed, true)

                if DoesEntityExist(targetPed) and IsEntityAPed(targetPed) then
                    if robbedRecently then
                        ESX.ShowNotification(_U('robbed_too_recently'))
                    elseif IsPedDeadOrDying(targetPed, true) then
                        ESX.ShowNotification(_U('target_dead'))
                    elseif GetDistanceBetweenCoords(pCoords.x, pCoords.y, pCoords.z, tCoords.x, tCoords.y, tCoords.z, true) >= Config.RobDistance then
                        ESX.ShowNotification(_U('target_too_far'))
                    else
                        exports['progressBars']:startUI(10000, "Robbing victim")
                        robNpc(targetPed,playerPed)
                    end
                end
            end
        end
    end
end)

function robNpc(targetPed,playerPed)
    robbedRecently = true
    Citizen.CreateThread(function()
        local dict = 'random@mugging3'
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(10)
        end

        TaskStandStill(targetPed, Config.RobAnimationSeconds * 1000)
        FreezeEntityPosition(targetPed, true)
        FreezeEntityPosition(playerPed, true)
        TaskPlayAnim(targetPed, dict, 'handsup_standing_base', 8.0, -8, .01, 49, 0, 0, 0, 0)
        ESX.ShowNotification(_U('robbery_started'))
        secondsRemaining = Config.RobAnimationSeconds + 1
	    isRobbingNPC = true
        TriggerServerEvent('civRobberyNotify')
        Citizen.Wait(Config.RobAnimationSeconds * 1000)

        ESX.TriggerServerCallback('esx_robnpc:giveMoney', function(amount)
            FreezeEntityPosition(targetPed, false)
            FreezeEntityPosition(playerPed, false)
            ESX.ShowNotification(_U('robbery_completed', amount))
        end)

        if Config.ShouldWaitBetweenRobbing then
            Citizen.Wait(math.random(Config.MinWaitSeconds, Config.MaxWaitSeconds) * 1000)
            ESX.ShowNotification(_U('can_rob_again'))
        end

        robbedRecently = false
    end)
end

RegisterNetEvent('robbingNPC')
AddEventHandler('robbingNPC', function()
	secondsRemaining = Config.RobAnimationSeconds + 1
	isRobbingNPC = true
end)

-- NOTIFY POLICE
RegisterNetEvent('civRobOutlawNotify')
AddEventHandler('civRobOutlawNotify', function(alert)
		if PlayerData.job ~= nil and PlayerData.job.name == 'police' then
            Notify(alert)
        end
end)

function Notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end

local timer = 1 --in minutes - Set the time during the player is outlaw
local showOutlaw = true --Set if show outlaw act on map
local blipTime = 25 --in second
local showcopsmisbehave = true --show notification when cops steal too
--End config

local timing = timer * 60000 --Don't touche it

Citizen.CreateThread(function()
    while true do
        Wait(100)
        if NetworkIsSessionStarted() then
            DecorRegister("IsOutlaw",  3)
            DecorSetInt(GetPlayerPed(-1), "IsOutlaw", 1)
            return
        end
    end
end)

Citizen.CreateThread( function()
    while true do
        Wait(100)
        local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
        local s1, s2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
        local street1 = GetStreetNameFromHashKey(s1)
        local street2 = GetStreetNameFromHashKey(s2)
        if civRobbingInProgress then
            DecorSetInt(GetPlayerPed(-1), "IsOutlaw", 2)
			if PlayerData.job ~= nil and PlayerData.job.name == 'police' and showcopsmisbehave == false then
			elseif PlayerData.job ~= nil and PlayerData.job.name == 'police' and showcopsmisbehave then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					local sex = nil
					if skin.sex == 0 then
						sex = "male" --male/change it to your language
					else
						sex = "female" --female/change it to your language
					end
					TriggerServerEvent('robbingCivInProgressPos', plyPos.x, plyPos.y, plyPos.z)
					if s2 == 0 then
						TriggerServerEvent('civRobberyInProgressS1', street1, sex)
					elseif s2 ~= 0 then
						TriggerServerEvent('civRobberyInProgress', street1, street2, sex)
					end
				end)
				Wait(3000)
				civRobbingInProgress = false
			else
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					local sex = nil
					if skin.sex == 0 then
						sex = "male"
					else
						sex = "female"
					end
					TriggerServerEvent('robbingCivInProgressPos', plyPos.x, plyPos.y, plyPos.z)
					if s2 == 0 then
						TriggerServerEvent('civRobberyInProgressS1', street1, sex)
					elseif s2 ~= 0 then
						TriggerServerEvent('civRobberyInProgress', street1, street2, sex)
					end
				end)
				Wait(3000)
				civRobbingInProgress = false
			end
        end
    end
end)

RegisterNetEvent('civRobberyPlace')
AddEventHandler('civRobberyPlace', function(tx, ty, tz)
	if PlayerData.job.name == 'police' then
		local transT = 250
		local Blip = AddBlipForCoord(tx, ty, tz)
		SetBlipSprite(Blip,  10)
		SetBlipColour(Blip,  1)
		SetBlipAlpha(Blip,  transT)
		SetBlipAsShortRange(Blip,  false)
		while transT ~= 0 do
			Wait(blipTime * 4)
			transT = transT - 1
			SetBlipAlpha(Blip,  transT)
			if transT == 0 then
				SetBlipSprite(Blip,  2)
				return
			end
		end
	end
end)

RegisterNetEvent('civRobbingEnable')
AddEventHandler('civRobbingEnable', function()
	civRobbingInProgress = true
end)