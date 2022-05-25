local bodycam = false
local UIToggle = false
local recording = false

RegisterNetEvent("ItsMatOG:toggleRecording")
AddEventHandler("ItsMatOG:toggleRecording", function(toggle)
    recording = not toggle
end)

RegisterNetEvent('ItsMatOG:toggleBodycam')
AddEventHandler('ItsMatOG:toggleBodycam', function()
    local ped = PlayerPedId()
    local player = PlayerPedId(PlayerId())
    local netID = NetworkGetNetworkIdFromEntity(player)
    loadAnimDict("clothingtie")
    if not bodycam then
        bodycam = true
        TaskPlayAnim(ped, "clothingtie", "try_tie_neutral_a", 3.0, 3.0, 1200, 51, 0, 0, 0, 0)
        Citizen.Wait(1200)
        PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
        ShowNotification("~b~Bodycam~w~: Axon Body Camera turned ~g~on~w~.")
        if recording then
            StartRecording(1)
        end
        Citizen.Wait(500)
        TriggerServerEvent("Server:SoundToRadius", netID, 4, "bodycam", 0.1)
    elseif bodycam then
        bodycam = false
        TaskPlayAnim(ped, "clothingtie", "try_tie_neutral_a", 3.0, 3.0, 1200, 51, 0, 0, 0, 0)
        Citizen.Wait(1200)
        PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
        if recording then
            StopRecordingAndSaveClip()
        end
        ShowNotification("~b~Bodycam~w~: Axon Body Camera turned ~r~off~w~.")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if bodycam then
            local ped = PlayerPedId()
            local player = PlayerPedId(PlayerId())
            local netID = NetworkGetNetworkIdFromEntity(player)
            Citizen.Wait(120000)
            if bodycam then
                TriggerServerEvent("Server:SoundToRadius", netID, 4, "bodycam", 0.1)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local name = GetPlayerName(PlayerId())
        if bodycam then
            local year, month, day, hour, minute, second = GetLocalTime()
            if month < 10 then
                month = "0" .. month
            end
            if day < 10 then
                day = "0" .. day
            end

            if not UIToggle then
                Citizen.Wait(500)
                SendNUIMessage({
                    transactionType = 'showBodycam',
                    show = true,
                    timestamp = "DATE: " .. year .. '-0' .. month .. '-' .. day .. ' ' .. 'TIME: ' .. hour .. ':' .. minute .. ':' .. second,
                    unit = "UNIT: " .. name
                })
                UIToggle = true
            end
            SendNUIMessage({
                transactionType = 'updateTime',
                timestamp = "DATE: " .. year .. '-' .. month .. '-' .. day .. ' ' .. 'TIME: ' .. hour .. ':' .. minute .. ':' .. second,
            })
        else
            if UIToggle then
                Citizen.Wait(500)
                SendNUIMessage({
                    transactionType = 'showBodycam',
                    show = false,
                })
                UIToggle = false
            end
        end
    end
end)

RegisterCommand('bodycam', function(source)
    TriggerEvent('ItsMatOG:toggleBodycam')
end, false)
TriggerEvent("chat:addSuggestion", "/bodycam", "Toggle the Axon Body Camera.")
RegisterKeyMapping('bodycam', 'Toggle the Axon Body Camera', 'keyboard', '')

RegisterCommand('bodycamrecord', function(source)
    TriggerEvent('ItsMatOG:toggleRecording')
end, false)
TriggerEvent("chat:addSuggestion", "/bodycamrecord", "Toggle the Axon Body Camera's recording features (Rockstar Recording).")

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end