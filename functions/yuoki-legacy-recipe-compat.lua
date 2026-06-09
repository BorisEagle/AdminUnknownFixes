-- Yuoki legacy compatibility cleanup.
--
-- Some Yuoki bridge recipes still point at old Bob item names that are not
-- present in current Bob/Py/Angel setups. Factorio validates recipe references
-- before the game can start, so known invalid bridge recipes must be disabled
-- early in data.lua.

local recipes = {
    ["y-ac-uc2bob-tungsten-ore"] = true,
}

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

for recipe_name in pairs(recipes) do
    if data.raw.recipe and data.raw.recipe[recipe_name] then
        log("[AdminUnknownFixes] Disabling invalid Yuoki bridge recipe '" .. recipe_name .. "'")
        data.raw.recipe[recipe_name] = nil
        disable_unlock(recipe_name)
    end
end
