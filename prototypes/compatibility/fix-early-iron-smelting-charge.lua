local function has_item(name)
  return data.raw.item and data.raw.item[name]
end

local function has_recipe(name)
  return data.raw.recipe and data.raw.recipe[name]
end

if has_item('iron-ore') and not has_item('auf-iron-smelting-charge') then
  data:extend({{
    type='item',
    name='auf-iron-smelting-charge',
    localised_name={'','Primitive iron smelting charge'},
    icon='__base__/graphics/icons/iron-ore.png',
    icon_size=64,
    subgroup='raw-material',
    order='a[auf-iron-smelting-charge]',
    stack_size=100,
  }})
end

local ores = {
  'angels-ore1-crushed',
  'angels-ore2-crushed',
  'angels-ore3-crushed',
  'angels-ore4-crushed',
}

local add = {}
for _, ore in pairs(ores) do
  local name = 'auf-iron-smelting-charge-' .. ore
  if has_item('auf-iron-smelting-charge') and has_item('iron-ore') and has_item(ore) and not has_recipe(name) then
    add[#add + 1] = {
      type='recipe',
      name=name,
      localised_name={'','Prepare primitive iron smelting charge'},
      enabled=true,
      category='auf-hand-sorting',
      energy_required=2,
      ingredients={{type='item', name='iron-ore', amount=8}, {type='item', name=ore, amount=3}},
      results={{type='item', name='auf-iron-smelting-charge', amount=1}},
      allow_productivity=false,
      allow_decomposition=false,
    }
  end
end

if has_item('auf-iron-smelting-charge') and has_item('iron-plate') and not has_recipe('auf-primitive-iron-plate') then
  add[#add + 1] = {
    type='recipe',
    name='auf-primitive-iron-plate',
    localised_name={'','Primitive iron plate smelting'},
    enabled=true,
    category='smelting',
    energy_required=3.2,
    ingredients={{type='item', name='auf-iron-smelting-charge', amount=1}},
    results={{type='item', name='iron-plate', amount=2}},
    allow_productivity=false,
    allow_decomposition=false,
  }
end

if #add > 0 then data:extend(add) end
