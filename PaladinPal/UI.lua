local _, ns = ...

local UI = {}
ns.UI = UI

local NO_SEAL_ICON = 134400 -- question mark icon

function UI:Init()
    local f = CreateFrame("Frame", "PaladinPalFrame", UIParent)
    f:SetSize(48, 48)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(frame)
        if not ns.db.locked then
            frame:StartMoving()
        end
    end)
    f:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, _, relPoint, x, y = frame:GetPoint()
        ns.db.point = { point, relPoint, x, y }
    end)

    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetAllPoints()

    f.cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
    f.cooldown:SetAllPoints()

    f.label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.label:SetPoint("TOP", f, "BOTTOM", 0, -2)

    self.frame = f
    self:ApplyPosition()
    self:ApplyLock()
end

function UI:ApplyPosition()
    local p = ns.db.point
    self.frame:ClearAllPoints()
    self.frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
end

function UI:ApplyLock()
    self.frame:EnableMouse(not ns.db.locked)
end

-- aura is the table from Seals:GetActiveSeal(), or nil when no seal is up.
function UI:SetSeal(aura)
    local f = self.frame
    if aura then
        f.icon:SetTexture(aura.icon)
        f.icon:SetDesaturated(false)
        f.icon:SetVertexColor(1, 1, 1)
        f.label:SetText((aura.name:gsub("^Seal of ", "")))
        if aura.duration and aura.duration > 0 then
            f.cooldown:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
        else
            f.cooldown:Clear()
        end
    else
        f.icon:SetTexture(NO_SEAL_ICON)
        f.icon:SetDesaturated(true)
        f.cooldown:Clear()
        if ns.db.warnNoSeal and UnitAffectingCombat("player") then
            f.icon:SetVertexColor(1, 0.3, 0.3)
            f.label:SetText("|cffff4040NO SEAL|r")
        else
            f.icon:SetVertexColor(1, 1, 1)
            f.label:SetText("No seal")
        end
    end
end
