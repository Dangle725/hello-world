local addonName, ns = ...

local defaults = {
    point = { "CENTER", "CENTER", 0, -150 },
    locked = false,
    warnNoSeal = true,
}

function ns.Print(msg)
    print("|cfff58cbaPaladin Pal|r: " .. msg)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        PaladinPalDB = PaladinPalDB or {}
        for k, v in pairs(defaults) do
            if PaladinPalDB[k] == nil then
                PaladinPalDB[k] = v
            end
        end
        ns.db = PaladinPalDB
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        local _, class = UnitClass("player")
        if class ~= "PALADIN" then
            return
        end
        ns.UI:Init()
        ns.Seals:Init()
    end
end)

SLASH_PALADINPAL1 = "/paladinpal"
SLASH_PALADINPAL2 = "/ppal"
SlashCmdList.PALADINPAL = function(msg)
    msg = strtrim(msg or ""):lower()
    if msg == "lock" or msg == "unlock" then
        ns.db.locked = (msg == "lock")
        ns.UI:ApplyLock()
        ns.Print(ns.db.locked and "Frame locked." or "Frame unlocked; drag to move.")
    elseif msg == "reset" then
        ns.db.point = CopyTable(defaults.point)
        ns.UI:ApplyPosition()
        ns.Print("Frame position reset.")
    elseif msg == "warn" then
        ns.db.warnNoSeal = not ns.db.warnNoSeal
        ns.Print("No-seal warning " .. (ns.db.warnNoSeal and "on." or "off."))
    else
        ns.Print("Commands: /ppal lock | unlock | reset | warn")
    end
end
