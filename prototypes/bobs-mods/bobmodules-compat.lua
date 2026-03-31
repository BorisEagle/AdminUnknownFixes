-- Bob's Modules 4 Pyanodons compatibility (merged from bobsmodules4py)
-- Integrates Bob's modules into the Py suite

-- Tech fixes
TECHNOLOGY('module-merging'):remove_prereq('modules'):add_prereq('advanced-circuit')
TECHNOLOGY('effect-transmission-2'):remove_prereq('advanced-electronics-2')
TECHNOLOGY('pollution-clean-module-1'):remove_prereq('modules'):add_prereq('basic-electronics')
TECHNOLOGY('pollution-create-module-1'):remove_prereq('modules'):add_prereq('basic-electronics')
TECHNOLOGY('pollution-clean-module-3'):remove_prereq('advanced-electronics-2')
TECHNOLOGY('pollution-create-module-3'):remove_prereq('advanced-electronics-2')
TECHNOLOGY('speed-module'):remove_prereq('machine-components-mk02'):add_prereq('basic-electronics')
TECHNOLOGY('productivity-module'):remove_prereq('machine-components-mk02'):add_prereq('basic-electronics')
TECHNOLOGY('efficiency-module'):remove_prereq('machine-components-mk02'):add_prereq('basic-electronics')
TECHNOLOGY('speed-module-2'):remove_prereq('advanced-circuit'):remove_prereq('machine-components-mk03')
TECHNOLOGY('efficiency-module-2'):remove_prereq('advanced-circuit'):remove_prereq('machine-components-mk03')
TECHNOLOGY('productivity-module-2'):remove_prereq('advanced-circuit'):remove_prereq('machine-components-mk03')
TECHNOLOGY('speed-module-3'):remove_prereq('nano-tech'):remove_prereq('machine-components-mk04')
TECHNOLOGY('efficiency-module-3'):remove_prereq('nano-tech'):remove_prereq('machine-components-mk04')
TECHNOLOGY('productivity-module-3'):remove_prereq('nano-tech'):remove_prereq('machine-components-mk04')
bobmods.lib.tech.add_recipe_unlock("basic-electronics", "lab-module")

-- Module tech costs: scale down since ModulesLab was removed in 2.0
bobmods.lib.tech.remove_science_pack("speed-module-2", "chemical-science-pack")
bobmods.lib.tech.remove_science_pack("speed-module-3", "production-science-pack")
bobmods.lib.tech.set_science_pack_count("speed-module-2", 100)
bobmods.lib.tech.set_science_pack_count("speed-module-3", 150)
bobmods.lib.tech.remove_science_pack("efficiency-module-2", "chemical-science-pack")
bobmods.lib.tech.remove_science_pack("efficiency-module-3", "production-science-pack")
bobmods.lib.tech.set_science_pack_count("efficiency-module-2", 100)
bobmods.lib.tech.set_science_pack_count("efficiency-module-3", 150)
bobmods.lib.tech.remove_science_pack("productivity-module-2", "chemical-science-pack")
bobmods.lib.tech.remove_science_pack("productivity-module-3", "production-science-pack")
bobmods.lib.tech.set_science_pack_count("productivity-module-2", 100)
bobmods.lib.tech.set_science_pack_count("productivity-module-3", 150)

-- Module effects use Bob's scaling
if bobmods.modules then
    data.raw["module"]["speed-module"].effect = {
        speed = { bonus = bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus + 0.001 },
        consumption = { bonus = bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty + 0.001 },
    }
    data.raw["module"]["speed-module-2"].effect = {
        speed = { bonus = 2 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus + 0.001 },
        consumption = { bonus = 2 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty + 0.001 },
    }
    data.raw["module"]["speed-module-3"].effect = {
        speed = { bonus = 3 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus + 0.001 },
        consumption = { bonus = 3 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty + 0.001 },
    }
    data.raw["module"]["efficiency-module"].effect =
        { consumption = { bonus = -1 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus - 0.001 } }
    data.raw["module"]["efficiency-module-2"].effect =
        { consumption = { bonus = -2 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus - 0.001 } }
    data.raw["module"]["efficiency-module-3"].effect =
        { consumption = { bonus = -3 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus - 0.001 } }
    data.raw["module"]["productivity-module"].effect = {
        productivity = { bonus = bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus + 0.001 },
        consumption = { bonus = bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty + 0.001 },
        pollution = { bonus = bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty + 0.001 },
    }
    data.raw["module"]["productivity-module-2"].effect = {
        productivity = { bonus = 2 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus + 0.001 },
        consumption = { bonus = 2 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty + 0.001 },
        pollution = { bonus = 2 * bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty + 0.001 },
    }
    data.raw["module"]["productivity-module-3"].effect = {
        productivity = { bonus = 3 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus + 0.001 },
        consumption = { bonus = 3 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty + 0.001 },
        pollution = { bonus = 3 * bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty + 0.001 },
    }
end

-- Prevent creature modules in beacon 2 and 3
if data.raw["beacon"]["bob-beacon-2"] then
    data.raw["beacon"]["bob-beacon-2"].allowed_effects = {'speed', 'consumption'}
end
if data.raw["beacon"]["bob-beacon-3"] then
    data.raw["beacon"]["bob-beacon-3"].allowed_effects = {'speed', 'consumption'}
end

-- Define vanilla module recipes with Bob's ingredients (2.0 names with bob- prefix)
data.raw["recipe"]["speed-module"].ingredients = {
    {type = "item", name = "bob-speed-processor", amount = 1},
    {type = "item", name = "bob-module-case", amount = 1},
    {type = "item", name = "bob-module-circuit-board", amount = 1},
    {type = "item", name = "bob-module-contact", amount = 4},
}
data.raw["recipe"]["efficiency-module"].ingredients = {
    {type = "item", name = "bob-efficiency-processor", amount = 1},
    {type = "item", name = "bob-module-case", amount = 1},
    {type = "item", name = "bob-module-circuit-board", amount = 1},
    {type = "item", name = "bob-module-contact", amount = 4},
}
data.raw["recipe"]["productivity-module"].ingredients = {
    {type = "item", name = "bob-productivity-processor", amount = 1},
    {type = "item", name = "bob-module-case", amount = 1},
    {type = "item", name = "bob-module-circuit-board", amount = 1},
    {type = "item", name = "bob-module-contact", amount = 4},
}

data.raw["recipe"]["speed-module-2"].ingredients = {
    {type = "item", name = "speed-module", amount = 1},
    {type = "item", name = "bob-speed-processor", amount = 2},
    {type = "item", name = "bob-module-contact", amount = 5},
}
data.raw["recipe"]["efficiency-module-2"].ingredients = {
    {type = "item", name = "efficiency-module", amount = 1},
    {type = "item", name = "bob-efficiency-processor", amount = 2},
    {type = "item", name = "bob-module-contact", amount = 5},
}
data.raw["recipe"]["productivity-module-2"].ingredients = {
    {type = "item", name = "productivity-module", amount = 1},
    {type = "item", name = "bob-productivity-processor", amount = 2},
    {type = "item", name = "bob-module-contact", amount = 5},
}

data.raw["recipe"]["speed-module-3"].ingredients = {
    {type = "item", name = "speed-module-2", amount = 1},
    {type = "item", name = "bob-speed-processor-2", amount = 3},
    {type = "item", name = "advanced-circuit", amount = 5},
}
data.raw["recipe"]["efficiency-module-3"].ingredients = {
    {type = "item", name = "efficiency-module-2", amount = 1},
    {type = "item", name = "bob-efficiency-processor-2", amount = 3},
    {type = "item", name = "advanced-circuit", amount = 5},
}
data.raw["recipe"]["productivity-module-3"].ingredients = {
    {type = "item", name = "productivity-module-2", amount = 1},
    {type = "item", name = "bob-productivity-processor-2", amount = 3},
    {type = "item", name = "advanced-circuit", amount = 5},
}

-- Beacon productivity/pollution when Bob's setting allows it
if settings.startup["bobmods-modules-transmitproductivity"] and settings.startup["bobmods-modules-transmitproductivity"].value == true then
    for _, beacon in pairs(data.raw.beacon) do
        if beacon.allowed_effects then
            table.insert(beacon.allowed_effects, "productivity")
            table.insert(beacon.allowed_effects, "pollution")
        end
    end
end
