-- Normalize entries passed into Angel's OV recipe patch queue.
--
-- Some Angel release builds still crash in override-functions.lua when recipe
-- patch entries are old short-form tables such as {"iron-plate", 0}. Current
-- upstream Angels code normalizes those in adjust_subtable, but this bridge needs
-- to survive installed releases too.
--
-- We wrap the public OV helpers after Angel has created angelsmods.functions.OV
-- and before later data-updates code queues recipe patches.

local OV = angelsmods and angelsmods.functions and angelsmods.functions.OV

if not OV or OV.__auf_entry_normalization_wrapped then
    return
end

OV.__auf_entry_normalization_wrapped = true

local function copy_extra_fields(src, dst)
    for k, v in pairs(src) do
        if k ~= 1 and k ~= 2 and k ~= "name" and k ~= "amount" and k ~= "type" then
            dst[k] = v
        end
    end
end

local function normalize_entry(entry, default_type)
    if entry == nil then
        return entry
    end

    if type(entry) == "string" then
        return { type = default_type or "item", name = entry, amount = 0 }
    end

    if type(entry) ~= "table" then
        return entry
    end

    if entry.name then
        if not entry.type then
            entry.type = default_type or "item"
        end
        return entry
    end

    if entry[1] then
        local normalized = {
            type = entry.type or default_type or "item",
            name = entry[1],
            amount = entry[2] or entry.amount or 0
        }
        copy_extra_fields(entry, normalized)
        return normalized
    end

    log("AdminUnknownFixes: Angel OV wrapper saw malformed recipe entry: " .. serpent.block(entry))
    return entry
end

local function normalize_recipe_patch(patch)
    if type(patch) ~= "table" then
        return patch
    end

    if patch.ingredients then
        for i, entry in pairs(patch.ingredients) do
            patch.ingredients[i] = normalize_entry(entry, "item")
        end
    end

    if patch.results then
        for i, entry in pairs(patch.results) do
            patch.results[i] = normalize_entry(entry, "item")
        end
    end

    if patch.normal then
        normalize_recipe_patch(patch.normal)
    end

    if patch.expensive then
        normalize_recipe_patch(patch.expensive)
    end

    return patch
end

local function wrap_entry_function(name)
    if type(OV[name]) ~= "function" then
        return
    end

    local original = OV[name]
    OV[name] = function(recipe, entry)
        return original(recipe, normalize_entry(entry, "item"))
    end
end

for _, name in pairs({
    "modify_input",
    "modify_normal_input",
    "modify_hard_input",
    "modify_output",
    "modify_normal_output",
    "modify_hard_output"
}) do
    wrap_entry_function(name)
end

if type(OV.patch_recipes) == "function" then
    local original_patch_recipes = OV.patch_recipes
    OV.patch_recipes = function(patch_list)
        if type(patch_list) == "table" then
            for _, patch in pairs(patch_list) do
                normalize_recipe_patch(patch)
            end
        end
        return original_patch_recipes(patch_list)
    end
end

log("AdminUnknownFixes: Angel OV recipe entry normalization wrapper installed")
