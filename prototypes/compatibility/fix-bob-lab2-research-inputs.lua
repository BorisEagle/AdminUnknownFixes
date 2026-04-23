-- Factorio 2.0: every technology's research ingredients must be a subset of at least one lab's inputs.
-- With Py + Bob, bob-lab-2 often gets Py packs added but not every Bob gold / colored-alien pack used by
-- warfare techs (e.g. bob-acid-bullets: automation + bob-science-pack-gold + bob-alien-science-pack-purple).

local function ensure_lab_input(lab, pack_name)
    if not lab or not lab.inputs or not pack_name or type(pack_name) ~= "string" then
        return
    end
    for _, existing in pairs(lab.inputs) do
        if existing == pack_name then
            return
        end
    end
    table.insert(lab.inputs, pack_name)
end

local function ensure_lab_inputs_for_ingredient_list(lab, ingredients)
    if not lab or not ingredients then
        return
    end
    for _, ing in pairs(ingredients) do
        local pack = ing[1] or (ing.type == "item" and ing.name)
        if pack and type(pack) == "string" then
            ensure_lab_input(lab, pack)
        end
    end
end

local lab = data.raw.lab and data.raw.lab["bob-lab-2"]
if not lab or not lab.inputs then
    return
end

for _, tech in pairs(data.raw.technology) do
    local unit = tech.unit
    local ingredients = unit and unit.ingredients
    if ingredients then
        local has_gold = false
        local has_colored_alien = false
        for _, ing in pairs(ingredients) do
            local n = ing[1] or ing.name
            if n == "bob-science-pack-gold" then
                has_gold = true
            end
            if type(n) == "string" and n:find("^bob%-alien%-science%-pack") then
                has_colored_alien = true
            end
        end
        if has_gold and has_colored_alien then
            ensure_lab_inputs_for_ingredient_list(lab, ingredients)
        end
    end
end
