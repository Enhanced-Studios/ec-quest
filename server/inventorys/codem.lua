if GetResourceState('codem-inventory') ~= "started" then
    return
end

local inv = exports['codem-inventory']

GetItemCount = function(source, item)
    local count = inv:GetItemsTotalAmount(source, item)
    return count
end

AddItem = function(source, item, count)
    inv:AddItem(source, item, count)
end

RemoveItem = function(source, item, count)
    inv:RemoveItem(source, item, count)
end
