-- Temporary shim for Bob logistics underground belts that may be absent in
-- current Bob's Logistics 2.0 combinations.
--
-- Some legacy compatibility code writes max_distance directly to prototypes like
-- data.raw['underground-belt']['bob-turbo-underground-belt'].max_distance.
-- If the prototype is absent, that explodes before we get to guarded code.
--
-- This shim is intentionally temporary: install it immediately before requiring
-- the Bob data-updates compatibility file, then restore the original metatable
-- immediately after. That way later code that correctly checks prototype
-- existence still sees missing prototypes as nil.

local belt_table = data.raw and data.raw['underground-belt']
if not belt_table then return end

local shim_names = {
    ['bob-basic-underground-belt'] = true,
    ['bob-turbo-underground-belt'] = true,
    ['bob-ultimate-underground-belt'] = true,
}

_G.__auf_bob_underground_belt_original_mt = _G.__auf_bob_underground_belt_original_mt or nil

function _G.__auf_install_bob_underground_belt_shim()
    local t = data.raw and data.raw['underground-belt']
    if not t or _G.__auf_bob_underground_belt_shim_installed then return end

    _G.__auf_bob_underground_belt_original_mt = getmetatable(t)
    _G.__auf_bob_underground_belt_shim_installed = true

    local original_mt = _G.__auf_bob_underground_belt_original_mt
    local original_index = original_mt and original_mt.__index or nil
    local warned = {}

    setmetatable(t, {
        __index = function(tbl, key)
            local original_value
            if type(original_index) == 'function' then
                original_value = original_index(tbl, key)
            elseif type(original_index) == 'table' then
                original_value = original_index[key]
            end
            if original_value ~= nil then
                return original_value
            end

            if shim_names[key] then
                if not warned[key] then
                    warned[key] = true
                    log("[AdminUnknownFixes] Missing underground belt '" .. key .. "'; using temporary no-op shim during Bob data-updates")
                end
                return { name = key, type = 'underground-belt', max_distance = 0 }
            end

            return nil
        end,
        __newindex = original_mt and original_mt.__newindex or nil,
        __pairs = original_mt and original_mt.__pairs or nil,
        __len = original_mt and original_mt.__len or nil,
    })
end

function _G.__auf_restore_bob_underground_belt_shim()
    local t = data.raw and data.raw['underground-belt']
    if not t or not _G.__auf_bob_underground_belt_shim_installed then return end

    setmetatable(t, _G.__auf_bob_underground_belt_original_mt)
    _G.__auf_bob_underground_belt_original_mt = nil
    _G.__auf_bob_underground_belt_shim_installed = false
end
