-- Normalize recipe ingredient/result entries before other mods' data-updates run,
-- and expose helpers so later wrappers can normalize again when recipes are
-- created or modified during data-updates.
--
-- Angel's override executor expects recipe ingredients/results to be tables with
-- a .name field. Some compatibility paths can leave old short-form entries like
-- {"iron-plate", 2}, or otherwise malformed entries, which then crash Angel with:
--   __angelsrefining__/prototypes/override-functions.lua:730: table index is nil

local raw_pairs = rawget(_G, "pairs")

local function normalize_entry(entry, recipe_name, field_name)
    if not entry then
        return nil
    end

    if type(entry) ~= "table" then
        log("AdminUnknownFixes: dropped non-table recipe entry in " .. tostring(recipe_name) .. "." .. tostring(field_name) .. ": " .. serpent.block(entry))
        return nil
    end

    -- Old short form can be {"iron-plate", 2}; removal markers are often
    -- {"iron-plate", 0}, so do not require entry[2] to be truthy in spirit.
    if entry[1] and not entry.name then
        local normalized = {
            type = entry.type or "item",
            name = entry[1],
            amount = entry[2] or entry.amount or 0
        }

        if entry.probability ~= nil then normalized.probability = entry.probability end
        if entry.amount_min ~= nil then normalized.amount_min = entry.amount_min end
        if entry.amount_max ~= nil then normalized.amount_max = entry.amount_max end
        if entry.catalyst_amount ~= nil then normalized.catalyst_amount = entry.catalyst_amount end
        if entry.ignored_by_productivity ~= nil then normalized.ignored_by_productivity = entry.ignored_by_productivity end
        if entry.ignored_by_stats ~= nil then normalized.ignored_by_stats = entry.ignored_by_stats end
        if entry.extra_count_fraction ~= nil then normalized.extra_count_fraction = entry.extra_count_fraction end
        if entry.percent_spoiled ~= nil then normalized.percent_spoiled = entry.percent_spoiled end
        if entry.temperature ~= nil then normalized.temperature = entry.temperature end
        if entry.minimum_temperature ~= nil then normalized.minimum_temperature = entry.minimum_temperature end
        if entry.maximum_temperature ~= nil then normalized.maximum_temperature = entry.maximum_temperature end
        if entry.fluidbox_index ~= nil then normalized.fluidbox_index = entry.fluidbox_index end

        log("AdminUnknownFixes: normalized short-form recipe entry in " .. tostring(recipe_name) .. "." .. tostring(field_name) .. ": " .. tostring(entry[1]))
        return normalized
    end

    if entry.name then
        if not entry.type then
            entry.type = "item"
        end
        return entry
    end

    log("AdminUnknownFixes: dropped malformed recipe entry in " .. tostring(recipe_name) .. "." .. tostring(field_name) .. ": " .. serpent.block(entry))
    return nil
end

local function normalize_list(list, recipe_name, field_name)
    if not list then
        return list
    end

    local normalized = {}

    -- Use the original pairs if available to avoid recursion through our later
    -- global pairs wrapper.
    for _, entry in (raw_pairs or pairs)(list) do
        local fixed = normalize_entry(entry, recipe_name, field_name)
        if fixed then
            table.insert(normalized, fixed)
        end
    end

    return normalized
end

local function normalize_recipe_variant(recipe, recipe_name)
    if not recipe then
        return
    end

    recipe.ingredients = normalize_list(recipe.ingredients, recipe_name, "ingredients")
    recipe.results = normalize_list(recipe.results, recipe_name, "results")
end

local function normalize_recipe(recipe, recipe_name)
    if not recipe then
        return
    end

    normalize_recipe_variant(recipe, recipe_name)
    normalize_recipe_variant(recipe.normal, recipe_name .. ".normal")
    normalize_recipe_variant(recipe.expensive, recipe_name .. ".expensive")
end

local function normalize_all_recipes()
    for recipe_name, recipe in next, data.raw.recipe or {}, nil do
        normalize_recipe(recipe, recipe_name)
    end
end

_G.__auf_normalize_recipe = normalize_recipe
_G.__auf_normalize_all_recipes = normalize_all_recipes

normalize_all_recipes()

log("AdminUnknownFixes: recipe entry normalization completed")
