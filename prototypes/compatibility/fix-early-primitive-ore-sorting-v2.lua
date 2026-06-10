local specs = {
  {n='auf-primitive-stiratite-sorting', i='angels-ore1-crushed', r={{'angels-slag',1,nil},{'iron-ore',1,0.25},{'copper-ore',1,0.10}}},
  {n='auf-primitive-saphirite-sorting', i='angels-ore2-crushed', r={{'angels-slag',1,nil},{'iron-ore',1,0.25},{'copper-ore',1,0.10}}},
  {n='auf-primitive-jivolite-sorting', i='angels-ore3-crushed', r={{'angels-slag',1,nil},{'iron-ore',1,0.20},{'copper-ore',1,0.12}}},
  {n='auf-primitive-crotinnium-sorting', i='angels-ore4-crushed', r={{'angels-slag',1,nil},{'iron-ore',1,0.20},{'copper-ore',1,0.12}}},
  {n='auf-primitive-rubyte-sorting', i='angels-ore5-crushed', r={{'angels-slag',1,nil},{'bob-lead-ore',1,0.18},{'bob-nickel-ore',1,0.08}}},
  {n='auf-primitive-bobmonium-sorting', i='angels-ore6-crushed', r={{'angels-slag',1,nil},{'bob-tin-ore',1,0.18},{'bob-quartz',1,0.08}}},
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

local add = {}
for _, s in pairs(specs) do
  local results = make_results(s.r)
  if get_item(s.i) and results and not data.raw.recipe[s.n] then
    local recipe = {
      type='recipe',
      name=s.n,
      enabled=true,
      category='crafting',
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
