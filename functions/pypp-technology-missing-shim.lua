-- PyPostProcessing's prototypes/functions/compatibility/bobs.lua calls
-- TECHNOLOGY("bob-thorium-processing"):remove_prereq("uranium-processing") when
-- uranium-processing is hidden and bobplates+bobpower+bobrevamp are present.
-- Current Bob's Revamp may omit that technology, so TECHNOLOGY() errors at
-- lib/metas/technology.lua:12 ("Technology bob-thorium-processing does not exist").
--
-- AdminUnknownFixes loads after pypostprocessing (dependency order), so we can
-- wrap TECHNOLOGY's __call here at end of data.lua and return a chainable no-op
-- for known optional Bob's tech names that pypp touches without existence checks.

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
    ["bob-thorium-processing"] = true,
    ["bob-deuterium-fuel-reprocessing"] = true,
}

local orig_call = tech_mt.__call
tech_mt.__call = function(self, technology)
    if type(technology) == "string" and not self[technology] and missing_ok[technology] then
        log("[AdminUnknownFixes] TECHNOLOGY('" .. technology .. "') missing; no-op shim for pypostprocessing compatibility/bobs.lua")
        return chainable_dummy(technology)
    end
    return orig_call(self, technology)
end
