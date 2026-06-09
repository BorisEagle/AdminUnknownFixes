-- Drop recipes that reference missing item/fluid prototypes before prototype validation.
-- Needed for legacy Yuoki/Bob recipe names such as bob-tungsten-ore.

local removed = {}

local function exists(kind, name)
    if not name then return false end
    if kind == "fluid" then
        return data.raw.fluid and data.raw.fluid[name]
    end
    return data.raw.item and data.raw.item[name]
end

local function bad_entry(e)
    if type(e) ~= "table" then return false end
    local kind = e.type or "item"
    if kind ~= "item" and kind ~= "fluid" then return false end
    local name = e.name or e[1]
    if exists(kind, name) then return false end
    return true, kind, name
end

local function bad_list(list)
    for _, e in pairs(list or {}) do
        local bad, kind, name = bad_entry(e)
        if bad then return true, kind, name end
    end
    return false
end

local function bad_variant(r)
    if not r then return false end
    if r.result and not exists("item", r.result) then return true, "item", r.result end

    local bad, kind, name = bad_list(r.ingredients)
    if bad then return true, kind, name end

    bad, kind, name = bad_list(r.results)
    if bad then return true, kind, name end

    return false
end

local function bad_recipe(r)
    local bad, kind, name = bad_variant(r)
    if bad then return true, kind, name end
    bad, kind, name = bad_variant(r.normal)
    if bad then return true, kind, name end
    bad, kind, name = bad_variant(r.expensive)
    if bad then return true, kind, name end
    return false
end

for recipe_name, recipe in pairs(data.raw.recipe or {}) do
    local bad, kind, name = bad_recipe(recipe)
    if bad then
        log("[AdminUnknownFixes] Deleting invalid recipe '" .. tostring(recipe_name) .. "' referencing missing " .. tostring(kind) .. " '" .. tostring(name) .. "'")
        data.raw.recipe[recipe_name] = nil
        removed[recipe_name] = true
    end
end

for tech_name, tech in pairs(data.raw.technology or {}) do
    for i = #(tech.effects or {}), 1, -1 do
        local effect = tech.effects[i]
        if effect and effect.type == "unlock-recipe" and removed[effect.recipe] then
            log("[AdminUnknownFixes] Removing unlock of deleted recipe '" .. tostring(effect.recipe) .. "' from technology '" .. tostring(tech_name) .. "'")
            table.remove(tech.effects, i)
        end
    end
end
