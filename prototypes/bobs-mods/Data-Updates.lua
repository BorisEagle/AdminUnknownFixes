
require('functions/fix-missing-bob-underground-belts')
if type(_G.__auf_install_bob_underground_belt_shim) == 'function' then
	_G.__auf_install_bob_underground_belt_shim()
end

require('prototypes/bobs-mods/prototypes/overrides/overrides-updates')

if type(_G.__auf_restore_bob_underground_belt_shim) == 'function' then
	_G.__auf_restore_bob_underground_belt_shim()
end

if mods['angelsrefining'] then
	require('prototypes/bobs-mods/prototypes/overrides/angels/overrides-updates')
else
	require('prototypes/bobs-mods/prototypes/overrides/no-angels/overrides-updates')
end
