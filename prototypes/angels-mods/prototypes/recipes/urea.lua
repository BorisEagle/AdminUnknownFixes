RECIPE {
    type = "recipe",
    name = "urea-gasification",
    category = "gasifier",
    enabled = false,
    energy_required = 3,
    ingredients = {
      	{type = 'item', name = 'urea', amount = 10},
        {type = 'fluid', name = 'gas-compressed-air', amount = 50},
    },
    results = {
        {type = 'fluid', name = 'gas-urea', amount = 200},
        {type = 'item', name = 'ash', amount = 2},
    },
    -- Do not set main_product to a fluid name: pypostprocessing data-final-fixes uses ITEM(main_product) and errors.
}:add_unlock('resin-1')