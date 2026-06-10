local function has_item(name)
  return data.raw.item and data.raw.item[name]
end

local function has_recipe(name)
  return data.raw.recipe and data.raw.recipe[name]
end

local function add_item(name, label, icon)
  if not has_item(name) then
    data:extend({{
      type='item',
      name=name,
      localised_name={'',label},
      icon=icon,
      icon_size=64,
      subgroup='raw-material',
      order='a[' .. name .. ']',
      stack_size=100,
    }})
  end
end

local function add_charge_recipe(add, metal, ore, charge, crushed)
  local name = 'auf-' .. metal .. '-smelting-charge-' .. crushed
  if has_item(charge) and has_item(ore) and has_item(crushed) and not has_recipe(name) then
    add[#add + 1] = {
      type='recipe',
      name=name,
      localised_name={'','Prepare primitive ' .. metal .. ' smelting charge'},
      enabled=true,
      category='auf-hand-sorting',
      energy_required=2,
      ingredients={{type='item', name=ore, amount=8}, {type='item', name=crushed, amount=3}},
      results={{type='item', name=charge, amount=1}},
      allow_productivity=false,
      allow_decomposition=false,
    }
  end
end

local function add_plate_recipe(add, metal, plate, charge)
  local name = 'auf-primitive-' .. metal .. '-plate'
  if has_item(charge) and has_item(plate) and not has_recipe(name) then
    add[#add + 1] = {
      type='recipe',
      name=name,
      localised_name={'','Primitive ' .. metal .. ' plate smelting'},
      enabled=true,
      category='smelting',
      energy_required=3.2,
      ingredients={{type='item', name=charge, amount=1}},
      results={{type='item', name=plate, amount=2}},
      allow_productivity=false,
      allow_decomposition=false,
    }
  end
end

if has_item('iron-ore') then
  add_item('auf-iron-smelting-charge', 'Primitive iron smelting charge', '__base__/graphics/icons/iron-ore.png')
end

if has_item('copper-ore') then
  add_item('auf-copper-smelting-charge', 'Primitive copper smelting charge', '__base__/graphics/icons/copper-ore.png')
end

local crushed_ores = {
  'angels-ore1-crushed',
  'angels-ore2-crushed',
  'angels-ore3-crushed',
  'angels-ore4-crushed',
}

local add = {}
for _, crushed in pairs(crushed_ores) do
  add_charge_recipe(add, 'iron', 'iron-ore', 'auf-iron-smelting-charge', crushed)
  add_charge_recipe(add, 'copper', 'copper-ore', 'auf-copper-smelting-charge', crushed)
end

add_plate_recipe(add, 'iron', 'iron-plate', 'auf-iron-smelting-charge')
add_plate_recipe(add, 'copper', 'copper-plate', 'auf-copper-smelting-charge')

if #add > 0 then data:extend(add) end
