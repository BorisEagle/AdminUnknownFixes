-- Repair missing pypostprocessing metatables on prototypes.
--
-- pypostprocessing's lib/metas/metas.lua iterates data.raw once (during its own
-- data stage load) to attach metatables that expose helper methods such as
-- recipe:replace_ingredient(), recipe:add_ingredient(), technology:add_prereq(),
-- etc. It also wraps data.extend so new prototypes added via data:extend get the
-- metatable automatically.
--
-- However, any mod that adds prototypes via direct assignment
-- (e.g. data.raw.recipe["foo"] = {...}) bypasses data.extend and never gets the
-- metatable. Later code that iterates data.raw.recipe and calls
-- recipe:replace_ingredient(...) then crashes with:
--     "attempt to call method 'replace_ingredient' (a nil value)"

local raw_pairs = rawget(_G, "pairs")

-- Iterate using `next` directly to bypass any wrapped pairs() and avoid recursion.
local function find_template_meta(raw_table, method_probe)
    for _, prototype in next, raw_table, nil do
        local mt = getmetatable(prototype)
        if mt and type(mt.__index) == "table" and mt.__index[method_probe] then
            return mt
        end
    end
    return nil
end

local function reapply_metatables(raw_table, method_probe)
    local template_meta = find_template_meta(raw_table, method_probe)
    if not template_meta then return end
    for _, prototype in next, raw_table, nil do
        local mt = getmetatable(prototype)
        if not mt or type(mt.__index) ~= "table" or not mt.__index[method_probe] then
            setmetatable(prototype, template_meta)
        end
    end
end

-- (1) Eager pass at end of data stage.
reapply_metatables(data.raw.recipe, "replace_ingredient")
reapply_metatables(data.raw.technology, "add_prereq")

-- (2) Wrap global pairs so iteration of data.raw.recipe / data.raw.technology
--     self-heals. Also normalize recipe entries immediately before consumers
--     like Angel's OV.execute iterate all recipes during data-updates.
--     Install at most once.
if not _G.__auf_pairs_wrapped then
    _G.__auf_pairs_wrapped = true
    ---@diagnostic disable-next-line: duplicate-set-field
    function _G.pairs(t)
        if t == data.raw.recipe then
            if type(_G.__auf_normalize_all_recipes) == "function" then
                _G.__auf_normalize_all_recipes()
            end
            reapply_metatables(t, "replace_ingredient")
        elseif t == data.raw.technology then
            reapply_metatables(t, "add_prereq")
        end
        return next, t, nil
    end
end

-- (3) Wrap py's global replacer helpers as belt-and-braces (cheap no-op if the
--     pairs wrapper already fixed things).
if py and type(py.global_item_replacer) == "function" then
    local original = py.global_item_replacer
    py.global_item_replacer = function(old, new, blackrecipe)
        if type(_G.__auf_normalize_all_recipes) == "function" then
            _G.__auf_normalize_all_recipes()
        end
        reapply_metatables(data.raw.recipe, "replace_ingredient")
        return original(old, new, blackrecipe)
    end
end

if py and type(py.global_fluid_replacer) == "function" then
    local original = py.global_fluid_replacer
    py.global_fluid_replacer = function(old, new, blackrecipe)
        if type(_G.__auf_normalize_all_recipes) == "function" then
            _G.__auf_normalize_all_recipes()
        end
        reapply_metatables(data.raw.recipe, "replace_ingredient")
        return original(old, new, blackrecipe)
    end
end

if py and type(py.global_prerequisite_replacer) == "function" then
    local original = py.global_prerequisite_replacer
    py.global_prerequisite_replacer = function(old, new)
        reapply_metatables(data.raw.technology, "add_prereq")
        return original(old, new)
    end
end
