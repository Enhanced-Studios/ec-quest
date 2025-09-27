if GetResourceState('qb-inventory') ~= "started" then
    return
end

local inv = exports['qb-inventory']

GetItemCount = function(source, item)
    local count = inv:GetItemCount(source, item)
    return count
end

AddItem = function(source, item, count)
    inv:AddItem(source, item, count, false, false, 'ec-quest')
end

RemoveItem = function(source, item, count)
    inv:RemoveItem(source, item, count, false, 'ec-quest')
end
