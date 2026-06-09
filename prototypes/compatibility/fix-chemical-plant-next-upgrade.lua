-- Factorio 2.0: any entity with next_upgrade cannot mine to an item product
-- with the hidden flag set. Py/Bob/Angel replacement passes may hide placed-item
-- products late in data-final-fixes, which makes vanilla/upgradable entities fail
-- prototype validation.
--
-- Clear next_upgrade for affected entities instead of unhiding items. The upgrade
-- chain is less important than keeping the prototype graph valid, and hidden
-- replacement items usually mean the old upgrade path is no longer meaningful.

local function item_is_hidden(name)
    if not name then return false end
    local item = data.raw.item and data.raw.item[name]
    return item and item.hidden == true
end

local function minable_has_hidden_item_product(entity)
    local minable = entity and entity.minable
    if not minable then return false end

    if item_is_hidden(minable.result) then
        return true
    end

    for _, product in pairs(minable.results or {}) do
        local product_type = product.type or "item"
        if product_type == "item" and item_is_hidden(product.name or product[1]) then
            return true
        end
    end

    return false
end

for prototype_type, prototypes in pairs(data.raw) do
    for name, entity in pairs(prototypes) do
        if type(entity) == "table" and entity.next_upgrade and minable_has_hidden_item_product(entity) then
            log("[AdminUnknownFixes] Clearing next_upgrade on " .. tostring(prototype_type) .. " '" .. tostring(name) .. "' because its mining result item is hidden")
            entity.next_upgrade = nil
        end
    end
end
