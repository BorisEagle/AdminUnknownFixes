-- Factorio 2.0: assembling-machine with next_upgrade cannot mine a hidden item product.
-- Py global_item_replacer and others may hide the placed-machine item after earlier data-final-fixes;
-- clear next_upgrade last so validation passes.

local names = {
    "chemical-plant",
    "oil-refinery",
}

for _, name in ipairs(names) do
    local ent = data.raw["assembling-machine"][name]
    if ent then
        ent.next_upgrade = nil
    end
end
