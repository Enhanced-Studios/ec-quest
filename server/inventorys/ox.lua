if GetResourceState('ox_inventory') ~= "started" then
    return
end

local inv = exports.ox_inventory

GetItemCount = function(source, item)
    local count = inv:GetItem(source, item, nil, true)
    return count
end

AddItem = function(source, item, count)
    inv:AddItem(source, item, count)
end

RemoveItem = function(source, item, count)
    inv:RemoveItem(source, item, count)
end
