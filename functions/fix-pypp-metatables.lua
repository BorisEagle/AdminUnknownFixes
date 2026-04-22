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
--
-- Observed offenders (Factorio 2.0 / current Py 3.x stack):
--   - __pypetroleumhandling__/data-updates.lua:1  (py.global_item_replacer)
--   - __pyalienlife__/data-updates.lua:186        (direct for-pairs loop)
--
-- Protection layers:
--   1. Reapply metatables at the end of our data.lua (catches anything added
--      during the data stage up to that point; our data.lua runs last due to
--      our dependencies on all the major py/angels/bobs mods).
--   2. Wrap the global `pairs` so that any iteration of `data.raw.recipe` or
--      `data.raw.technology` transparently reapplies the metatable to any
--      prototype that is missing it before returning the iterator. This is the
--      key fix for mods like pyalienlife that load between pypostprocessing and
--      us and iterate data.raw.recipe directly in their data-updates.
--   3. Monkey-patch pypp's global replacer helpers as an extra belt-and-braces
--      layer.
--
-- IMPORTANT: Capture the original `pairs` via rawget(_G, "pairs") and use it
-- inside our helpers. If the helpers called the wrapped `pairs`, they would
-- recurse into themselves and hang Factorio at load.

local raw_pairs = rawget(_G, "pairs")

-- Iterate using `next` directly to bypass any wrapped pairs() and avoid the
-- factory-vs-iterator mixup (pairs returns next,t,nil; it is not itself a
-- stateful iterator that can be passed as the first value of a generic for).
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
--     self-heals. This handles mods that iterate directly (e.g. pyalienlife)
--     and run before our data-updates stage. Install at most once.
if not _G.__auf_pairs_wrapped then
    _G.__auf_pairs_wrapped = true
    ---@diagnostic disable-next-line: duplicate-set-field
    function _G.pairs(t)
        if t == data.raw.recipe then
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
        reapply_metatables(data.raw.recipe, "replace_ingredient")
        return original(old, new, blackrecipe)
    end
end

if py and type(py.global_fluid_replacer) == "function" then
    local original = py.global_fluid_replacer
    py.global_fluid_replacer = function(old, new, blackrecipe)
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
