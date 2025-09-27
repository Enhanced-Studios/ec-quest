local refreshTime
local leaderboard = {}
local activeQuest = {}

local function addPlayerToRegistry(identifier)
    local data = GetResourceKvpString('questPlayers')
    local players = data and json.decode(data) or {}
    if not players[identifier] then
        players[identifier] = true
        SetResourceKvp('questPlayers', json.encode(players))
    end
end

local function markQuestCompleted(source, questId)
    local identifier = GetPlayerIdentifierByType(source, 'license') or GetPlayerIdentifierByType(source, 'license2')
    if not identifier then
        return
    end

    addPlayerToRegistry(identifier)

    local key = ('quests:%s'):format(identifier)
    local data = GetResourceKvpString(key)
    local completed = data and json.decode(data) or {}
    completed[questId] = true
    SetResourceKvp(key, json.encode(completed))
end

local function resetAllQuests()
    local data = GetResourceKvpString('questPlayers')
    local players = data and json.decode(data) or {}

    for identifier, _ in pairs(players) do
        local key = ('quests:%s'):format(identifier)
        SetResourceKvp(key, json.encode({}))
    end

    print('[EC-Quests] All player quest completions reset!')
end

local function getPlayerCompleted(source)
    local identifier = GetPlayerIdentifierByType(source, 'license') or GetPlayerIdentifierByType(source, 'license2')
    if not identifier then
        return {}
    end

    local key = ('quests:%s'):format(identifier)
    local data = GetResourceKvpString(key)
    local completed = data and json.decode(data) or {}
    return completed
end

local function Roll(chance)
    local roll = math.random(100)
    return roll <= chance
end

local function shuffle(tbl)
    local shuffled = {}
    for i = 1, #tbl do
        shuffled[i] = tbl[i]
    end
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end

local function loadQuest()
    activeQuest = {}
    local keys = {}
    for k in pairs(Config.Quests) do
        keys[#keys + 1] = k
    end

    local shuffledKeys = shuffle(keys)

    for _, k in ipairs(shuffledKeys) do
        local max = tonumber(Config.MaxQuest)
        if max and #activeQuest >= max then
            break
        end
        local quest = Config.Quests[k]
        if Roll(quest.chance) then
            quest["id"] = k
            activeQuest[#activeQuest + 1] = quest
        end
    end

    SetResourceKvp('activeQuest', json.encode(activeQuest))
    resetAllQuests()
    return activeQuest
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    refreshTime = (tonumber(GetResourceKvpString('refreshTime') or '48'))
    activeQuest = json.decode(GetResourceKvpString('activeQuest')) or loadQuest()
    if refreshTime <= 0 then
        refreshTime = Config.RefreshTime * 60 * 60
    end
    print('Resource started, refresh time set to:', refreshTime)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    SetResourceKvp('refreshTime', tostring(refreshTime) or '48')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        refreshTime = refreshTime - 1
        if refreshTime <= 0 then
            refreshTime = Config.RefreshTime * 60 * 60
            resetAllQuests()
            SetResourceKvp('refreshTime', tostring(refreshTime) or '48')
            loadQuest()
        end
    end
end)

lib.callback.register('ec-quests:refreshTime', function(source)
    return refreshTime
end)

RegisterCommand('RefreshQuest', function(source)
    local src = source
    if not src then
        print('Quests have been refreshed.')
        refreshTime = Config.RefreshTime * 60 * 60
        resetAllQuests()
        SetResourceKvp('refreshTime', tostring(refreshTime) or '48')
        loadQuest()
        return
    end
    if IsPlayerAceAllowed(src, "group.admin") or debug.mode then
        refreshTime = Config.RefreshTime * 60 * 60
        resetAllQuests()
        SetResourceKvp('refreshTime', tostring(refreshTime) or '48')
        loadQuest()
        TriggerClientEvent('chat:addMessage', src, {
            args = {'^2[EC-Quests]', 'Quests have been refreshed.'}
        })
    else
        TriggerClientEvent('chat:addMessage', src, {
            args = {'^1[EC-Quests]', 'You do not have permission to use this command.'}
        })
    end
end, false)

local function getXP(source)
    local src = source
    local identifier = GetPlayerIdentifierByType(src, 'license') or GetPlayerIdentifierByType(src, 'license2')
    if not identifier then
        print(('Player %s has no valid license identifier!'):format(src))
        return nil
    end

    local result = MySQL.query.await('SELECT player, level, xp, name FROM enhanced_quests_levels WHERE player = ?',
        {identifier})
    if result[1] then
        return result[1]
    end
    MySQL.insert('INSERT INTO `enhanced_quests_levels` (player, level, xp, name) VALUES (?, ?, ?, ?)',
        {identifier, 1, 10, GetPlayerName(src)}, function(id)

        end)
    return {
        identifier = identifier,
        level = 1,
        xp = 10,
        name = GetPlayerName(src)
    }
end

lib.callback.register('ec-quests:getXP', function(source)
    local player = getXP(source)
    local XpToNext = Config.XpToStart * (Config.XPmultiplier ^ (player.level - 1))
    if player.level == 1 then
        XpToNext = Config.XpToStart
    end
    XpToNext = math.ceil(XpToNext)
    return {player.level, player.xp, XpToNext} or {1, 1, 1}
end)

lib.callback.register('ec-quests:claimReward', function(source, ID)
    local Quest = Config.Quests[ID]

    for _, v in ipairs(Quest.items) do
        if GetItemCount(source, v.name) < v.count then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Quests',
                description = 'Error',
                type = 'error'
            })
            return
        end
    end

    for _, v in ipairs(Quest.items) do
        RemoveItem(source, v.name, v.count)
    end

    local playerXP = getXP(source)
    playerXP.xp = playerXP.xp + Quest.xp
    local restXP = playerXP.xp

    while true do
        local XpToNext = Config.XpToStart * (Config.XPmultiplier ^ (playerXP.level - 1))
        if restXP < XpToNext then
            break
        end
        restXP = restXP - XpToNext
        playerXP.level = playerXP.level + 1
    end

    playerXP.xp = restXP

    markQuestCompleted(source, ID)
    local identifier = GetPlayerIdentifierByType(source, 'license') or GetPlayerIdentifierByType(source, 'license2')
    MySQL.update('UPDATE enhanced_quests_levels SET xp = ?, level = ? WHERE player = ?',
        {restXP > 0 and restXP or playerXP.xp, playerXP.level, identifier}, function(affectedRows)
        end)
    AddItem(source, 'money', Quest.reward * (Config.RewardMultiplierPerLevel ^ (playerXP.level - 1)))
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Quests',
        description = 'Completed',
        type = 'success'
    })
    return true
end)

lib.callback.register('ec-quests:getQuest', function(source)
    local completed = getPlayerCompleted(source)

    local quests = {}
    for _, quest in ipairs(activeQuest) do
        local questCopy = table.clone(quest)
        questCopy.claimed = completed[quest.id] == true
        quests[#quests + 1] = questCopy
    end

    return quests
end)

lib.callback.register('ec-quests:getLeaderboard', function(source)
    leaderboard = MySQL.query.await(
        'SELECT player, level, xp, name FROM enhanced_quests_levels ORDER BY level DESC, xp DESC LIMIT 100') or {}
    return leaderboard
end)

