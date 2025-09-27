local tabletObj

local function Tablet(tablet)
    ClearPedTasks(cache.ped)
    if not tablet then
        if tabletObj then
            DetachEntity(tabletObj, true, false)
            DeleteEntity(tabletObj)
            tabletObj = nil
        end
        return
    end

    local animDict = "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a"
    local animName = "idle_a"
    local propModel = "prop_cs_tablet"
    local propBone = 28422
    local propPlacement = vector3(-0.05, 0.0, 0.0)
    local propRot = vector3(0.0, -90.0, 0.0)

    lib.playAnim(cache.ped, animDict, animName, 8.0, 8.0, -1, 51)

    lib.requestModel(propModel)

    tabletObj = CreateObject(propModel, 0.0, 0.0, 0.0, true, true, false)
    local tabletBoneIndex = GetPedBoneIndex(cache.ped, propBone)

    AttachEntityToEntity(tabletObj, cache.ped, tabletBoneIndex, propPlacement.x, propPlacement.y, propPlacement.z,
        propRot.x, propRot.y, propRot.z, true, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(propModel)
end

local function OpenNui(arg)
    SetNuiFocus(arg, arg)
    SendNUIMessage({
        action = 'setVisible',
        data = arg
    })
    if Config.UseItem then
        Tablet(arg)
    end
end

if Config.UseItem then
    exports('quest_tablet', function(data, slot)
        OpenNui(true)
    end)
else
    RegisterCommand('quests', function()
        OpenNui(true)
    end)
end

RegisterNUICallback('hide-ui', function(_, cb)
    OpenNui(false)
    cb({})
end)

RegisterNUICallback('setRefreshTime', function(_, cb)
    local time = lib.callback.await('ec-quests:refreshTime', false)
    cb({
        time = time
    })
end)

RegisterNUICallback('setLeaderboard', function(_, cb)
    local leaderboard = lib.callback.await('ec-quests:getLeaderboard', false)
    cb({
        leaderboard = leaderboard
    })
end)

RegisterNUICallback('claimReward', function(data, cb)
    local success = lib.callback.await('ec-quests:claimReward', false, data.id)
    cb({
        success = success
    })
end)

RegisterNUICallback('setQuestMenu', function(_, cb)
    local playerXP = lib.callback.await('ec-quests:getXP', false)
    cb({
        theme = Config.PrimaryColor,
        quests = lib.callback.await('ec-quests:getQuest', false), -- lib.callback.await('ec-quests:getQuest', false)
        playerXP = playerXP
    })
end)

if debug.mode then
    RegisterCommand('clear', function(source, args)
        TriggerEvent('chat:clear')
    end, false)
end
