-- Angel's Petrochem replaces vanilla sulfur-processing with angels-sulfur-processing-1,
-- but many technologies (explosives, battery, ...) can still list "sulfur-processing"
-- as a prerequisite. Once that tech is hidden, pypostprocessing data-final-fixes.lua
-- errors: "<tech> has hidden prerequisite sulfur-processing".
--
-- Remap every technology's prerequisites in data-updates (after Angel's data-updates
-- round). Optionally temporarily unhide sulfur-processing if anything still references
-- it while hidden (pypp load order). restore-sulfur-processing-hidden.lua restores hidden.

local sulfur = data.raw.technology["sulfur-processing"]
local angels_name = "angels-sulfur-processing-1"
local has_angels_replacement = mods["angelspetrochem"] and data.raw.technology[angels_name]

local function tech_lists_sulfur_processing(tech)
    if not tech or not tech.prerequisites then return false end
    for _, pre in pairs(tech.prerequisites) do
        if pre == "sulfur-processing" then
            return true
        end
    end
    return false
end

for _, tech in pairs(data.raw.technology) do
    if not tech.prerequisites then goto continue end
    if not has_angels_replacement then goto continue end
    if not tech_lists_sulfur_processing(tech) then goto continue end

    local new_pre = {}
    local seen = {}
    for _, pre in pairs(tech.prerequisites) do
        if type(pre) ~= "string" then
            table.insert(new_pre, pre)
        else
            local p = (pre == "sulfur-processing") and angels_name or pre
            if not seen[p] then
                seen[p] = true
                table.insert(new_pre, p)
            end
        end
    end
    tech.prerequisites = new_pre
    ::continue::
end

if sulfur and sulfur.hidden then
    local any_ref = false
    for _, tech in pairs(data.raw.technology) do
        if tech_lists_sulfur_processing(tech) then
            any_ref = true
            break
        end
    end
    if any_ref then
        _G.__auf_sulfur_processing_restore = { hidden = true }
        sulfur.hidden = false
    end
end
