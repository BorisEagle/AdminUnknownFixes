-- Make Angel's first ore sorting facility fit the early Py electronics curve.
--
-- In this mod combination, Ore Sorting Facility 1 can inherit a Simple circuit
-- board requirement that belongs much later than the first ore sorting step.
-- Replace that specific 12-board requirement with 36 Air-core inductors.

local recipe_names = {
  'angels-ore-sorting-facility',
  'ore-sorting-facility',
}

local simple_circuit_board_names = {
  ['electronic-circuit'] = true,
  ['basic-circuit-board'] = true,
  ['bob-basic-circuit-board'] = true,
  ['circuit-board'] = true,
  ['t1-circuit'] = true,
  ['circuit-grey-board'] = true,
}

local function patch_ingredients(ingredients)
  if not ingredients then return end

  for _, ingredient in pairs(ingredients) do
    local name = ingredient.name or ingredient[1]
    local amount = ingredient.amount or ingredient[2]

    if simple_circuit_board_names[name] and amount == 12 then
      if ingredient.name then
        ingredient.type = 'item'
        ingredient.name = 'inductor1'
        ingredient.amount = 36
      else
        ingredient[1] = 'inductor1'
        ingredient[2] = 36
      end
    end
  end
end

if data.raw.recipe and data.raw.item and data.raw.item['inductor1'] then
  for _, recipe_name in pairs(recipe_names) do
    local recipe = data.raw.recipe[recipe_name]
    if recipe then
      patch_ingredients(recipe.ingredients)
      if recipe.normal then patch_ingredients(recipe.normal.ingredients) end
      if recipe.expensive then patch_ingredients(recipe.expensive.ingredients) end
    end
  end
end
