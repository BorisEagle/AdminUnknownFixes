-- Paired with fix-sulfur-processing-prerequisites.lua and patch-pypp-impossible-research-validation.lua.
-- Must run first in our data-final-fixes (after pypostprocessing's data-final-fixes).

if _G.__auf_saved_global_error then
    local e = _G.__auf_saved_global_error
    _G.__auf_saved_global_error = nil
    _G.error = e
    ---@diagnostic disable-next-line: duplicate-set-field
    error = e
end

local r = _G.__auf_sulfur_processing_restore
if r and data.raw.technology["sulfur-processing"] then
    data.raw.technology["sulfur-processing"].hidden = r.hidden
end
_G.__auf_sulfur_processing_restore = nil
