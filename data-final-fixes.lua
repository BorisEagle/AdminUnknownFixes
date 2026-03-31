
--angel mods
require('prototypes/angels-mods/Data-Final-Fixes')

--aai
require('prototypes/aai/Data-fixes')

--bobs mods
require('prototypes/bobs-mods/Data-Final-Fixes')

--madclown mods
require('prototypes/madclowns-mods/data-fixes')

--msp
if mods['MoreSciencePacks-for1_1'] then
    require('prototypes/msp/Data-fixes')
end

--apm mods
require('prototypes/apm-mods/Data-Final-Fixes')

if mods['SeaBlockMetaPack'] then
    TECHNOLOGY('chemical-science-pack'):remove_prereq('advanced-circuit')
end

----------------------------------------------------
-- MERGED FROM PyPPTBaA: Debug logging
----------------------------------------------------
if settings.startup["debug-techcheck"] and settings.startup["debug-techcheck"].value then
    for _, tech in pairs(data.raw.technology) do
        if not tech.prerequisites then goto continue end
        for _, prereq in pairs(tech.prerequisites) do
            if not data.raw.technology[prereq] then
                log(tech.name .. " is missing prereq: " .. prereq)
                log(serpent.block(tech))
                goto continue
            end
        end
        ::continue::
    end
end

if settings.startup["log-technology"] and data.raw.technology[settings.startup["log-technology"].value] ~= nil then
    log(serpent.block(data.raw.technology[settings.startup["log-technology"].value]))
end

----------------------------------------------------
-- MERGED FROM PyPPTBaA: Global Item Replacer
----------------------------------------------------
require('prototypes/global-item-replacer')

----------------------------------------------------
-- MERGED FROM PyPPTBaA: Ingredient Deduplicator
----------------------------------------------------
require('prototypes/ingredient-deduplicator')

----------------------------------------------------
-- MERGED FROM PyPPTBaA: Icon fixes
----------------------------------------------------
if mods['pyhightech'] and mods['bobelectronics'] then
    if data.raw.item['electronic-circuit'] then
        data.raw.item['electronic-circuit'].icon_size = 64
        data.raw.item['electronic-circuit'].icon = "__pyhightechgraphics__/graphics/icons/circuit-board-1.png"
    end
    if data.raw.item['advanced-circuit'] then
        data.raw.item['advanced-circuit'].icon_size = 64
        data.raw.item['advanced-circuit'].icon = "__pyhightechgraphics__/graphics/icons/circuit-board-2.png"
    end
    if data.raw.item['processing-unit'] then
        data.raw.item['processing-unit'].icon_size = 64
        data.raw.item['processing-unit'].icon = "__pyhightechgraphics__/graphics/icons/circuit-board-3.png"
    end
    if data.raw.item['intelligent-unit'] then
        data.raw.item['intelligent-unit'].icon_size = 64
        data.raw.item['intelligent-unit'].icon = "__pyhightechgraphics__/graphics/icons/intelligent-unit.png"
    end
end

----------------------------------------------------
-- MERGED FROM bobsmodules4py: Bob's Modules compat
----------------------------------------------------
if mods['bobmodules'] then
    require('prototypes/bobs-mods/bobmodules-compat')
end
