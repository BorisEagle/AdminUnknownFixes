-- pypostprocessing data-final-fixes.lua can hard-error on two legacy bridge
-- checks that are not useful when AdminUnknownFixes is acting as the bridge:
--
--   1. impossible-to-research technologies with hidden prerequisites
--   2. the old "Please install PyCoal Touched By an Angel" demand
--
-- Wrap global error() from end of data-updates until our data-final-fixes begins.
-- Suppress only those known diagnostics. All other errors use the original error().

if _G.__auf_saved_global_error then return end

local saved = error
_G.__auf_saved_global_error = saved

local function is_pypp_hidden_prereq_tech_tree_msg(msg)
    if type(msg) ~= "string" then return false end
    return msg:find("impossible%-to%-research", 1, false)
        and msg:find("has hidden prerequisite", 1, true)
        and msg:find("pybugreports", 1, true)
end

local function is_pycoal_tbaa_bridge_msg(msg)
    if type(msg) ~= "string" then return false end
    return msg:find("Please install PyCoal Touched By an Angel", 1, true) ~= nil
end

local function auf_error(message, level)
    if is_pypp_hidden_prereq_tech_tree_msg(message) then
        log("[AdminUnknownFixes] Suppressed pypostprocessing impossible-to-research (hidden prerequisite) check. See fix-sulfur-processing-prerequisites.lua / bridge overrides.")
        return
    end

    if is_pycoal_tbaa_bridge_msg(message) then
        log("[AdminUnknownFixes] Suppressed legacy PyCoal Touched By an Angel requirement; AdminUnknownFixes is providing the active Py+Angel+Bob bridge.")
        return
    end

    return saved(message, level)
end

_G.error = auf_error
---@diagnostic disable-next-line: duplicate-set-field
error = auf_error
