-- Return a chainable no-op TECHNOLOGY() proxy for known optional technologies
-- that this compatibility bridge or pypostprocessing may touch without checking.
--
-- Current Bob/Angel 2.0 combinations can omit or rename some technologies that
-- older compatibility code still expects. Calling TECHNOLOGY("missing-tech")
-- normally errors in pypostprocessing/lib/metas/technology.lua, so guard the
-- known optional names here instead of sprinkling existence checks everywhere.

if not _G.TECHNOLOGY then return end

local tech_mt = getmetatable(TECHNOLOGY)
if not tech_mt or type(tech_mt.__call) ~= "function" then return end

local function chainable_dummy(name)
    local t = { name = name, type = "technology" }
    setmetatable(t, {
        __index = function(_, _)
            return function(self, ...)
                return self
            end
        end,
    })
    return t
end

local missing_ok = {
    -- Bob optional/moved technologies
    ["bob-thorium-processing"] = true,
    ["bob-deuterium-fuel-reprocessing"] = true,

    -- Angel smelting technologies that may be absent/renamed in current Angel 2.0
    -- while old Py+Angel bridge code still adds packs/prerequisites to them.
    ["angels-solder-smelting-basic"] = true,
    ["angels-metallurgy-1"] = true,
    ["angels-metallurgy-2"] = true,
    ["angels-copper-smelting-1"] = true,
    ["angels-iron-smelting-1"] = true,
    ["angels-lead-smelting-1"] = true,
    ["angels-tin-smelting-1"] = true,
    ["angels-solder-smelting-1"] = true,
    ["angels-stone-smelting-1"] = true,
    ["angels-glass-smelting-1"] = true,
    ["angels-ceramic-smelting-1"] = true,
    ["angels-iron-casting-2"] = true,
    ["angels-copper-casting-2"] = true,
}

local orig_call = tech_mt.__call
tech_mt.__call = function(self, technology)
    if type(technology) == "string" and not self[technology] and missing_ok[technology] then
        log("[AdminUnknownFixes] TECHNOLOGY('" .. technology .. "') missing; returning no-op compatibility shim")
        return chainable_dummy(technology)
    end
    return orig_call(self, technology)
end
