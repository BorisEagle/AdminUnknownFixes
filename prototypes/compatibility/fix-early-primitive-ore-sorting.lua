-- Early-game primitive crushed ore sorting for Bob + Angel + Py + Yuoki.
--
-- In this stack, the Py burner-start objective can require iron plates before
-- Steam power. Angel mixed ores can be hand-crushed, but the proper crushed ore
-- sorting chain may not yet be practical, and nearby iron-rock reserves can be
-- gated behind Open Pit mining. This leaves the player with crushed starter ore
-- but no realistic way to obtain the first small amount of smeltable ore.
--
-- Add deliberately poor hand-sorting recipes for the same initial crushed ores
-- handled by Tier 1 ore sorting. These are not meant to replace ore sorting;
-- they are a miserable bootstrap route: mostly slag, sometimes usable ore.

local recipes = {
    {
        name = 'auf-primitive-stiratite-sorting',
        ingredient = 'angels-ore1-crushed',
        results = {
            {type = 'item', name = 'angels-slag', amount = 1},
            {type = 'item', name = 'iron-ore', amount = 1, probability = 0.25},
            {type = 'item', name = 'copper-ore', amount = 1, probability = 0.10},
        },
    },
    {
        name = 'auf-primitive-saphirite-sorting',
        ingredient = 'angels-ore2-crushed',
        results = {
            {type = 'item', name = 'angels-slag', amount = 1},
            {type = 'item', name = 'iron-ore', amount = 1, probability = 0.25},
            {type = 'item', name = 'copper-ore', amount = 1, probability = 0.10},
        },
    },
    {
        name = 'auf-primitive-jivolite-sorting',
        ingredient = 'angels-ore3-crushed',
        results = {
            {type = 'item', name = 'angels-slag', amount = 1},
            {type = 'item', name = 'iron-ore', amount = 1, probability = 0.20},
            {type = 'item', name = 'copper-ore', amount = 1, probability = 0.12},
        },
    },
    {
        name = 'auf-primitive-crotinnium-sorting',
        ingredient = 'angels-ore4-crushed',
        results = {
            {type = 'item', name = 'angels-slag', amount = 1},
            {type = 'item', name = 'iron-ore', amount = 1, probability = 0.20},
            {type = 'item', name = 'copper-ore', amount = 1, probability = 0.12},
        },
    },
    {
        name = 'auf-primitive-rubyte-sorting',
        ingredient = 'angels-ore5-crushed',
        results = {
            {type = 'item', name = 'angels-slag', amount = 1},
            {type = 'item', name = 'bob-lead-ore', amount = 1, probability = 0.18},
            {type = 'item', name = 'bob-nickel-ore', amount = 1, probability = 0.08},
        },
    },
    {
        name = 'auf-primitive-bobmonium-sorting',
        ingredient = 'angels-ore6-crushed',
        results = {
            {type = 'item', name = 'angels-slag', amount = 1},
            {type = 'item', name = 'bob-tin-ore', amount = 1, probability = 0.18},
            {type = 'item', name = 'bob-quartz', amount = 1, probability = 0.08},
        },
    },
}

local function item_exists(name)
    return data.raw.item and data.raw.item[name]
end

local function recipe_exists(name)
    return data.raw.recipe and data.raw.recipe[name]
end

local function all_results_exist(results)
    for _, result in pairs(results) do
        if not item_exists(result.name) then
            return false
        end
    end
    return true
end

local to_add = {}

for _, spec in pairs(recipes) do
    if item_exists(spec.ingredient) and all_results_exist(spec.results) and not recipe_exists(spec.name) then
        to_add[#to_add + 1] = {
            type = 'recipe',
            name = spec.name,
            enabled = true,
            category = 'crafting',
            energy_required = 4,
            ingredients = {
                {type = 'item', name = spec.ingredient, amount = 5},
            },
            results = spec.results,
            allow_productivity = false,
            always_show_products = true,
            allow_decomposition = false,
        }
    end
end

if #to_add > 0 then
    data:extend(to_add)
end
