local specs = {
  {n='auf-primitive-saphirite-sorting', l={'', 'Primitive saphirite hand sorting'}, i='angels-ore1-crushed', r={{'angels-slag',1,nil},{'iron-ore',1,0.20},{'copper-ore',1,0.10}}},
  {n='auf-primitive-jivolite-sorting', l={'', 'Primitive jivolite hand sorting'}, i='angels-ore2-crushed', r={{'angels-slag',1,nil},{'iron-ore',1,0.20},{'copper-ore',1,0.10}}},
  {n='auf-primitive-stiratite-sorting', l={'', 'Primitive stiratite hand sorting'}, i='angels-ore3-crushed', r={{'angels-slag',1,nil},{'copper-ore',1,0.20},{'iron-ore',1,0.10}}},
  {n='auf-primitive-crotinnium-sorting', l={'', 'Primitive crotinnium hand sorting'}, i='angels-ore4-crushed', r={{'angels-slag',1,nil},{'copper-ore',1,0.20},{'iron-ore',1,0.10}}},
  {n='auf-primitive-rubyte-sorting', l={'', 'Primitive rubyte hand sorting'}, i='angels-ore5-crushed', r={{'angels-slag',1,nil},{'bob-lead-ore',1,0.20},{'bob-nickel-ore',1,0.10}}},
  {n='auf-primitive-bobmonium-sorting', l={'', 'Primitive bobmonium hand sorting'}, i='angels-ore6-crushed', r={{'angels-slag',1,nil},{'bob-tin-ore',1,0.20},{'bob-quartz',1,0.10}}},
}

local function get_item(name)
  return data.raw.item and data.raw.item[name]
end

local function make_results(rows)
  local out = {}
  for _, row in pairs(rows) do
    if not get_item(row[1]) then return nil end
    local entry = {type='item', name=row[1], amount=row[2]}
    if row[3] then entry.probability = row[3] end
    out[#out + 1] = entry
  end
  return out
end

local function set_icon(recipe, source_name)
  local source = get_item(source_name)
  if source and source.icons then
    recipe.icons = source.icons
  elseif source and source.icon then
    recipe.icon = source.icon
    recipe.icon_size = source.icon_size or 64
    recipe.icon_mipmaps = source.icon_mipmaps
  else
    recipe.icon = '__base__/graphics/icons/iron-ore.png'
    recipe.icon_size = 64
  end
end

local character = data.raw.character and data.raw.character.character
if character then
  character.crafting_categories = character.crafting_categories or {'crafting'}
  local found = false
  for _, category in pairs(character.crafting_categories) do
    if category == 'auf-hand-sorting' then found = true end
  end
  if not found then table.insert(character.crafting_categories, 'auf-hand-sorting') end
end

local add = {}
for _, s in pairs(specs) do
  local results = make_results(s.r)
  if get_item(s.i) and results and not data.raw.recipe[s.n] then
    local recipe = {
      type='recipe',
      name=s.n,
      localised_name=s.l,
      enabled=true,
      category='auf-hand-sorting',
      energy_required=4,
      ingredients={{type='item', name=s.i, amount=5}},
      results=results,
      allow_productivity=false,
      always_show_products=true,
      allow_decomposition=false,
    }
    set_icon(recipe, s.i)
    add[#add + 1] = recipe
  end
end

if #add > 0 then data:extend(add) end
