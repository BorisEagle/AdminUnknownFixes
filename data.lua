fun = require("functions/functions")
--log(serpent.block(fun))

require('prototypes/recipe-category')

if settings.startup['prod-for-sinners'].value then
	require('functions/sinners-prod')
end

--multi-mod
--aka stuff many mods need
--require('prototypes/multi-mod/Data')

--angel mods
require('prototypes/angels-mods/Data')

--aai
require('prototypes/aai/Data')

--bobs mods
require('prototypes/bobs-mods/Data')

--omni mods
--require("prototypes/omni-mods/Data")

--madclown mods
require('prototypes/madclowns-mods/data')

--msp
if mods['MoreSciencePacks-for1_1'] then
	require('prototypes/msp/Data')
end

--apm mods
require('prototypes/apm-mods/Data')

-- Normalize malformed recipe entries before any data-updates stage begins.
-- Prevents Angel's override executor from crashing on entries without .name.
require('functions/normalize-recipe-entries')

-- Wrap Angel's OV helpers so recipe patches queued later in data-updates are
-- normalized before Angel executes them.
require('functions/fix-angels-ov-entry-normalization')

-- Compatibility fix: reapply pypostprocessing's metatables to any recipe/technology
-- prototype that was added via direct data.raw assignment instead of data:extend.
-- Prevents crashes like pypetroleumhandling's py.global_item_replacer at data-updates
-- stage (e.g. "attempt to call method 'replace_ingredient' (a nil value)").
-- Must run at the end of data.lua, before any data-updates stage begins.
require('functions/fix-pypp-metatables')

-- No-op TECHNOLOGY() for optional Bob's techs that pypostprocessing touches without guards.
require('functions/pypp-technology-missing-shim')
