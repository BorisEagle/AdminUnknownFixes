-- Yuoki legacy compatibility cleanup.
--
-- Old Yuoki/Bob bridge recipes can reference Bob ore item names that no longer
-- exist in current Bob/Py/Angel stacks. Modern Yuoki uses plain ore names in
-- yi-bobores.lua, so prefer rewriting old bob-* item references to those names.
-- If no replacement exists, disable the recipe so prototype validation can pass.

local ore_name_map = {
    ["bob-bauxite-ore"] = "bauxite-ore",
    ["bob-cobalt-ore"] = "cobalt-ore",
    ["bob-gem-ore"] = "gem-ore",
    ["bob-gold-ore"] = "gold-ore",
    ["bob-lead-ore"] = "lead-ore",
    ["bob-nickel-ore"] = "nickel-ore",
    ["bob-quartz"] = "quartz",
    ["bob-quartz-ore"] = "quartz",
    ["bob-rutile-ore"] = "rutile-ore",
    ["bob-silver-ore"] = "silver-ore",
    ["bob-tin-ore"] = "tin-ore",
    ["bob-tungsten-ore"] = "tungsten-ore",
    ["bob-zinc-ore"] = "zinc-ore",
}

local function item_exists(name)
    return name and data.raw.item and data.raw.item[name] ~= nil
end

local function set_entry_name(entry, new_name)
    if type(entry) ~= "table" then return end
    if entry.name then
        entry.name = new_name
    elseif entry[1] then
        entry[1] = new_name
    end
end

local function rewrite_entry(entry)
    if type(entry) ~= "table" then return false, false, nil end
    local kind = entry.type or "item"
    if kind ~= "item" then return false, false, nil end

    local old_name = entry.name or entry[1]
    local new_name = ore_name_map[old_name]
    if not new_name then return false, false, nil end

    if item_exists(new_name) then
        set_entry_name(entry, new_name)
        return true, false, old_name .. " -> " .. new_name
    end

    return false, true, old_name
end

local function rewrite_list(list)
    local changed = false
    for _, entry in pairs(list or {}) do
        local entry_changed, missing_target, note = rewrite_entry(entry)
        if missing_target then return changed, true, note end
        if entry_changed then
            changed = true
            log("[AdminUnknownFixes] Rewrote Yuoki legacy ore reference " .. tostring(note))
        end
    end
    return changed, false, nil
end

local function rewrite_variant(recipe)
    if not recipe then return false, false, nil end
    local changed = false

    if recipe.result and ore_name_map[recipe.result] then
        local new_name = ore_name_map[recipe.result]
        if item_exists(new_name) then
            log("[AdminUnknownFixes] Rewrote Yuoki legacy recipe result " .. recipe.result .. " -> " .. new_name)
            recipe.result = new_name
            changed = true
        else
            return changed, true, recipe.result
        end
    end

    local list_changed, missing_target, note = rewrite_list(recipe.ingredients)
    if missing_target then return changed, true, note end
    changed = changed or list_changed

    list_changed, missing_target, note = rewrite_list(recipe.results)
    if missing_target then return changed, true, note end
    changed = changed or list_changed

    return changed, false, nil
end

local function disable_unlock(recipe_name)
    for _, tech in pairs(data.raw.technology or {}) do
        for i = #(tech.effects or {}), 1, -1 do
            local effect = tech.effects[i]
            if effect and effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                table.remove(tech.effects, i)
            end
        end
    end
end

local function recipe_looks_like_yuoki_bridge(recipe_name)
    if type(recipe_name) ~= "string" then return false end
    return recipe_name:sub(1, 5) == "y-ac-"
end

for recipe_name, recipe in pairs(data.raw.recipe or {}) do
    if recipe_looks_like_yuoki_bridge(recipe_name) then
        local changed, missing_target, note = rewrite_variant(recipe)
        if not missing_target then
            local normal_changed, normal_missing, normal_note = rewrite_variant(recipe.normal)
            changed = changed or normal_changed
            missing_target = normal_missing
            note = normal_note
        end
        if not missing_target then
            local expensive_changed, expensive_missing, expensive_note = rewrite_variant(recipe.expensive)
            changed = changed or expensive_changed
            missing_target = expensive_missing
            note = expensive_note
        end

        if missing_target then
            log("[AdminUnknownFixes] Disabling Yuoki bridge recipe '" .. tostring(recipe_name) .. "' because replacement for '" .. tostring(note) .. "' is missing")
            data.raw.recipe[recipe_name] = nil
            disable_unlock(recipe_name)
        elseif changed then
            log("[AdminUnknownFixes] Updated Yuoki bridge recipe '" .. tostring(recipe_name) .. "' to current ore names")
        end
    end
end
