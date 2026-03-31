-- Ingredient Deduplicator (merged from PyPPTBaA)
-- Removes duplicate ingredients from recipes after global item replacement

for _, recipe in pairs(data.raw.recipe) do
    local inglist = {}
    if recipe.ingredients ~= nil then
        for idx, ing in pairs(recipe.ingredients) do
            local name = ing.name
            if name ~= nil then
                if data.raw.item[name] or data.raw.fluid[name] or data.raw.module[name] or data.raw.tool[name] or data.raw.ammo[name] then
                    if not inglist[name] then
                        inglist[name] = true
                    else
                        data.raw.recipe[recipe.name].ingredients[idx] = nil
                    end
                else
                    data.raw.recipe[recipe.name].ingredients[idx] = nil
                end
            end
        end
    end
end
