-- Let the starting stone furnace run early mixed smelting recipes.
--
-- In the current Bob + Angel + Py + Yuoki stack, the enabled iron-plate recipe
-- uses the normal smelting category but has two item ingredients:
--   angels crushed ore + iron ore -> iron plate
-- A stone furnace can craft smelting, but with only one source slot it cannot
-- actually accept that recipe. Advanced/mixing furnaces solve this later, but
-- those require plates already, creating a burner-phase deadlock.

local function ensure_source_slots(name, count)
  local furnace = data.raw.furnace and data.raw.furnace[name]
  if furnace then
    furnace.source_inventory_size = math.max(furnace.source_inventory_size or 1, count)
  end
end

ensure_source_slots('stone-furnace', 2)
