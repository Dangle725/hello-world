local _, ns = ...

local Seals = {}
ns.Seals = Seals

-- Seal buffs are matched by name, so this only works on English clients.
-- Swap to a table of spell IDs once the Forever IDs are confirmed.
local SEAL_PATTERN = "^Seal of "

-- Returns the active seal's aura data (name, icon, expirationTime, ...) or nil.
function Seals:GetActiveSeal()
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if not aura then
            return nil
        end
        if aura.name and aura.name:find(SEAL_PATTERN) then
            return aura
        end
    end
end

function Seals:Update()
    ns.UI:SetSeal(self:GetActiveSeal())
end

function Seals:Init()
    local f = CreateFrame("Frame")
    f:RegisterUnitEvent("UNIT_AURA", "player")
    f:RegisterEvent("PLAYER_REGEN_DISABLED") -- entered combat
    f:RegisterEvent("PLAYER_REGEN_ENABLED")  -- left combat
    f:SetScript("OnEvent", function()
        self:Update()
    end)
    self:Update()
end
