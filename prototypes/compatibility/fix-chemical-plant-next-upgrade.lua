-- Factorio 2.0: next_upgrade is stricter than old compatibility code assumes.
--
-- Validation failures seen in Bob/Angel/Py combinations:
--   * an entity with next_upgrade mines to a hidden item product
--   * next_upgrade target has a different bounding box
--
-- Clear invalid next_upgrade links instead of unhiding items or reshaping entity
-- boxes. The upgrade chain is less important than keeping the prototype graph
-- valid, and these old upgrade paths are often no longer meaningful after Py/Bob/
-- Angel replacement passes.

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

local function same_number(a, b)
    return tonumber(a) == tonumber(b)
end

local function same_position(a, b)
    if not a and not b then return true end
    if not a or not b then return false end
    return same_number(a[1], b[1]) and same_number(a[2], b[2])
end

local function same_box(a, b)
    if not a and not b then return true end
    if not a or not b then return false end
    return same_position(a[1], b[1]) and same_position(a[2], b[2])
end

local function next_upgrade_target(entity)
    if not entity or not entity.next_upgrade then return nil end
    -- Factorio next_upgrade points to an entity prototype with the same prototype
    -- type, not to the item.
    local same_type = entity.type and data.raw[entity.type]
    if same_type and same_type[entity.next_upgrade] then
        return same_type[entity.next_upgrade]
    end

    -- Fallback for any prototype table whose .type is missing or unusual.
    for _, prototypes in pairs(data.raw) do
        if prototypes[entity.next_upgrade] then
            return prototypes[entity.next_upgrade]
        end
    end

    return nil
end

local function next_upgrade_has_incompatible_boxes(entity)
    local target = next_upgrade_target(entity)
    if not target then
        return true
    end

    return not same_box(entity.collision_box, target.collision_box)
        or not same_box(entity.selection_box, target.selection_box)
end

for prototype_type, prototypes in pairs(data.raw) do
    for name, entity in pairs(prototypes) do
        if type(entity) == "table" and entity.next_upgrade then
            if minable_has_hidden_item_product(entity) then
                log("[AdminUnknownFixes] Clearing next_upgrade on " .. tostring(prototype_type) .. " '" .. tostring(name) .. "' because its mining result item is hidden")
                entity.next_upgrade = nil
            elseif next_upgrade_has_incompatible_boxes(entity) then
                log("[AdminUnknownFixes] Clearing next_upgrade on " .. tostring(prototype_type) .. " '" .. tostring(name) .. "' because target is missing or has incompatible bounding boxes")
                entity.next_upgrade = nil
            end
        end
    end
end
